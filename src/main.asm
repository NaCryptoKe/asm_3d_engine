; =============================================================================
; main.asm — Entry point and main game loop
; =============================================================================

bits 64
DEFAULT REL          ; all memory refs use RIP-relative addressing by default

extern x11_init
extern x11_shutdown
extern x11_blit
extern x11_poll_events
extern g_display
extern g_running
extern g_framebuf

global _start

; =============================================================================
section .data
align 8

err_msg     db "Error: could not open X11 display.", 0x0A
err_len     equ $ - err_msg

; =============================================================================
section .text

_start:
    ; ---- initialize X11 ----------------------------------------------------
    call    x11_init
    test    eax, eax
    jnz     .init_fail

    ; ---- paint framebuffer dark navy to prove it works ---------------------
    call    clear_screen
    call    x11_blit

    ; =========================================================================
    ; GAME LOOP
    ; =========================================================================
.game_loop:
    call    x11_poll_events

    ; (Phase 4) call player_update
    ; (Phase 2) call renderer_frame

    call    x11_blit

    movzx   eax, byte [g_running]   ; DEFAULT REL makes this RIP-relative — no warning
    test    eax, eax
    jnz     .game_loop

    call    x11_shutdown
    jmp     .exit_ok

.init_fail:
    mov     rax, 1              ; sys_write
    mov     rdi, 2              ; stderr
    lea     rsi, [err_msg]
    mov     rdx, err_len
    syscall

.exit_ok:
    mov     rax, 60             ; sys_exit
    xor     rdi, rdi
    syscall

; -----------------------------------------------------------------------------
; clear_screen — fill framebuffer with dark navy 0x1A1A2E
; -----------------------------------------------------------------------------
clear_screen:
    push    rbp
    mov     rbp, rsp

    mov     rdi, [g_framebuf]
    test    rdi, rdi
    jz      .done

    mov     ecx, 640 * 480
    mov     eax, 0x001A1A2E     ; dark navy (BGRA — blue channel gets 0x2E)

.fill:
    mov     dword [rdi], eax
    add     rdi, 4
    dec     ecx
    jnz     .fill

.done:
    pop     rbp
    ret
