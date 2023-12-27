.segment "IMG"
    .incbin "rom.chr"

.segment "ZEROPAGE"
    CURSORMOVEMENT: .res 1  ; #%0000LDRU
    CURSORXPOS: .res 1
    CURSORYPOS: .res 1

.segment "VARS"

.include "header.asm"
.include "utils.asm"
.include "gamepad.asm"
.include "ppu.asm"
.include "palette.asm"

.include "random.asm"
.include "drawing.asm"
.include "gamelogic.asm"

.include "nmi.asm"
.include "irq.asm"
.include "reset.asm"

.segment "CODE"
game_loop:
    lda nmi_ready
    bne game_loop

    ; get gamepad input
    jsr set_gamepad

    lda #0
    sta CURSORMOVEMENT  ; reset movement byte
    ; see if dpad UP was pressed
    lda gamepad_press
    and PRESS_UP
    cmp PRESS_UP
    bne up_not_pressed
        lda CURSORMOVEMENT
        clc 
        adc #%00000001
        sta CURSORMOVEMENT
    up_not_pressed:
    lda gamepad_press
    and PRESS_RIGHT
    cmp PRESS_RIGHT
    bne right_not_pressed
        lda CURSORMOVEMENT
        clc 
        adc #%00000010
        sta CURSORMOVEMENT
    right_not_pressed:
    lda gamepad_press
    and PRESS_DOWN
    cmp PRESS_DOWN
    bne down_not_pressed
        lda CURSORMOVEMENT
        clc 
        adc #%00000100
        sta CURSORMOVEMENT
    down_not_pressed:
    lda gamepad_press
    and PRESS_LEFT
    cmp PRESS_LEFT
    bne left_not_pressed
        lda CURSORMOVEMENT
        clc 
        adc #%00001000
        sta CURSORMOVEMENT
    left_not_pressed:

    jsr set_new_cursor_pos
    jsr draw_cursor

    ; return to start of game loop
    jmp game_loop