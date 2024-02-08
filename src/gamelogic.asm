.segment "ZEROPAGE"
.segment "CODE"

; cursor X movement limited to between $00 - $FF (inclusive)
; cursor Y movement limited to between $07 - $E6 (inclusive)
set_new_cursor_pos:
    lda CURSORMOVEMENT
    and #%00000001
    beq not_moving_up
        ;moving_up:
        lda CURSORYPOS
        cmp #$07
        beq not_moving_up
            ldx CURSORYPOS
            dex 
            stx CURSORYPOS
            txa 
            and #%00000111
            cmp #%00000111
            bne not_moving_up
                ldx CURSORTILEYPOS
                dex 
                stx CURSORTILEYPOS
    not_moving_up:
    lda CURSORMOVEMENT
    and #%00000010
    beq not_moving_right
        ;moving_right:
        lda CURSORXPOS
        cmp #$FF
        beq not_moving_right
            ldx CURSORXPOS
            inx 
            stx CURSORXPOS
            txa 
            and #%00000111
            cmp #%00000000
            bne not_moving_right
                ldx CURSORTILEXPOS
                inx 
                stx CURSORTILEXPOS
    not_moving_right:
    lda CURSORMOVEMENT
    and #%00000100
    beq not_moving_down
        ;moving_down:
        lda CURSORYPOS
        cmp #$E6
        beq not_moving_down
            ldx CURSORYPOS
            inx 
            stx CURSORYPOS
            txa 
            and #%00000111
            cmp #%00000000
            bne not_moving_down
                ldx CURSORTILEYPOS
                inx  
                stx CURSORTILEYPOS
    not_moving_down:
    lda CURSORMOVEMENT
    and #%00001000
    beq not_moving_left
        ;moving_left:
        lda CURSORXPOS
        cmp #$00
        beq not_moving_left
            ldx CURSORXPOS
            dex 
            stx CURSORXPOS
            txa 
            and #%00000111
            cmp #%00000111
            bne not_moving_left
                ldx CURSORTILEXPOS
                dex 
                stx CURSORTILEXPOS
    not_moving_left:

    rts 

clear_board:
    ldx #0
    loop_thru_clear_deck:
        lda #0
        sta DECK, x
        inx 
        cpx #52
        bne loop_thru_clear_deck
    lda #0
    sta DRAWPILE
    sta DRAWPILE+1
    sta DRAWPILE+2
    sta DISCARDPILES
    sta DISCARDPILES+1
    sta DISCARDPILES+2
    sta DISCARDPILES+3
    loop_thru_clear_col_1:
        lda #0
        sta BOARDCOL1, x
        inx 
        cpx #20
        bne loop_thru_clear_col_1
    loop_thru_clear_col_2:
        lda #0
        sta BOARDCOL2, x
        inx 
        cpx #20
        bne loop_thru_clear_col_2
    loop_thru_clear_col_3:
        lda #0
        sta BOARDCOL3, x
        inx 
        cpx #20
        bne loop_thru_clear_col_3
    loop_thru_clear_col_4:
        lda #0
        sta BOARDCOL4, x
        inx 
        cpx #20
        bne loop_thru_clear_col_4
    loop_thru_clear_col_5:
        lda #0
        sta BOARDCOL5, x
        inx 
        cpx #20
        bne loop_thru_clear_col_5
    loop_thru_clear_col_6:
        lda #0
        sta BOARDCOL6, x
        inx 
        cpx #20
        bne loop_thru_clear_col_6
    loop_thru_clear_col_7:
        lda #0
        sta BOARDCOL7, x
        inx 
        cpx #20
        bne loop_thru_clear_col_7
    rts 