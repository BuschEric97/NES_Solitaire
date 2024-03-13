.segment "IMG"
    .incbin "rom.chr"

.segment "ZEROPAGE"
    CURSORMOVEMENT: .res 1  ; #%0000LDRU
    CURSORXPOS: .res 1
    CURSORTILEXPOS: .res 1
    CURSORYPOS: .res 1
    CURSORTILEYPOS: .res 1
    CURCARDID: .res 1       ; #%HSSVVVVV (H == hidden flag (for drawing the back of the card), SS == suite, VVVVV == value)
    GAMEFLAG: .res 1        ; #%000000WG (W == win flag, G == game flag)
    SCORE: .res 4           ; score cannot be lower than 0000 or higher than 9999
    SCORECHANGE: .res 1     ; #%SVVVVVVV (S == sign (0 == add points, 1 == subtract points), VVVVVVV == value)
    SHUFFLES: .res 1        ; counter for how many times deck has been refreshed
    DECK: .res 52
    TOPDECKINDEX: .res 1       ; indicates which card is on the top of the deck, equals #$FF if deck is empty
    BOTTOMDECKINDEX: .res 1    ; indicates which card is on the bottom of the deck, equals #$FF if deck is empty
    DRAWPILEINDEX: .res 1      ; indicates which card from the deck is currently the top card of the draw pile, equals #$FF if draw pile is empty
    DISCARDPILES: .res 4
    BOARDCOL1: .res 14
    BOARDCOL2: .res 15
    BOARDCOL3: .res 16
    BOARDCOL4: .res 17
    BOARDCOL5: .res 18
    BOARDCOL6: .res 19
    BOARDCOL7: .res 20
    ; Move Storage Schema:
    ; a move position is a number from 0-148
    ;   0 == deck
    ;   1-3 == draw piles
    ;   145-148 == discard piles
    ;   5-24 == board column 1
    ;   25-44 == board column 2
    ;   45-64 == board column 3
    ;   65-84 == board column 4
    ;   85-104 == board column 5
    ;   105-124 == board column 6
    ;   125-144 == board column 7
    CURMOVEIND: .res 1      ; determines where to store click pos on A press: 0 == CURMOVESTART, 1 == CURMOVEEND
    CURMOVESTART: .res 1    ; current move starting board position
    CURMOVEEND: .res 1      ; current move ending board position
    MOVEVALIDATION: .res 1  ; #$00 == move is valid, #$01 == move is invalid

.segment "VARS"

.include "header.asm"
.include "utils.asm"
.include "gamepad.asm"
.include "ppu.asm"
.include "palette.asm"

.include "random.asm"
.include "drawing.asm"
.include "gamelogic.asm"

.include "title.asm"
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

    ; do score logic when a game is being played
    lda GAMEFLAG
    and #%00000001
    beq not_update_score
        ; decrease score by 1 every 256 frames
        lda seed+1
        bne not_update_score
            ;time_score_decrease
            lda #%10000001
            sta SCORECHANGE
            jsr update_score
    not_update_score:

    ;-----------------;
    ; CURSOR HANDLING ;
    ;-----------------;

    ; skip cursor code when game is not running
    lda GAMEFLAG
    and #%00000001
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
    jsr draw_cursor_0
    skip_cursor:

    ;-----------------;
    ; BUTTON HANDLING ;
    ;-----------------;

    ; see if button A was pressed
    lda gamepad_new_press
    and PRESS_A
    cmp PRESS_A
    bne a_not_pressed
        lda GAMEFLAG
        and #%00000001
        beq a_not_pressed
            jsr get_click_pos
            jsr adjust_click_pos

            ; skip a button logic if the click position is invalid
            lda CURCLICKPOS
            cmp #$FF
            beq a_not_pressed

            lda CURMOVEIND
            bne a_move_second_press
                ;a_move_first_press:
                lda CURCLICKPOS
                beq a_move_deck_clicked
                    ;a_move_deck_not_clicked:
                    lda CURCLICKPOS
                    sta CURMOVESTART

                    jsr get_cursor_1_pos
                    jsr draw_cursor_1

                    lda #1
                    sta CURMOVEIND

                    jmp a_not_pressed
                a_move_deck_clicked:
                    lda #0
                    sta CURMOVESTART
                    sta CURMOVEEND
                    jsr make_move

                jmp a_not_pressed
            a_move_second_press:
                lda CURCLICKPOS
                sta CURMOVEEND

                jsr erase_cursor_1

                lda #0
                sta CURMOVEIND

                jsr validate_move
                lda MOVEVALIDATION
                bne a_not_pressed
                    jsr make_move
    a_not_pressed:

    ; see if button B was pressed
    lda gamepad_new_press
    and PRESS_B
    cmp PRESS_B
    bne b_not_pressed
        nop 
    b_not_pressed:

    ; see if button SELECT was pressed
    lda gamepad_new_press
    and PRESS_SELECT
    cmp PRESS_SELECT
    bne select_not_pressed
        lda GAMEFLAG
        and #%00000001
        beq select_not_pressed
            lda #0
            sta CURMOVESTART
            sta CURMOVEEND
            jsr make_move
    select_not_pressed:

    ; see if button START was pressed
    lda gamepad_new_press
    and PRESS_START
    cmp PRESS_START
    bne start_not_pressed
        lda GAMEFLAG
        and #%00000001
        bne start_not_pressed   ; don't allow button START actions when game is being played
            jsr clear_board
            jsr clear_background
            jsr deal_board
            jsr draw_board
            jsr clear_score
            jsr draw_score

            lda #%00000001
            sta GAMEFLAG    ; set GAMEFLAG to 1 to indicate a game is being played

            ; initialize cursor position
            lda #$80
            sta CURSORXPOS
            sta CURSORYPOS
            lda #$10
            sta CURSORTILEXPOS
            sta CURSORTILEYPOS
    start_not_pressed:

    ; check if the game has been won
    lda GAMEFLAG
    and #%00000001
    beq game_win_check_done
        jsr check_for_win
    game_win_check_done:

    ; return to start of game loop
    jmp game_loop