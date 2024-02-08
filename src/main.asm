.segment "IMG"
    .incbin "rom.chr"

.segment "ZEROPAGE"
    CURSORMOVEMENT: .res 1  ; #%0000LDRU
    CURSORXPOS: .res 1
    CURSORTILEXPOS: .res 1
    CURSORYPOS: .res 1
    CURSORTILEYPOS: .res 1
    CURCARDID: .res 1   ; HSSVVVVV (H == hidden flag (for drawing the back of the card), SS == suite, VVVVV == value)
    DECK: .res 52
    DRAWPILE: .res 3
    BOARDCOL1: .res 20
    BOARDCOL2: .res 20
    BOARDCOL3: .res 20
    BOARDCOL4: .res 20
    BOARDCOL5: .res 20
    BOARDCOL6: .res 20
    BOARDCOL7: .res 20
    DISCARDPILES: .res 4

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

    ; increment seed to enhance pseudo-randomness
    lda seed+1
    clc 
    adc #1
    sta seed+1
    lda seed
    adc #0
    sta seed

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

    lda gamepad_press
    and PRESS_A
    cmp PRESS_A
    bne a_not_pressed
        lda #1
        sta DRAWBGCARD
        lda #%01000000
        sta BGCARDID
        lda CURSORTILEXPOS
        sta BGCARDTILEX
        lda CURSORTILEYPOS
        sta BGCARDTILEY
        jsr draw_bg_card
    a_not_pressed:

    lda gamepad_press
    and PRESS_B
    cmp PRESS_B
    bne b_not_pressed
        lda #0
        sta DRAWBGCARD
        lda CURSORTILEXPOS
        sta BGCARDTILEX
        lda CURSORTILEYPOS
        sta BGCARDTILEY
        jsr draw_bg_card
    b_not_pressed:

    ; return to start of game loop
    jmp game_loop