; You can get the syscalls from /usr/include/asm/unistd_64.h for 64 bit and unistd_32 for 32 bit.

;The following segment hold initialized, readable and writtable data. (Like Variables)
section .data
    ; defining the the message and the length of the message
    msg db "10", 0xA     ; The string (the message), 0xA is the ASCII for newline or in other programming languages /n
    ; db stands for `Define Byte` indicating we're storing a string of characters i.e. a string
    len equ $ - msg                 ; Calculates the length of the message
    ; the above line is a assembler trick, $ holds the current memory address. What it basically doing is by using len (length) it subtracts the memory of msg from the current memory address

; This section holds the executable code or instructions
section .text
    ; The linker requires a global symbol for entry point to the program like C, CPP's main function.
    global _start                   

_start:
    ; Syscall 1 is for writing or printing
    mov rax, 1      ; sys_write is system call 1, The system call goes into memory address 1, This is the accumulator
    mov rdi, 1      ; First argument (File Descriptor): 1 for STDOUT, This is the destination index
    mov rsi, msg      ; Second argument (Buffer): The address of our message string, This is the source index
    mov rdx, len    ; Third argument (Count): The length of the message, This is the data register
    syscall         ; Execute the system call

    mov rax, 60     ; sys_exit is system call #60 
    mov rdi, 0      ; First argument (Exit Status): 0 for success 
    syscall         ; Execute the system call

; Assembly is case-insensetive on keywords, but case sensetive on user defined ones. Usually use all lowercases.

