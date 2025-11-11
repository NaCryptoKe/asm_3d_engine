section .text
    global _start

_start:
    mov rax, 0
    mov rcx, 5

start_loop:
    add rax, rcx
    dec rcx
    jnz start_loop
    jmp exit

exit:
    mov rdi, rax
    mov rax, 60
    syscall
