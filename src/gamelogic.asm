.segment "ZEROPAGE"
    DECKSWAPPOS0: .res 1
    DECKSWAPPOS1: .res 1
    DECKTEMPCARDID: .res 1

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
    ldx #0
    loop_thru_clear_col_1:
        lda #0
        sta BOARDCOL1, x
        inx 
        cpx #20
        bne loop_thru_clear_col_1
    ldx #0
    loop_thru_clear_col_2:
        lda #0
        sta BOARDCOL2, x
        inx 
        cpx #20
        bne loop_thru_clear_col_2
    ldx #0
    loop_thru_clear_col_3:
        lda #0
        sta BOARDCOL3, x
        inx 
        cpx #20
        bne loop_thru_clear_col_3
    ldx #0
    loop_thru_clear_col_4:
        lda #0
        sta BOARDCOL4, x
        inx 
        cpx #20
        bne loop_thru_clear_col_4
    ldx #0
    loop_thru_clear_col_5:
        lda #0
        sta BOARDCOL5, x
        inx 
        cpx #20
        bne loop_thru_clear_col_5
    ldx #0
    loop_thru_clear_col_6:
        lda #0
        sta BOARDCOL6, x
        inx 
        cpx #20
        bne loop_thru_clear_col_6
    ldx #0
    loop_thru_clear_col_7:
        lda #0
        sta BOARDCOL7, x
        inx 
        cpx #20
        bne loop_thru_clear_col_7
    rts 

swap_2_deck_cards:
    ; swap 2 cards in the deck for shuffling
    ldx DECKSWAPPOS0
    lda DECK, x 
    sta DECKTEMPCARDID

    ldx DECKSWAPPOS1
    lda DECK, x 
    ldx DECKSWAPPOS0
    sta DECK, x 

    ldx DECKSWAPPOS1
    lda DECKTEMPCARDID
    sta DECK, x 

    rts 

generate_deck:
    ; generate an ordered deck
    ; diamonds
    lda #%10000001
    sta DECK
    lda #%10000010
    sta DECK+1
    lda #%10000011
    sta DECK+2
    lda #%10000100
    sta DECK+3
    lda #%10000101
    sta DECK+4
    lda #%10000110
    sta DECK+5
    lda #%10000111
    sta DECK+6
    lda #%10001000
    sta DECK+7
    lda #%10001001
    sta DECK+8
    lda #%10001010
    sta DECK+9
    lda #%10001011
    sta DECK+10
    lda #%10001100
    sta DECK+11
    lda #%10001101
    sta DECK+12

    ; hearts
    lda #%10100001
    sta DECK+13
    lda #%10100010
    sta DECK+14
    lda #%10100011
    sta DECK+15
    lda #%10100100
    sta DECK+16
    lda #%10100101
    sta DECK+17
    lda #%10100110
    sta DECK+18
    lda #%10100111
    sta DECK+19
    lda #%10101000
    sta DECK+20
    lda #%10101001
    sta DECK+21
    lda #%10101010
    sta DECK+22
    lda #%10101011
    sta DECK+23
    lda #%10101100
    sta DECK+24
    lda #%10101101
    sta DECK+25

    ; spades
    lda #%11000001
    sta DECK+26
    lda #%11000010
    sta DECK+27
    lda #%11000011
    sta DECK+28
    lda #%11000100
    sta DECK+29
    lda #%11000101
    sta DECK+30
    lda #%11000110
    sta DECK+31
    lda #%11000111
    sta DECK+32
    lda #%11001000
    sta DECK+33
    lda #%11001001
    sta DECK+34
    lda #%11001010
    sta DECK+35
    lda #%11001011
    sta DECK+36
    lda #%11001100
    sta DECK+37
    lda #%11001101
    sta DECK+38

    ; clubs
    lda #%11100001
    sta DECK+39
    lda #%11100010
    sta DECK+40
    lda #%11100011
    sta DECK+41
    lda #%11100100
    sta DECK+42
    lda #%11100101
    sta DECK+43
    lda #%11100110
    sta DECK+44
    lda #%11100111
    sta DECK+45
    lda #%11101000
    sta DECK+46
    lda #%11101001
    sta DECK+47
    lda #%11101010
    sta DECK+48
    lda #%11101011
    sta DECK+49
    lda #%11101100
    sta DECK+50
    lda #%11101101
    sta DECK+51

    rts 

deal_board:
    ; set ordered deck
    jsr generate_deck

    ; shuffle deck
    ldx #0
    deck_shuffle_loop:
        txa 
        pha 

        ; get random number modulus 52 and set to DECKSWAPPOS0
        jsr prng 
        sec 
        deal_board_mod_0:
            sbc #52
            bcs deal_board_mod_0
        adc #52
        sta DECKSWAPPOS0

        ; get random number modulus 52 and set to DECKSWAPPOS1
        jsr prng 
        sec 
        deal_board_mod_1:
            sbc #52
            bcs deal_board_mod_1
        adc #52
        sta DECKSWAPPOS1

        jsr swap_2_deck_cards

        pla 
        tax 
        inx 
        cpx #$FF
        bne deck_shuffle_loop

    ; set top deck index
    lda #51
    sta TOPDECKINDEX

    ; deal top cards of deck onto board columns
    ldx TOPDECKINDEX
    lda DECK, x 
    sec 
    sbc #%10000000      ; reveal last card of each column
    sta BOARDCOL1
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL2
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sec 
    sbc #%10000000      ; reveal last card of each column
    sta BOARDCOL2+1
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL3
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL3+1
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sec 
    sbc #%10000000      ; reveal last card of each column
    sta BOARDCOL3+2
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL4
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL4+1
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL4+2
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sec 
    sbc #%10000000      ; reveal last card of each column
    sta BOARDCOL4+3
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL5
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL5+1
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL5+2
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL5+3
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sec 
    sbc #%10000000      ; reveal last card of each column
    sta BOARDCOL5+4
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL6
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL6+1
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL6+2
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL6+3
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL6+4
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sec 
    sbc #%10000000      ; reveal last card of each column
    sta BOARDCOL6+5
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL7
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL7+1
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL7+2
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL7+3
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL7+4
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sta BOARDCOL7+5
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    ldx TOPDECKINDEX
    lda DECK, x 
    sec 
    sbc #%10000000      ; reveal last card of each column
    sta BOARDCOL7+6
    lda #0
    sta DECK, x 
    dex 
    stx TOPDECKINDEX

    rts 