; =============================================================================
; x11.asm — X11 window, framebuffer, events
; =============================================================================

bits 64
DEFAULT REL          ; RIP-relative addressing everywhere — no implicit ABS

extern XOpenDisplay
extern XDefaultScreen
extern XDefaultRootWindow
extern XCreateSimpleWindow
extern XSelectInput
extern XMapWindow
extern XNextEvent
extern XCreateGC
extern XPutImage
extern XCreateImage
extern XFlush
extern XStoreName
extern XDestroyWindow
extern XCloseDisplay
extern XDefaultVisual
extern XSync
extern XPending

%define SCREEN_W            640
%define SCREEN_H            480
%define SCREEN_DEPTH        24

%define KeyPressMask        0x00000001
%define KeyReleaseMask      0x00000002
%define ExposureMask        0x00008000
%define StructureNotifyMask 0x00020000

%define KeyPress_t          2
%define DestroyNotify_t     17

global x11_init
global x11_shutdown
global x11_blit
global x11_poll_events
global g_display
global g_window
global g_gc
global g_ximage
global g_framebuf
global g_running

; =============================================================================
section .data
align 8

g_display   dq 0
g_window    dq 0
g_gc        dq 0
g_ximage    dq 0
g_framebuf  dq 0
g_screen    dq 0
g_running   db 1

win_title   db "ASM 2.5D", 0

; =============================================================================
section .bss
align 16
xevent      resb 192

; =============================================================================
section .text

; -----------------------------------------------------------------------------
; Stack alignment reminder:
;   On entry to any function, rsp % 16 == 8  (call pushed 8-byte return addr)
;   push rbp  → rsp % 16 == 0
;   Each additional push adds 8 bytes.
;   Before any call: count pushes since last known 16-align point.
;   If odd number of extra pushes → sub rsp,8 to pad first.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; x11_init — open display, window, framebuffer, XImage
; Returns: eax = 0 success, 1 fail
; -----------------------------------------------------------------------------
x11_init:
    push    rbp
    mov     rbp, rsp
    push    rbx                 ; rbx = Display*
    push    r12                 ; r12 = screen
    push    r13                 ; r13 = root / Visual*
    push    r14                 ; r14 = spare
    ; Entry: rsp%16==8, push rbp→0, push rbx→8, push r12→0, push r13→8, push r14→0
    ; rsp is now 16-aligned. Good.

    ; XOpenDisplay(NULL)
    xor     edi, edi
    call    XOpenDisplay        ; rsp%16==0 before call ✓
    test    rax, rax
    jz      .fail
    mov     [g_display], rax
    mov     rbx, rax

    ; XDefaultScreen(display)
    mov     rdi, rbx
    call    XDefaultScreen
    mov     [g_screen], rax
    mov     r12, rax

    ; XDefaultRootWindow(display)
    mov     rdi, rbx
    call    XDefaultRootWindow
    mov     r13, rax

    ; XCreateSimpleWindow — 9 args (6 regs + 3 stack)
    ;   rsp%16==0 currently. 3 pushes = 24 bytes → 0+24=24, %16==8 → misaligned.
    ;   Sub 8 first to pad: after sub rsp,8 → rsp%16==8, then 3 pushes → 24 more
    ;   → rsp%16 == (8+24)%16 == 0. ✓
    mov     rdi, rbx            ; display
    mov     rsi, r13            ; parent = root
    xor     edx, edx            ; x
    xor     ecx, ecx            ; y
    mov     r8d,  SCREEN_W      ; width
    mov     r9d,  SCREEN_H      ; height
    sub     rsp, 8              ; alignment pad
    push    qword 0             ; background = black
    push    qword 0             ; border color
    push    qword 0             ; border_width
    call    XCreateSimpleWindow
    add     rsp, 32             ; 3 args (24) + pad (8)
    test    rax, rax
    jz      .fail
    mov     [g_window], rax

    ; XStoreName(display, window, title)
    mov     rdi, rbx
    mov     rsi, [g_window]
    lea     rdx, [win_title]    ; DEFAULT REL → RIP-relative ✓
    call    XStoreName

    ; XSelectInput(display, window, mask)
    mov     rdi, rbx
    mov     rsi, [g_window]
    mov     edx, KeyPressMask | KeyReleaseMask | ExposureMask | StructureNotifyMask
    call    XSelectInput

    ; XMapWindow(display, window)
    mov     rdi, rbx
    mov     rsi, [g_window]
    call    XMapWindow

    ; XSync(display, False)
    mov     rdi, rbx
    xor     esi, esi
    call    XSync

    ; mmap(NULL, W*H*4, PROT_RW, MAP_PRIVATE|MAP_ANON, -1, 0)
    mov     rax, 9
    xor     rdi, rdi
    mov     rsi, SCREEN_W * SCREEN_H * 4
    mov     rdx, 3
    mov     r10, 0x22
    mov     r8,  -1
    xor     r9d, r9d
    syscall
    cmp     rax, -4096
    ja      .fail
    mov     [g_framebuf], rax

    ; XDefaultVisual(display, screen)
    mov     rdi, rbx
    mov     rsi, r12
    call    XDefaultVisual
    mov     r13, rax            ; Visual*

    ; XCreateImage — 10 args (6 regs + 4 stack)
    ;   rsp%16==0. 4 pushes = 32 bytes → still 0. No pad needed. ✓
    mov     rdi, rbx            ; display
    mov     rsi, r13            ; visual
    mov     edx, SCREEN_DEPTH   ; depth = 24
    mov     ecx, 2              ; ZPixmap
    xor     r8d, r8d            ; offset = 0
    mov     r9,  [g_framebuf]   ; data
    push    qword 0             ; bytes_per_line = 0 (auto)
    push    qword 32            ; bitmap_pad
    push    qword SCREEN_H
    push    qword SCREEN_W
    call    XCreateImage
    add     rsp, 32
    test    rax, rax
    jz      .fail
    mov     [g_ximage], rax

    ; XCreateGC(display, window, 0, NULL)
    mov     rdi, rbx
    mov     rsi, [g_window]
    xor     edx, edx
    xor     ecx, ecx
    call    XCreateGC
    mov     [g_gc], rax

    xor     eax, eax
    jmp     .done

.fail:
    mov     eax, 1
.done:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

; -----------------------------------------------------------------------------
; x11_blit — XPutImage + XFlush
; -----------------------------------------------------------------------------
x11_blit:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    ; Entry rsp%16==8, push rbp→0, push rbx→8, push r12→0. Aligned. ✓
    ; XPutImage — 10 args (6 regs + 4 stack). 4 pushes=32 → still aligned. ✓
    mov     rdi, [g_display]
    mov     rsi, [g_window]
    mov     rdx, [g_gc]
    mov     rcx, [g_ximage]
    xor     r8d, r8d            ; src_x
    xor     r9d, r9d            ; src_y
    push    qword SCREEN_H      ; height
    push    qword SCREEN_W      ; width
    push    qword 0             ; dst_y
    push    qword 0             ; dst_x
    call    XPutImage
    add     rsp, 32

    mov     rdi, [g_display]
    call    XFlush

    pop     r12
    pop     rbx
    pop     rbp
    ret

; -----------------------------------------------------------------------------
; x11_poll_events — non-blocking drain
; -----------------------------------------------------------------------------
x11_poll_events:
    push    rbp
    mov     rbp, rsp
    push    rbx
    ; rsp%16==8 → push rbp→0 → push rbx→8. One extra push = misaligned.
    ; Before each call below we need to check:
    ;   XPending: no stack args, rsp%16==8 → sub 8 first? 
    ;   Actually: after push rbp (rsp%16=0) and push rbx (rsp%16=8),
    ;   calls need rsp%16==0 → need to pad.
    sub     rsp, 8              ; align: rsp%16 now == 0

.check_pending:
    mov     rdi, [g_display]
    call    XPending
    test    eax, eax
    jz      .done

    mov     rdi, [g_display]
    lea     rsi, [xevent]       ; DEFAULT REL ✓
    call    XNextEvent

    mov     eax, dword [xevent]

    cmp     eax, DestroyNotify_t
    je      .quit

    cmp     eax, KeyPress_t
    jne     .check_pending

    ; XKeyEvent.keycode is at byte offset +84
    mov     eax, dword [xevent + 84]
    cmp     eax, 9              ; Escape keycode
    je      .quit
    cmp     eax, 24             ; 'q' keycode
    je      .quit
    jmp     .check_pending

.quit:
    mov     byte [g_running], 0
.done:
    add     rsp, 8              ; restore pad
    pop     rbx
    pop     rbp
    ret

; -----------------------------------------------------------------------------
; x11_shutdown
; -----------------------------------------------------------------------------
x11_shutdown:
    push    rbp
    mov     rbp, rsp

    cmp     qword [g_window], 0
    je      .no_window
    mov     rdi, [g_display]
    mov     rsi, [g_window]
    call    XDestroyWindow
.no_window:
    cmp     qword [g_display], 0
    je      .no_display
    mov     rdi, [g_display]
    call    XCloseDisplay
.no_display:
    pop     rbp
    ret
