.segment "ZEROPAGE"
    DECKSWAPPOS0: .res 1
    DECKSWAPPOS1: .res 1
    DECKTEMPCARDID: .res 1
    CURCLICKPOS: .res 1
    MOVEVALSTARTCARD: .res 1
    MOVEVALENDCARD: .res 1
    MOVEVALTEMPCARD: .res 1

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

    ; set draw pile index
    lda #$FF
    sta DRAWPILEINDEX

    ; set bottom deck index
    lda #0
    sta BOTTOMDECKINDEX

    ; draw the discard pile empty slots
    lda #1
    sta DRAWBGDPILE
    lda #0
    sta BGDPILEID
    jsr draw_bg_discard_pile

    lda #1
    sta BGDPILEID
    jsr draw_bg_discard_pile

    lda #2
    sta BGDPILEID
    jsr draw_bg_discard_pile

    lda #3
    sta BGDPILEID
    jsr draw_bg_discard_pile

    rts 

get_click_pos:
    ; set error value for click pos, if this doesn't change by done_get_click_pos then the current click pos is invalid
    lda #$FF
    sta CURCLICKPOS
    
    ; deck
    lda CURSORTILEXPOS
    cmp #$01
    bmi not_click_deck
        lda CURSORTILEXPOS
        cmp #$04
        bpl not_click_deck
            lda CURSORTILEYPOS
            cmp #$02
            bmi not_click_deck
                lda CURSORTILEYPOS
                cmp #$05
                bpl not_click_deck
                    ; deck clicked
                    lda #0
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_deck:

    ; discard piles
    ; discard pile 0
    lda CURSORTILEXPOS
    cmp #$10
    bmi not_click_discard_0
        lda CURSORTILEXPOS
        cmp #$13
        bpl not_click_discard_0
            lda CURSORTILEYPOS
            cmp #$02
            bmi not_click_discard_0
                lda CURSORTILEYPOS
                cmp #$05
                bpl not_click_discard_0
                    ; discard piles clicked
                    lda #145
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_discard_0:

    ; discard pile 1
    lda CURSORTILEXPOS
    cmp #$14
    bmi not_click_discard_1
        lda CURSORTILEXPOS
        cmp #$17
        bpl not_click_discard_1
            lda CURSORTILEYPOS
            cmp #$02
            bmi not_click_discard_1
                lda CURSORTILEYPOS
                cmp #$05
                bpl not_click_discard_1
                    ; discard piles clicked
                    lda #146
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_discard_1:

    ; discard pile 2
    lda CURSORTILEXPOS
    cmp #$18
    bmi not_click_discard_2
        lda CURSORTILEXPOS
        cmp #$1B
        bpl not_click_discard_2
            lda CURSORTILEYPOS
            cmp #$02
            bmi not_click_discard_2
                lda CURSORTILEYPOS
                cmp #$05
                bpl not_click_discard_2
                    ; discard piles clicked
                    lda #147
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_discard_2:

    ; discard pile 3
    lda CURSORTILEXPOS
    cmp #$1C
    bmi not_click_discard_3
        lda CURSORTILEXPOS
        cmp #$1F
        bpl not_click_discard_3
            lda CURSORTILEYPOS
            cmp #$02
            bmi not_click_discard_3
                lda CURSORTILEYPOS
                cmp #$05
                bpl not_click_discard_3
                    ; discard piles clicked
                    lda #148
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_discard_3:

    ; draw piles
    lda CURSORTILEXPOS
    cmp #$05
    bmi not_click_draw
        lda CURSORTILEXPOS
        cmp #$0E
        bpl not_click_draw
            lda CURSORTILEYPOS
            cmp #$02
            bmi not_click_draw
                lda CURSORTILEYPOS
                cmp #$05
                bpl not_click_draw
                    ; draw piles clicked
                    ; determine which draw pile was clicked and store that value in X
                    ;   we do this using a modified version of modulo
                    ldx #0
                    lda CURSORTILEXPOS
                    sec 
                    sbc #$05
                    sec 
                    draw_piles_mod:
                        inx 
                        sbc #$03
                        bcs draw_piles_mod
                    stx CURCLICKPOS     ; store the draw pile value
                    jmp done_get_click_pos
    not_click_draw:

    ; board columns
    ; board column 1
    lda CURSORTILEXPOS
    cmp #$01
    bmi not_click_col_1
        lda CURSORTILEXPOS
        cmp #$04
        bpl not_click_col_1
            lda CURSORTILEYPOS
            cmp #$06
            bmi not_click_col_1
                lda CURSORTILEYPOS
                cmp #$1A
                bpl not_click_col_1
                    ; column 1 clicked
                    lda CURSORTILEYPOS
                    sec 
                    sbc #1
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_col_1:

    ; board column 2
    lda CURSORTILEXPOS
    cmp #$05
    bmi not_click_col_2
        lda CURSORTILEXPOS
        cmp #$08
        bpl not_click_col_2
            lda CURSORTILEYPOS
            cmp #$06
            bmi not_click_col_2
                lda CURSORTILEYPOS
                cmp #$1A
                bpl not_click_col_2
                    ; column 1 clicked
                    lda CURSORTILEYPOS
                    sec 
                    sbc #1
                    clc 
                    adc #20
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_col_2:

    ; board column 3
    lda CURSORTILEXPOS
    cmp #$09
    bmi not_click_col_3
        lda CURSORTILEXPOS
        cmp #$0C
        bpl not_click_col_3
            lda CURSORTILEYPOS
            cmp #$06
            bmi not_click_col_3
                lda CURSORTILEYPOS
                cmp #$1A
                bpl not_click_col_3
                    ; column 1 clicked
                    lda CURSORTILEYPOS
                    sec 
                    sbc #1
                    clc 
                    adc #40
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_col_3:

    ; board column 4
    lda CURSORTILEXPOS
    cmp #$0D
    bmi not_click_col_4
        lda CURSORTILEXPOS
        cmp #$10
        bpl not_click_col_4
            lda CURSORTILEYPOS
            cmp #$06
            bmi not_click_col_4
                lda CURSORTILEYPOS
                cmp #$1A
                bpl not_click_col_4
                    ; column 1 clicked
                    lda CURSORTILEYPOS
                    sec 
                    sbc #1
                    clc 
                    adc #60
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_col_4:

    ; board column 5
    lda CURSORTILEXPOS
    cmp #$11
    bmi not_click_col_5
        lda CURSORTILEXPOS
        cmp #$14
        bpl not_click_col_5
            lda CURSORTILEYPOS
            cmp #$06
            bmi not_click_col_5
                lda CURSORTILEYPOS
                cmp #$1A
                bpl not_click_col_5
                    ; column 1 clicked
                    lda CURSORTILEYPOS
                    sec 
                    sbc #1
                    clc 
                    adc #80
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_col_5:

    ; board column 6
    lda CURSORTILEXPOS
    cmp #$15
    bmi not_click_col_6
        lda CURSORTILEXPOS
        cmp #$18
        bpl not_click_col_6
            lda CURSORTILEYPOS
            cmp #$06
            bmi not_click_col_6
                lda CURSORTILEYPOS
                cmp #$1A
                bpl not_click_col_6
                    ; column 1 clicked
                    lda CURSORTILEYPOS
                    sec 
                    sbc #1
                    clc 
                    adc #100
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_col_6:

    ; board column 7
    lda CURSORTILEXPOS
    cmp #$19
    bmi not_click_col_7
        lda CURSORTILEXPOS
        cmp #$1C
        bpl not_click_col_7
            lda CURSORTILEYPOS
            cmp #$06
            bmi not_click_col_7
                lda CURSORTILEYPOS
                cmp #$1A
                bpl not_click_col_7
                    ; column 1 clicked
                    lda CURSORTILEYPOS
                    sec 
                    sbc #1
                    clc 
                    adc #120
                    sta CURCLICKPOS
                    jmp done_get_click_pos
    not_click_col_7:

    done_get_click_pos:
    rts 

adjust_click_pos:
    ; skip processing if click position is not on a column
    lda CURCLICKPOS
    cmp #5
    bpl click_on_column
        cmp #145
        bmi click_on_column
            jmp done_adjusting_click_pos
    click_on_column:

    lda CURCLICKPOS
    cmp #25
    bpl click_not_column1
        ;click_column1:
        ;lda CURCLICKPOS
        sec 
        sbc #5
        beq adjust_column1_loop_break   ; skip adjusting if we clicked the top of the column
        tax 

        ; increase X by 1 if we are currently clicking the start position
        lda CURMOVEIND
        bne adjust_column1_move_check
            inx 
        adjust_column1_move_check:

        lda BOARDCOL1, x 
        bne click_not_column1   ; skip adjusting if where we clicked is not empty
        jmp adjust_column1_loop_cond
        adjust_column1_loop:
            lda CURCLICKPOS
            sec 
            sbc #1
            sta CURCLICKPOS
            dex 
            adjust_column1_loop_cond:
            cpx #0
            beq adjust_column1_loop_break   ; break out of loop if we reached top of column
            lda BOARDCOL1-1, x 
            beq adjust_column1_loop
        adjust_column1_loop_break:
        jmp done_adjusting_click_pos
    click_not_column1:

    lda CURCLICKPOS
    cmp #45
    bpl click_not_column2
        ;click_column2:
        ;lda CURCLICKPOS
        sec 
        sbc #25
        beq adjust_column2_loop_break   ; skip adjusting if we clicked the top of the column
        tax 

        ; increase X by 1 if we are currently clicking the start position
        lda CURMOVEIND
        bne adjust_column2_move_check
            inx 
        adjust_column2_move_check:

        lda BOARDCOL2, x 
        bne click_not_column2   ; skip adjusting if where we clicked is not empty
        jmp adjust_column2_loop_cond
        adjust_column2_loop:
            lda CURCLICKPOS
            sec 
            sbc #1
            sta CURCLICKPOS
            dex 
            adjust_column2_loop_cond:
            cpx #0
            beq adjust_column2_loop_break   ; break out of loop if we reached top of column
            lda BOARDCOL2-1, x 
            beq adjust_column2_loop
        adjust_column2_loop_break:
        jmp done_adjusting_click_pos
    click_not_column2:

    lda CURCLICKPOS
    cmp #65
    bpl click_not_column3
        ;click_column3:
        ;lda CURCLICKPOS
        sec 
        sbc #45
        beq adjust_column3_loop_break   ; skip adjusting if we clicked the top of the column
        tax 

        ; increase X by 1 if we are currently clicking the start position
        lda CURMOVEIND
        bne adjust_column3_move_check
            inx 
        adjust_column3_move_check:

        lda BOARDCOL3, x 
        bne click_not_column3   ; skip adjusting if where we clicked is not empty
        jmp adjust_column3_loop_cond
        adjust_column3_loop:
            lda CURCLICKPOS
            sec 
            sbc #1
            sta CURCLICKPOS
            dex 
            adjust_column3_loop_cond:
            cpx #0
            beq adjust_column3_loop_break   ; break out of loop if we reached top of column
            lda BOARDCOL3-1, x 
            beq adjust_column3_loop
        adjust_column3_loop_break:
        jmp done_adjusting_click_pos
    click_not_column3:

    lda CURCLICKPOS
    cmp #85
    bpl click_not_column4
        ;click_column4:
        ;lda CURCLICKPOS
        sec 
        sbc #65
        beq adjust_column4_loop_break   ; skip adjusting if we clicked the top of the column
        tax 

        ; increase X by 1 if we are currently clicking the start position
        lda CURMOVEIND
        bne adjust_column4_move_check
            inx 
        adjust_column4_move_check:

        lda BOARDCOL4, x 
        bne click_not_column4   ; skip adjusting if where we clicked is not empty
        jmp adjust_column4_loop_cond
        adjust_column4_loop:
            lda CURCLICKPOS
            sec 
            sbc #1
            sta CURCLICKPOS
            dex 
            adjust_column4_loop_cond:
            cpx #0
            beq adjust_column4_loop_break   ; break out of loop if we reached top of column
            lda BOARDCOL4-1, x 
            beq adjust_column4_loop
        adjust_column4_loop_break:
        jmp done_adjusting_click_pos
    click_not_column4:

    lda CURCLICKPOS
    cmp #105
    bpl click_not_column5
        ;click_column5:
        ;lda CURCLICKPOS
        sec 
        sbc #85
        beq adjust_column5_loop_break   ; skip adjusting if we clicked the top of the column
        tax 

        ; increase X by 1 if we are currently clicking the start position
        lda CURMOVEIND
        bne adjust_column5_move_check
            inx 
        adjust_column5_move_check:

        lda BOARDCOL5, x 
        bne click_not_column5   ; skip adjusting if where we clicked is not empty
        jmp adjust_column5_loop_cond
        adjust_column5_loop:
            lda CURCLICKPOS
            sec 
            sbc #1
            sta CURCLICKPOS
            dex 
            adjust_column5_loop_cond:
            cpx #0
            beq adjust_column5_loop_break   ; break out of loop if we reached top of column
            lda BOARDCOL5-1, x 
            beq adjust_column5_loop
        adjust_column5_loop_break:
        jmp done_adjusting_click_pos
    click_not_column5:

    lda CURCLICKPOS
    cmp #125
    bpl click_not_column6
        ;click_column6:
        ;lda CURCLICKPOS
        sec 
        sbc #105
        beq adjust_column6_loop_break   ; skip adjusting if we clicked the top of the column
        tax 

        ; increase X by 1 if we are currently clicking the start position
        lda CURMOVEIND
        bne adjust_column6_move_check
            inx 
        adjust_column6_move_check:

        lda BOARDCOL6, x 
        bne click_not_column6   ; skip adjusting if where we clicked is not empty
        jmp adjust_column6_loop_cond
        adjust_column6_loop:
            lda CURCLICKPOS
            sec 
            sbc #1
            sta CURCLICKPOS
            dex 
            adjust_column6_loop_cond:
            cpx #0
            beq adjust_column6_loop_break   ; break out of loop if we reached top of column
            lda BOARDCOL6-1, x 
            beq adjust_column6_loop
        adjust_column6_loop_break:
        jmp done_adjusting_click_pos
    click_not_column6:

    lda CURCLICKPOS
    cmp #145
    bpl click_not_column7
        ;click_column7:
        ;lda CURCLICKPOS
        sec 
        sbc #125
        beq adjust_column7_loop_break   ; skip adjusting if we clicked the top of the column
        tax 

        ; increase X by 1 if we are currently clicking the start position
        lda CURMOVEIND
        bne adjust_column7_move_check
            inx 
        adjust_column7_move_check:

        lda BOARDCOL7, x 
        bne click_not_column7   ; skip adjusting if where we clicked is not empty
        jmp adjust_column7_loop_cond
        adjust_column7_loop:
            lda CURCLICKPOS
            sec 
            sbc #1
            sta CURCLICKPOS
            dex 
            adjust_column7_loop_cond:
            cpx #0
            beq adjust_column7_loop_break   ; break out of loop if we reached top of column
            lda BOARDCOL7-1, x 
            beq adjust_column7_loop
        adjust_column7_loop_break:
        jmp done_adjusting_click_pos
    click_not_column7:

    done_adjusting_click_pos:
    rts 

; get the cursor 1 position from current click position
get_cursor_1_pos:
    lda CURCLICKPOS
    cmp #$FF
    bne cursor_at_a_card
        lda #0
        sta MOVECURSORXPOS
        sta MOVECURSORYPOS

        jmp done_get_cursor_1_pos
    cursor_at_a_card:

    lda CURCLICKPOS
    cmp #1
    bmi cursor_not_at_draw_piles
        cmp #4
        bpl cursor_not_at_draw_piles
            ;cursor_at_draw_piles:
            lda #$10
            sta MOVECURSORYPOS
            lda #$28
            sta MOVECURSORXPOS

            jmp done_get_cursor_1_pos
    cursor_not_at_draw_piles:

    lda CURCLICKPOS
    cmp #145
    bne cursor_not_at_discard_pile_0
        ;cursor_at_discard_pile_0:
        lda #$10
        sta MOVECURSORYPOS
        lda #$80
        sta MOVECURSORXPOS

        jmp done_get_cursor_1_pos
    cursor_not_at_discard_pile_0:

    lda CURCLICKPOS
    cmp #146
    bne cursor_not_at_discard_pile_1
        ;cursor_at_discard_pile_1:
        lda #$10
        sta MOVECURSORYPOS
        lda #$A0
        sta MOVECURSORXPOS

        jmp done_get_cursor_1_pos
    cursor_not_at_discard_pile_1:

    lda CURCLICKPOS
    cmp #147
    bne cursor_not_at_discard_pile_2
        ;cursor_at_discard_pile_2:
        lda #$10
        sta MOVECURSORYPOS
        lda #$C0
        sta MOVECURSORXPOS

        jmp done_get_cursor_1_pos
    cursor_not_at_discard_pile_2:

    lda CURCLICKPOS
    cmp #148
    bne cursor_not_at_discard_pile_3
        ;cursor_at_discard_pile_3:
        lda #$10
        sta MOVECURSORYPOS
        lda #$E0
        sta MOVECURSORXPOS

        jmp done_get_cursor_1_pos
    cursor_not_at_discard_pile_3:

    lda CURCLICKPOS
    cmp #5
    bmi cursor_not_at_column_1
        cmp #25
        bpl cursor_not_at_column_1
            lda #$08
            sta MOVECURSORXPOS
            lda CURCLICKPOS
            sec 
            sbc #5
            asl 
            asl 
            asl 
            clc 
            adc #$30
            sta MOVECURSORYPOS

            jmp done_get_cursor_1_pos
    cursor_not_at_column_1:

    lda CURCLICKPOS
    cmp #25
    bmi cursor_not_at_column_2
        cmp #45
        bpl cursor_not_at_column_2
            lda #$28
            sta MOVECURSORXPOS
            lda CURCLICKPOS
            sec 
            sbc #25
            asl 
            asl 
            asl 
            clc 
            adc #$30
            sta MOVECURSORYPOS

            jmp done_get_cursor_1_pos
    cursor_not_at_column_2:

    lda CURCLICKPOS
    cmp #45
    bmi cursor_not_at_column_3
        cmp #65
        bpl cursor_not_at_column_3
            lda #$48
            sta MOVECURSORXPOS
            lda CURCLICKPOS
            sec 
            sbc #45
            asl 
            asl 
            asl 
            clc 
            adc #$30
            sta MOVECURSORYPOS

            jmp done_get_cursor_1_pos
    cursor_not_at_column_3:

    lda CURCLICKPOS
    cmp #65
    bmi cursor_not_at_column_4
        cmp #85
        bpl cursor_not_at_column_4
            lda #$68
            sta MOVECURSORXPOS
            lda CURCLICKPOS
            sec 
            sbc #65
            asl 
            asl 
            asl 
            clc 
            adc #$30
            sta MOVECURSORYPOS

            jmp done_get_cursor_1_pos
    cursor_not_at_column_4:

    lda CURCLICKPOS
    cmp #85
    bmi cursor_not_at_column_5
        cmp #105
        bpl cursor_not_at_column_5
            lda #$88
            sta MOVECURSORXPOS
            lda CURCLICKPOS
            sec 
            sbc #85
            asl 
            asl 
            asl 
            clc 
            adc #$30
            sta MOVECURSORYPOS

            jmp done_get_cursor_1_pos
    cursor_not_at_column_5:

    lda CURCLICKPOS
    cmp #105
    bmi cursor_not_at_column_6
        cmp #125
        bpl cursor_not_at_column_6
            lda #$A8
            sta MOVECURSORXPOS
            lda CURCLICKPOS
            sec 
            sbc #105
            asl 
            asl 
            asl 
            clc 
            adc #$30
            sta MOVECURSORYPOS

            jmp done_get_cursor_1_pos
    cursor_not_at_column_6:

    lda CURCLICKPOS
    cmp #125
    bmi cursor_not_at_column_7
        cmp #145
        bpl cursor_not_at_column_7
            lda #$C8
            sta MOVECURSORXPOS
            lda CURCLICKPOS
            sec 
            sbc #125
            asl 
            asl 
            asl 
            clc 
            adc #$30
            sta MOVECURSORYPOS

            jmp done_get_cursor_1_pos
    cursor_not_at_column_7:

    done_get_cursor_1_pos:
    rts 

validate_move:
    lda #0
    sta MOVEVALIDATION  ; move is valid unless proven otherwise
    sta MOVEVALSTARTCARD
    sta MOVEVALENDCARD
    sta MOVEVALTEMPCARD

    ; validate move end not on draw piles or deck
    lda CURMOVEEND
    cmp #0
    bmi move_end_not_draw_piles
        cmp #4
        bpl move_end_not_draw_piles
            ;move_end_is_draw_piles:
            lda #1
            sta MOVEVALIDATION
            jmp done_validate_move
    move_end_not_draw_piles:

    ; get start card
    lda CURMOVESTART
    cmp #1
    beq validation_start_not_on_col
        cmp #2
        beq validation_start_not_on_col
            cmp #3
            beq validation_start_not_on_col
                jmp validation_start_on_col
            validation_start_not_on_col:
                ldx DRAWPILEINDEX
                lda DECK, x 
                and #%01111111
                sta MOVEVALSTARTCARD
                jmp done_get_move_start_card
    validation_start_on_col:
        sec 
        sbc #5
        ldx #0
        validation_start_card_loop:
            inx 
            sec 
            sbc #20
            bcs validation_start_card_loop
        clc 
        adc #20
        tay 
        ; X should now correspond to column (i.e. if X == 3, then we are dealing with column 3)
        ; Y should now hold the card offset of X column

        txa 
        cmp #1
        bne validation_start_col_not_1
            lda BOARDCOL1, y
            sta MOVEVALSTARTCARD
            jmp done_get_move_start_card
        validation_start_col_not_1:
        cmp #2
        bne validation_start_col_not_2
            lda BOARDCOL2, y
            sta MOVEVALSTARTCARD
            jmp done_get_move_start_card
        validation_start_col_not_2:
        cmp #3
        bne validation_start_col_not_3
            lda BOARDCOL3, y
            sta MOVEVALSTARTCARD
            jmp done_get_move_start_card
        validation_start_col_not_3:
        cmp #4
        bne validation_start_col_not_4
            lda BOARDCOL4, y
            sta MOVEVALSTARTCARD
            jmp done_get_move_start_card
        validation_start_col_not_4:
        cmp #5
        bne validation_start_col_not_5
            lda BOARDCOL5, y
            sta MOVEVALSTARTCARD
            jmp done_get_move_start_card
        validation_start_col_not_5:
        cmp #6
        bne validation_start_col_not_6
            lda BOARDCOL6, y
            sta MOVEVALSTARTCARD
            jmp done_get_move_start_card
        validation_start_col_not_6:
        cmp #7
        bne validation_start_col_not_7
            lda BOARDCOL7, y
            sta MOVEVALSTARTCARD
            jmp done_get_move_start_card
        validation_start_col_not_7:
            ; get the start card from discard piles
            lda DISCARDPILES, y
            sta MOVEVALSTARTCARD
    done_get_move_start_card:

    ; get end card
    lda CURMOVEEND
    cmp #1
    beq validation_end_not_on_col
        cmp #2
        beq validation_end_not_on_col
            cmp #3
            beq validation_end_not_on_col
                jmp validation_end_on_col
            validation_end_not_on_col:
                ldx DRAWPILEINDEX
                lda DECK, x 
                and #%01111111
                sta MOVEVALENDCARD
                jmp done_get_move_end_card
    validation_end_on_col:
        sec 
        sbc #5
        ldx #0
        validation_end_card_loop:
            inx 
            sec 
            sbc #20
            bcs validation_end_card_loop
        clc 
        adc #20
        tay 
        cpy #0
        beq validation_end_on_top_col
            dey 
        validation_end_on_top_col:
        ; X should now correspond to column (i.e. if X == 3, then we are dealing with column 3)
        ; Y should now hold the card offset of X column

        txa 
        cmp #1
        bne validation_end_col_not_1
            lda BOARDCOL1, y
            sta MOVEVALENDCARD
            jmp done_get_move_end_card
        validation_end_col_not_1:
        cmp #2
        bne validation_end_col_not_2
            lda BOARDCOL2, y
            sta MOVEVALENDCARD
            jmp done_get_move_end_card
        validation_end_col_not_2:
        cmp #3
        bne validation_end_col_not_3
            lda BOARDCOL3, y
            sta MOVEVALENDCARD
            jmp done_get_move_end_card
        validation_end_col_not_3:
        cmp #4
        bne validation_end_col_not_4
            lda BOARDCOL4, y
            sta MOVEVALENDCARD
            jmp done_get_move_end_card
        validation_end_col_not_4:
        cmp #5
        bne validation_end_col_not_5
            lda BOARDCOL5, y
            sta MOVEVALENDCARD
            jmp done_get_move_end_card
        validation_end_col_not_5:
        cmp #6
        bne validation_end_col_not_6
            lda BOARDCOL6, y
            sta MOVEVALENDCARD
            jmp done_get_move_end_card
        validation_end_col_not_6:
        cmp #7
        bne validation_end_col_not_7
            lda BOARDCOL7, y
            sta MOVEVALENDCARD
            jmp done_get_move_end_card
        validation_end_col_not_7:
            ; get the end card from discard piles
            iny 
            lda DISCARDPILES, y
            sta MOVEVALENDCARD
    done_get_move_end_card:

    ; validate move start card is not hidden
    lda MOVEVALSTARTCARD
    and #%10000000
    beq validation_move_start_not_hidden
        lda #1
        sta MOVEVALIDATION
        jmp done_validate_move
    validation_move_start_not_hidden:

    ; check if move end is on discard piles
    lda CURMOVEEND
    cmp #145
    bmi move_end_not_discard_piles
        cmp #149
        bpl move_end_not_discard_piles
            ;move_end_is_discard_piles:
            ; validate move start card is 1 more than corresponding discard pile card
            lda MOVEVALSTARTCARD
            and #%00011111
            sec 
            sbc #1
            sta MOVEVALTEMPCARD
            lda MOVEVALSTARTCARD
            and #%01100000
            lsr 
            lsr 
            lsr 
            lsr 
            lsr 
            tax 
            lda DISCARDPILES, x
            and #%00011111
            cmp MOVEVALTEMPCARD
            beq move_end_not_discard_piles
                lda #1
                sta MOVEVALIDATION
                jmp done_validate_move
    move_end_not_discard_piles:

    ; check if move end card is on a column
    lda CURMOVEEND
    cmp #5
    bmi done_validate_move
        cmp #145
        bpl done_validate_move
            ; check if move start card is a king
            lda MOVEVALSTARTCARD
            and #%00011111
            cmp #13
            bne move_start_not_king
                ;move_start_is_king:
                ; validate move end card is an empty card slot
                lda MOVEVALENDCARD
                beq validation_end_card_is_empty
                    lda #1
                    sta MOVEVALIDATION
                    jmp done_validate_move
                validation_end_card_is_empty:
                jmp done_validate_move
            move_start_not_king:
                ; validate move start card is value 1 less than move end card and is opposite color
                lda MOVEVALSTARTCARD
                and #%00011111
                clc 
                adc #1
                sta MOVEVALTEMPCARD
                lda MOVEVALENDCARD
                and #%00011111
                cmp MOVEVALTEMPCARD
                beq validation_start_card_is_1_less
                    lda #1
                    sta MOVEVALIDATION
                    jmp done_validate_move
                validation_start_card_is_1_less:

                lda MOVEVALSTARTCARD
                and #%01000000
                sta MOVEVALTEMPCARD
                lda MOVEVALENDCARD
                and #%01000000
                eor MOVEVALTEMPCARD
                bne validation_end_card_is_off_color
                    lda #1
                    sta MOVEVALIDATION
                    jmp done_validate_move
                validation_end_card_is_off_color:

    done_validate_move:
    rts 