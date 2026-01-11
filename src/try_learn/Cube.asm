org 0x7C00
bits 16

start:
    jmp main

; Variables
width DW ?
height DW ?
x DW ?
y DW ?
end_x DW ?
end_y DW ?

; A function to set the origin at the center and the X and Y cordinate to range from -1 - 1
; Offset = (Y * 320) + X, which means ((Y * 256) + (Y * 64)) + X
offset_calc:
    mov ax, dx
    shl ax, 8

    mov bx, dx
    shl bx, 6

    add ax, bx ; Did Y * 320

    add ax, cx ; Finished
    ret

; Draw a pixel function
draw_pixel:
    mov di, ax      ; The place the pixel is being drawn, is on di
    mov byte[es:di], bl ; Writing color byte into ES:DI
    ret

; A function to draw a square
draw_square:
    ; Calculate end coordinates for the square
    mov ax, [x]
    add ax, [width]
    mov [end_x], ax

    mov ax, [y]
    add ax, [height]
    mov [end_y], ax

    mov dx, [y]             ; dx = current y
    row_loop:
        mov cx, [x]         ; cx = current x
    column_loop:
        call offset_calc
        mov bl, 0x04        ; square color
        call draw_pixel

        inc cx
        cmp cx, [end_x]
        jne column_loop

        inc dx
        cmp dx, [end_y]
        jne row_loop
        ret


; The entry of the function
main:
    ; reseting registers to 0
    xor ax, ax     
    mov ds, ax      
    mov ss, ax      
    ; Setting the stack pointer to the start of the boot sequence
    mov sp, 0x7C00

    ; enter the draw mode for VGA 320 x 200
    mov ah, 0
    mov al, 0x13
    int 0x10

    mov ax, 0xA000
    mov es, ax

; A simple function to draw the background
drawing_background:
    mov dx, 0

    reset_cx:
        mov cx, 0
        

    draw_column:
        call offset_calc

        mov bl, 0x97        ;background color
        call draw_pixel    
        
        inc cx
        cmp cx, 320
        jne draw_column

    draw_row:
        inc dx
        cmp dx, 200
        jne reset_cx


; RED SQUARE
mov word [y], 50        ; Y-axis starting point
mov word [x], 50        ; X-axis starting point
mov word [height], 5    ; Height of the square
mov word [width], 5     ; Width of the square
call draw_square

hold:
    jmp $

times 510 - ($ - $$) db 0
dw 0xAA55