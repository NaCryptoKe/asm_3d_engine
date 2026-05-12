; =============================================================================
; player.asm — player state and movement (Phase 4 — stub for now)
; =============================================================================
bits 64

global player_init
global player_update

; Player state (fixed-point Q16.16 for position and angle)
section .data
align 8

; Starting position: center of tile (2,2) — will move to map coords later
global g_player_x
global g_player_y
global g_player_angle

g_player_x      dq 0x00020000      ; 2.0 in Q16.16
g_player_y      dq 0x00020000      ; 2.0 in Q16.16
g_player_angle  dq 0               ; 0 radians (facing East) in Q16.16

section .text

player_init:
    ret

player_update:
    ; TODO Phase 4: read g_keys[], update position, check map collision
    ret
