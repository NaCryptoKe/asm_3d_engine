; ===== print_number.asm =====
; Linux x86-64 NASM
; Prints 123 using only syscalls (no libc)
; ----------------------------------------

section .data
    newline db 10          ; '\n'

section .text
    global _start

_start:
    ; --- 1. Initialization ---
    mov     rax, 123       ; The number to print
    mov     rbx, 10        ; Divisor (base 10)
    mov     rcx, 0         ; Digit counter

.convert_loop:
    mov     rdx, 0         ; Clear high part of dividend
    div     rbx            ; (RDX:RAX) / RBX → RAX=quotient, RDX=remainder
    add     dl, '0'        ; Convert remainder → ASCII digit
    dec     rsp            ; Make space for 1 byte on the stack
    mov     [rsp], dl      ; Store digit on stack
    inc     rcx            ; Increment byte counter
    cmp     rax, 0
    jnz     .convert_loop  ; Repeat until quotient == 0

    ; --- 2. Print number ---
    mov     rax, 1         ; sys_write
    mov     rdi, 1         ; STDOUT
    mov     rsi, rsp       ; Address of first digit
    mov     rdx, rcx       ; Number of digits
    syscall

    ; --- 3. Print newline ---
    mov     rax, 1         ; sys_write
    mov     rdi, 1
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; --- 4. Exit program ---
    mov     rax, 60        ; sys_exit
    xor     rdi, rdi       ; status 0
    syscall

