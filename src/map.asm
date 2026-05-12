; =============================================================================
; map.asm — tile grid data and lookup (Phase 3 — data ready, logic stub)
; =============================================================================
bits 64

global map_get_tile
global g_map
global MAP_W
global MAP_H

%define MAP_W   8
%define MAP_H   8

; Tile values:
;   0 = empty floor
;   1 = solid wall (stone)
;   2 = solid wall (brick) — different color later

section .data
align 8

; 8x8 map — row-major, left=West, right=East, top=North
g_map:
    db 1, 1, 1, 1, 1, 1, 1, 1   ; row 0 (North wall)
    db 1, 0, 0, 0, 0, 0, 0, 1   ; row 1
    db 1, 0, 1, 0, 0, 1, 0, 1   ; row 2
    db 1, 0, 0, 0, 0, 0, 0, 1   ; row 3
    db 1, 0, 1, 0, 0, 1, 0, 1   ; row 4
    db 1, 0, 0, 0, 0, 0, 0, 1   ; row 5
    db 1, 0, 0, 2, 2, 0, 0, 1   ; row 6
    db 1, 1, 1, 1, 1, 1, 1, 1   ; row 7 (South wall)

section .text

; map_get_tile(tile_x: rdi, tile_y: rsi) → tile_value in al
; Returns 0xFF if out of bounds
map_get_tile:
    cmp     rdi, MAP_W
    jae     .oob
    cmp     rsi, MAP_H
    jae     .oob

    ; index = y * MAP_W + x
    imul    rsi, MAP_W
    add     rsi, rdi
    movzx   eax, byte [g_map + rsi]
    ret
.oob:
    mov     eax, 0xFF
    ret
