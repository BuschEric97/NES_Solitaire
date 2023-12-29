.segment "ZEROPAGE"
.segment "CODE"

set_new_cursor_pos:
    lda CURSORMOVEMENT
    and #%00000001
    beq not_moving_up
        ;moving_up:
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