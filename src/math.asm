; =============================================================================
; math.asm — fixed-point math helpers and trig tables (Phase 2)
; =============================================================================
; Fixed-point format: Q16.16
;   upper 16 bits = integer part
;   lower 16 bits = fractional part
;   e.g. 1.0 = 0x00010000,  0.5 = 0x00008000
;
; Trig tables: 1024-entry sine table, Q16.16, covering 0..2π
; (generated via Python and incbin'd, or computed at init — Phase 2 decision)
; =============================================================================
bits 64

global fp_mul          ; Q16.16 × Q16.16 → Q16.16
global fp_div          ; Q16.16 / Q16.16 → Q16.16

section .text

; fp_mul(a: rdi, b: rsi) → rax   (all Q16.16)
fp_mul:
    imul    rdi, rsi           ; 64-bit product in rdi (we ignore overflow for now)
    mov     rax, rdi
    sar     rax, 16            ; shift right 16 to re-normalise
    ret

; fp_div(a: rdi, b: rsi) → rax   (all Q16.16)
fp_div:
    test    rsi, rsi
    jz      .divzero
    mov     rax, rdi
    sal     rax, 16            ; shift numerator left 16
    cqo                        ; sign-extend rax into rdx:rax
    idiv    rsi
    ret
.divzero:
    mov     rax, 0x7FFFFFFF    ; return max on div/0
    ret
