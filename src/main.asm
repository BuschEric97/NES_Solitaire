.segment "IMG"
    .incbin "rom.chr"

.segment "ZEROPAGE"
    CURSORMOVEMENT: .res 1  ; #%0000LDRU
    CURSORXPOS: .res 1
    CURSORTILEXPOS: .res 1
    CURSORYPOS: .res 1
    CURSORTILEYPOS: .res 1
    CURCARDID: .res 1       ; HSSVVVVV (H == hidden flag (for drawing the back of the card), SS == suite, VVVVV == value)
    GAMEFLAG: .res 1        ; Flag to indicate when a game is being played
    DECK: .res 52
    TOPDECKINDEX: .res 1       ; indicates which card is on the top of the deck, equals #$FF if deck is empty
    DRAWPILE: .res 3
    DISCARDPILES: .res 4
    BOARDCOL1: .res 20
    BOARDCOL2: .res 20
    BOARDCOL3: .res 20
    BOARDCOL4: .res 20
    BOARDCOL5: .res 20
    BOARDCOL6: .res 20
    BOARDCOL7: .res 20

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

    ; skip cursor code when game is not running
    lda GAMEFLAG
    bne do_cursor_logic
        jmp skip_cursor
    do_cursor_logic:

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

    ; always draw the cursor when a game is being played
    jsr set_new_cursor_pos
    jsr draw_cursor
    skip_cursor:

    lda gamepad_press
    and PRESS_A
    cmp PRESS_A
    bne a_not_pressed
        lda #1
        sta DRAWBGCARD
        lda #%01000001
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

    ; see if button START was pressed
    lda gamepad_new_press
    and PRESS_START
    cmp PRESS_START
    bne start_not_pressed
        lda GAMEFLAG
        bne start_not_pressed   ; don't allow button START actions when game is being played
            jsr clear_board
            jsr clear_background
            
            ;TODO: deal cards
            lda #%11000001
            sta DECK
            lda #0
            sta TOPDECKINDEX

            lda #%01000001
            sta DRAWPILE
            sta DRAWPILE+1
            sta DRAWPILE+2

            lda #%01000001
            sta DISCARDPILES
            sta DISCARDPILES+1
            sta DISCARDPILES+2
            sta DISCARDPILES+3

            lda #%01000001
            sta BOARDCOL1
            sta BOARDCOL1+1
            sta BOARDCOL1+2
            sta BOARDCOL1+3
            sta BOARDCOL1+4
            sta BOARDCOL1+5
            sta BOARDCOL1+6
            sta BOARDCOL1+7
            lda #%01000011
            sta BOARDCOL2
            lda #%01000001
            sta BOARDCOL2+1
            sta BOARDCOL2+2
            sta BOARDCOL2+3
            sta BOARDCOL2+4
            sta BOARDCOL3
            sta BOARDCOL3+1
            sta BOARDCOL4
            sta BOARDCOL4+1
            sta BOARDCOL5
            sta BOARDCOL5+1
            sta BOARDCOL6
            sta BOARDCOL6+1
            sta BOARDCOL7
            sta BOARDCOL7+1

            jsr draw_board

            lda #1
            sta GAMEFLAG    ; set GAMEFLAG to 1 to indicate a game is being played

            ; initialize cursor position
            lda #$80
            sta CURSORXPOS
            sta CURSORYPOS
            lda #$10
            sta CURSORTILEXPOS
            sta CURSORTILEYPOS
    start_not_pressed:

    ; return to start of game loop
    jmp game_loop