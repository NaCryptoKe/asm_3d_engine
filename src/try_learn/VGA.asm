org 0x7C00      ; Directive: Tells the assembler the code will be loaded at memory address 0x7C00, the standard boot sector location.
bits 16         ; Directive: Specifies that the assembler should generate 16-bit code, for the CPU's real mode.

start:
    jmp main    ; Jumps over any data/functions to the main execution label.

; --- Main Execution ---
main:
    ; --- Segment Register Initialization ---
    xor ax, ax      ; Sets the AX register to zero. A fast and common method.
    mov ds, ax      ; Sets the Data Segment (DS) register to 0.
    mov ss, ax      ; Sets the Stack Segment (SS) register to 0.
    mov sp, 0x7C00  ; Sets the Stack Pointer (SP) to 0x7C00. The stack will grow downwards from here.

    ; --- Set Video Mode ---
    mov ah, 0       ; Loads 0 into AH for the "Set Video Mode" function of the BIOS interrupt.
    mov al, 0x13    ; Loads 0x13 into AL, specifying the 320x200 pixels, 256-color graphics mode.
    int 0x10        ; Calls BIOS video interrupt 0x10 to apply the new video mode.

    ; --- Video Memory Setup ---
    mov ax, 0xA000  ; Loads the starting address of VGA video memory (for mode 0x13) into AX.
    mov es, ax      ; Moves the video memory address into the Extra Segment (ES) register, which we'll use for drawing.

    ; --- Pixel Drawing Logic ---
    ; This section draws a filled rectangle.

    mov dx, 50      ; Initializes DX with the starting Y-coordinate (row 50).

reset_cx:
    mov cx, 110     ; Resets CX to the starting X-coordinate (column 110) for each new row.

draw_column:    
    ; --- Calculate Pixel Offset in Memory ---
    ; The formula is: Offset = (Y * 320) + X, because the screen is 320 pixels wide.
    
    mov ax, dx      ; Copies Y-coordinate (from DX) into AX for calculation.
    shl ax, 8       ; Multiplies AX by 256 (Y * 256) by shifting bits left 8 times.
    mov bx, dx      ; Copies Y-coordinate (from DX) into BX for another calculation.
    shl bx, 6       ; Multiplies BX by 64 (Y * 64) by shifting bits left 6 times.
    add ax, bx      ; Adds the two results: (Y * 256) + (Y * 64) = Y * 320. AX now holds the row's starting offset.
    add ax, cx      ; Adds the X-coordinate (from CX) to get the final pixel offset.
    mov di, ax      ; Moves the final calculated offset into the Destination Index (DI) register.

    ; --- Draw the Pixel ---
    mov al, 220       ; Loads the color index 2 (Green in the standard VGA palette) into AL.
    mov byte [es:di], al ; Writes the color byte from AL into video memory at the location specified by ES:DI.
    
    ; --- Loop to Draw a Horizontal Line ---
    inc cx          ; Increments the X-coordinate to move to the next pixel to the right.
    cmp cx, 211     ; Compares the X-coordinate with 211.
    jne draw_column ; If CX is not equal to 211, jumps back to draw the next pixel in the line.

; --- Loop to Draw the Next Row ---
draw_row:
    inc dx          ; Increments the Y-coordinate to move to the row below.
    cmp dx, 151     ; Compares the Y-coordinate with 151.
    jne reset_cx    ; If DX is not equal to 151, jumps back to `reset_cx` to draw the next full row.

hold:
    ; --- Halt Execution ---
    jmp $           ; Jumps to the current address, creating an infinite loop to keep the image on screen.

; --- Boot Sector Padding and Signature ---
times 510-($-$$) db 0   ; Pads the file with zeros up to byte 510. `$` is current address, `$$` is start address.
dw 0xAA55               ; The boot signature. The BIOS requires these two bytes to identify a bootable device.