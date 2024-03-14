.segment "ZEROPAGE"
    DRAWBGCARD: .res 1
    BGCARDID: .res 1
    BGCARDTILEX: .res 1
    BGCARDTILEY: .res 1
    BGCARDTILENUM: .res 2
    BGCARDHBYTE: .res 1
    BGCARDLBYTE: .res 1
    DRAWBGDPILE: .res 1
    BGDPILEID: .res 1       ; #$00 == diamonds, #$01 == hearts, #$02 == spades, #$03 == clubs
    BGDPILEHBYTE: .res 1
    BGDPILELBYTE: .res 1
    MOVETEMPCARDID: .res 13
    MOVECURSORXPOS: .res 1
    MOVECURSORYPOS: .res 1

.segment "CODE"

draw_sprites:
    ; wait for vblank
    bit $2002
    vblank_wait:
        bit $2002
        bpl vblank_wait
    
    ; draw all sprites to screen
    lda #$02
    sta $4014
    
    rts 

draw_cursor_0:
    lda CURSORYPOS
    sta $0200       ; cursor Y pos

    lda #$00
    sta $0201       ; cursor tile number

    lda #%00000000
    sta $0202       ; cursor attributes

    lda CURSORXPOS
    sta $0203       ; cursor X pos

    jsr draw_sprites

    rts 

erase_cursor_0:
    lda #$FF
    sta $0200

    jsr draw_sprites

    rts 

draw_cursor_1:
    lda MOVECURSORYPOS
    sta $0204

    lda #$01
    sta $0205

    lda #%00000000
    sta $0206

    lda MOVECURSORXPOS
    sta $0207

    jsr draw_sprites

    rts 

erase_cursor_1:
    lda #$FF
    sta $0204

    jsr draw_sprites

    rts 

draw_bg_discard_pile:
    ; wait for vblank
    bit $2002
    vblank_wait_bg_dpile:
        bit $2002
        bpl vblank_wait_bg_dpile

    ; disable sprites and background rendering
    lda #%00000000
    sta $2001

    ; get the high and low byte of the discard pile position\
    lda #$20
    sta BGDPILEHBYTE
    lda BGDPILEID
    asl 
    asl 
    clc 
    adc #$50
    sta BGDPILELBYTE

    ; draw the discard pile
    lda DRAWBGDPILE
    bne draw_dpile_on_bg
        jmp erase_dpile_from_bg
    draw_dpile_on_bg:
        ; draw top
        lda $2002
        lda BGDPILEHBYTE
        sta $2006
        lda BGDPILELBYTE
        sta $2006

        lda #$76
        sta $2007
        lda #$77
        sta $2007
        lda #$78
        sta $2007

        ; draw middle
        lda BGDPILELBYTE
        clc 
        adc #$20
        sta BGDPILELBYTE
        lda BGDPILEHBYTE
        adc #0
        sta BGDPILEHBYTE

        lda $2002
        lda BGDPILEHBYTE
        sta $2006
        lda BGDPILELBYTE
        sta $2006

        lda #$86
        sta $2007
        lda BGDPILEID
        asl 
        clc 
        adc #$58
        sta $2007
        clc 
        adc #1
        sta $2007

        ; draw bottom
        lda BGDPILELBYTE
        clc 
        adc #$20
        sta BGDPILELBYTE
        lda BGDPILEHBYTE
        adc #0
        sta BGDPILEHBYTE

        lda $2002
        lda BGDPILEHBYTE
        sta $2006
        lda BGDPILELBYTE
        sta $2006

        lda #$96
        sta $2007
        lda BGDPILEID
        asl 
        clc 
        adc #$68
        sta $2007
        clc 
        adc #1
        sta $2007

        jmp done_drawing_bg_dpile
    erase_dpile_from_bg:
        ; draw top
        lda $2002
        lda BGDPILEHBYTE
        sta $2006
        lda BGDPILELBYTE
        sta $2006

        lda #$2F
        sta $2007
        sta $2007
        sta $2007

        ; draw middle
        lda BGDPILELBYTE
        clc 
        adc #$20
        sta BGDPILELBYTE
        lda BGDPILEHBYTE
        adc #0
        sta BGDPILEHBYTE

        lda $2002
        lda BGDPILEHBYTE
        sta $2006
        lda BGDPILELBYTE
        sta $2006

        lda #$2F
        sta $2007
        sta $2007
        sta $2007

        ; draw bottom
        lda BGDPILELBYTE
        clc 
        adc #$20
        sta BGDPILELBYTE
        lda BGDPILEHBYTE
        adc #0
        sta BGDPILEHBYTE

        lda $2002
        lda BGDPILEHBYTE
        sta $2006
        lda BGDPILELBYTE
        sta $2006

        lda #$2F
        sta $2007
        sta $2007
        sta $2007

    done_drawing_bg_dpile:
    ; enable sprites and background rendering
    lda #%00011110
    sta $2001

    ; reset scrolling
    lda #$00
    sta $2005
    sta $2005

    rts 

draw_bg_card:
    ; wait for vblank
    bit $2002
    vblank_wait_bg:
        bit $2002
        bpl vblank_wait_bg

    ; disable sprites and background rendering
    lda #%00000000
    sta $2001

    ; get the high and low byte of the card position
    ; BGCARDTILENUM == BGCARDTILEX + (BGCARDTILEY * 32)

    ; BGCARDTILEY * 32
    lda #0
    ldx #8
    bg_card_mult_loop:
        lsr BGCARDTILEY
        bcc bg_card_mult_no_add
        clc 
        adc #32
    bg_card_mult_no_add:
        ror A
        ror BGCARDTILENUM
        dex 
        bne bg_card_mult_loop
    sta BGCARDTILENUM+1
    
    ; result + BGCARDTILEX
    lda BGCARDTILENUM
    clc 
    adc BGCARDTILEX
    sta BGCARDTILENUM
    lda BGCARDTILENUM+1
    adc #0
    sta BGCARDTILENUM+1

    ; store result in high and low byte
    lda BGCARDTILENUM+1
    clc 
    adc #$20    ; and #$20 to high byte
    sta BGCARDHBYTE
    lda BGCARDTILENUM
    sta BGCARDLBYTE

    ; skip drawing the card if the card ID is #$00
    lda BGCARDID
    bne dont_skip_bg_card
        jmp done_drawing_bg_card
    dont_skip_bg_card:

    ; draw the card
    lda DRAWBGCARD
    bne draw_on_bg
        jmp erase_from_bg
    draw_on_bg:
        ; draw top of card
        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        sta $2006

        lda BGCARDID
        and #%10000000
        bne top_back
            lda BGCARDID
            and #%01000000
            bne black_card
            red_card:
                lda BGCARDID
                and #%00011111
                clc 
                adc #$30    ; card value
                sta $2007
                lda #$30
                sta $2007
                lda BGCARDID
                and #%00100000
                lsr 
                lsr 
                lsr 
                lsr 
                lsr 
                clc 
                adc #$3E
                sta $2007
                jmp top_done
            black_card:
                lda BGCARDID
                and #%00011111
                clc 
                adc #$40    ; card value
                sta $2007
                lda #$40
                sta $2007
                lda BGCARDID
                and #%00100000
                lsr 
                lsr 
                lsr 
                lsr 
                lsr 
                clc 
                adc #$4E
                sta $2007
            top_done:
            jmp top_back_done
        top_back:
            lda #$73
            sta $2007
            lda #$74
            sta $2007
            lda #$75
            sta $2007
        top_back_done:

        ; draw middle of card
        lda BGCARDLBYTE
        clc 
        adc #$20
        sta BGCARDLBYTE
        lda BGCARDHBYTE
        adc #0
        sta BGCARDHBYTE

        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        sta $2006

        lda BGCARDID
        and #%10000000
        bne middle_back
            lda #$80
            sta $2007
            lda BGCARDID
            and #%01100000
            lsr 
            lsr 
            lsr 
            lsr 
            clc 
            adc #$50    ; suite top-left
            sta $2007
            clc 
            adc #1    ; suite top-right
            sta $2007
            jmp middle_back_done
        middle_back:
            lda #$83
            sta $2007
            lda #$84
            sta $2007
            lda #$85
            sta $2007
        middle_back_done:

        ; draw bottom of card
        lda BGCARDLBYTE
        clc 
        adc #$20
        sta BGCARDLBYTE
        lda BGCARDHBYTE
        adc #0
        sta BGCARDHBYTE

        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        sta $2006

        lda BGCARDID
        and #%10000000
        bne bottom_back
            lda #$90 
            sta $2007
            lda BGCARDID
            and #%01100000
            lsr 
            lsr 
            lsr 
            lsr 
            clc 
            adc #$60    ; suite bottom-left
            sta $2007
            clc 
            adc #1      ; suite bottom-right
            sta $2007
            jmp bottom_back_done
        bottom_back:
            lda #$93
            sta $2007
            lda #$94
            sta $2007
            lda #$95
            sta $2007
        bottom_back_done:
        jmp done_drawing_bg_card
    erase_from_bg:
        ; erase top of card
        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        sta $2006

        lda #$2F
        sta $2007
        sta $2007
        sta $2007

        ; erase middle of card
        lda BGCARDLBYTE
        clc 
        adc #$20
        sta BGCARDLBYTE
        lda BGCARDHBYTE
        adc #0
        sta BGCARDHBYTE

        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        sta $2006

        lda #$2F
        sta $2007
        sta $2007
        sta $2007
        
        ; erase bottom of card
        lda BGCARDLBYTE
        clc 
        adc #$20
        sta BGCARDLBYTE
        lda BGCARDHBYTE
        adc #0
        sta BGCARDHBYTE

        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        sta $2006

        lda #$2F
        sta $2007
        sta $2007
        sta $2007
    
    done_drawing_bg_card:
    ; enable sprites and background rendering
    lda #%00011110
    sta $2001

    ; reset scrolling
    lda #$00
    sta $2005
    sta $2005

    rts 

; This subroutine handles drawing the current move as well as moving the relevant cards around!
make_move:
    ; handle card in start position
    ; move from deck
    lda CURMOVESTART
    beq move_from_deck
        jmp move_not_from_deck
    move_from_deck:
        lda TOPDECKINDEX
        cmp #$FF
        bne move_deck_not_empty
            ;move_deck_empty:
            ; update draw pile index
            lda #$FF
            sta DRAWPILEINDEX

            ; set top card index back to top card of deck
            lda #51
            sta TOPDECKINDEX
            top_deck_index_loop:
                ldx TOPDECKINDEX
                dex 
                stx TOPDECKINDEX

                cpx #0
                bne top_deck_index_loop_not_end
                    lda #$FF
                    sta TOPDECKINDEX
                    jmp done_making_move
                top_deck_index_loop_not_end:

                lda DECK, x 
                beq top_deck_index_loop
            
            ; redraw the deck
            lda #1
            sta DRAWBGCARD
            ldx TOPDECKINDEX
            lda DECK, x 
            sta BGCARDID
            lda #$01
            sta BGCARDTILEX
            lda #$02
            sta BGCARDTILEY
            jsr draw_bg_card

            ; erase the draw pile
            lda #0
            sta DRAWBGCARD
            lda #$05
            sta BGCARDTILEX
            lda #$02
            sta BGCARDTILEY
            jsr draw_bg_card

            ; increment shuffle counter
            lda SHUFFLES
            beq not_first_shuffle
                ; subtract score penalty
                lda #%10011110
                sta SCORECHANGE
                jsr update_score
            not_first_shuffle:
            ldx SHUFFLES
            inx 
            stx SHUFFLES

            jmp done_making_move
        move_deck_not_empty:
            ; update draw pile index
            lda TOPDECKINDEX
            sta DRAWPILEINDEX

            ; store top card of deck into temp slot
            ldx TOPDECKINDEX
            lda DECK, x 
            sec 
            sbc #%10000000  ; make sure not to show back of card now
            sta MOVETEMPCARDID

            lda TOPDECKINDEX
            cmp BOTTOMDECKINDEX
            bne move_deck_not_last_card
                ;move_deck_last_card:
                lda #0
                sta DRAWBGCARD
                lda #$01
                sta BGCARDTILEX
                lda #$02
                sta BGCARDTILEY
                jsr draw_bg_card
                
                ; update TOPDECKINDEX with empty deck index
                lda #$FF
                sta TOPDECKINDEX

                jmp handle_end_card
            move_deck_not_last_card:
                ; update TOPDECKINDEX with new top of deck
                next_top_deck_index_loop:
                    ldx TOPDECKINDEX
                    dex 
                    stx TOPDECKINDEX

                    lda DECK, x 
                    beq next_top_deck_index_loop

                jmp handle_end_card
    move_not_from_deck:

    ; move from draw pile
    lda CURMOVESTART
    cmp #1
    bne move_not_from_draw_pile
        ;move_from_draw_pile:
        ; skip taking from draw pile if draw pile is empty
        lda DRAWPILEINDEX
        cmp #$FF
        beq move_not_from_draw_pile
            ; add score bonus if CURMOVEEND is on a column
            lda CURMOVEEND
            cmp #145
            bpl no_score_from_draw_pile
                lda #%00000101
                sta SCORECHANGE
                jsr update_score
            no_score_from_draw_pile:

            ; store draw pile card into temp slot
            ldx DRAWPILEINDEX
            lda DECK, x 
            sec 
            sbc #%10000000  ; make sure not to show back of card now
            sta MOVETEMPCARDID

            ; erase draw pile card from deck
            ldx DRAWPILEINDEX
            lda #0
            sta DECK, x 

            lda DRAWPILEINDEX
            cmp BOTTOMDECKINDEX
            bne skip_update_bottom_deck_index
                ; update BOTTOMDECKINDEX with new bottom of deck
                next_bottom_deck_index_loop:
                    ldx BOTTOMDECKINDEX
                    inx 
                    stx BOTTOMDECKINDEX

                    lda DECK, x 
                    beq next_bottom_deck_index_loop
            skip_update_bottom_deck_index:


            ; move draw pile index back 1 card
            next_draw_pile_index_loop:
                ldx DRAWPILEINDEX
                inx 
                stx DRAWPILEINDEX
                
                ; skip drawing a next card if there are no more cards in the draw pile now
                lda DRAWPILEINDEX
                cmp #51
                beq move_erase_draw_pile

                ldx DRAWPILEINDEX
                lda DECK, x 
                beq next_draw_pile_index_loop

            ; draw the new draw pile card from index
            lda #1
            sta DRAWBGCARD
            ldx DRAWPILEINDEX
            lda DECK, x 
            sec 
            sbc #%10000000  ; make sure not to show back of card now
            sta BGCARDID
            lda #$05
            sta BGCARDTILEX
            lda #$02
            sta BGCARDTILEY
            jsr draw_bg_card

            ; don't erase draw pile after just drawing to draw pile
            jmp handle_end_card
            move_erase_draw_pile:
                lda #0
                sta DRAWBGCARD
                lda #$05
                sta BGCARDTILEX
                lda #$02
                sta BGCARDTILEY
                jsr draw_bg_card

                jmp handle_end_card
    move_not_from_draw_pile:

    ; move from discard piles
    lda CURMOVESTART
    cmp #145
    bmi move_not_from_discard_piles
        lda CURMOVESTART
        cmp #149
        bpl move_not_from_discard_piles
            ;move_from_discard_piles:
            ; subtract score penalty
            lda #%10001111
            sta SCORECHANGE
            jsr update_score

            ; store which discard pile was clicked into X
            lda CURMOVESTART
            sec 
            sbc #145
            tax 

            ; store discard pile card into temp slot
            lda DISCARDPILES, x 
            sta MOVETEMPCARDID

            ; decrement the discard pile card, if discard pile card was an ace draw the empty discard pile slot instead
            lda DISCARDPILES, x 
            and #%00011111
            cmp #1
            bne discard_pile_not_ace
                ;discard_pile_is_ace:
                lda #0
                sta DISCARDPILES, x

                txa 
                sta BGDPILEID
                lda #1
                sta DRAWBGDPILE
                jsr draw_bg_discard_pile

                jmp handle_end_card
            discard_pile_not_ace:
                lda DISCARDPILES, x
                sec 
                sbc #1
                sta DISCARDPILES, x 

                sta BGCARDID
                lda #1 
                sta DRAWBGCARD
                txa 
                asl 
                asl 
                clc 
                adc #$10
                sta BGCARDTILEX
                lda #$02
                sta BGCARDTILEY
                jsr draw_bg_card
            
            jmp handle_end_card
    move_not_from_discard_piles:

    ; move from columns
    ; move from column 1
    lda CURMOVESTART
    cmp #5
    bmi move_not_from_column1
        lda CURMOVESTART
        cmp #25
        bpl move_not_from_column1
            ;move_from_column1:
            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #5
            tax 

            ldy #0
            move_stack_from_column1_loop:
                ; store column card into temp slot
                lda BOARDCOL1, x 
                sta MOVETEMPCARDID, y

                ; remove column card from column
                lda #0
                sta BOARDCOL1, x 

                ; erase column card from column
                lda #0
                sta DRAWBGCARD
                lda #$01
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next card slot is empty OR Y == 13
                inx 
                iny 
                cpy #13
                beq move_stack_from_column1_loop_break
                lda BOARDCOL1, x 
                beq move_stack_from_column1_loop_break
                ; otherwise continue looping
                jmp move_stack_from_column1_loop
            move_stack_from_column1_loop_break:

            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #5
            tax 

            ; get the card below column card if any
            dex 
            cpx #$FF
            bne cont_move_from_column1
                jmp handle_end_card     ; skip rest of move from logic if no card is below column card
            cont_move_from_column1:

            ; flip the card below if it is hidden
            lda BOARDCOL1, x 
            cmp #%10000000
            bmi column1_below_card_already_shown
                sec 
                sbc #%10000000
                sta BOARDCOL1, x 

                txa 
                pha 
                lda #%00000101
                sta SCORECHANGE
                jsr update_score
                pla 
                tax 
            column1_below_card_already_shown:

            ; redraw the card below if there is one
            lda #1
            sta DRAWBGCARD
            lda BOARDCOL1, x 
            sta BGCARDID
            lda #$01
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            jsr draw_bg_card

            jmp handle_end_card
    move_not_from_column1:

    ; move from column 2
    lda CURMOVESTART
    cmp #25
    bmi move_not_from_column2
        lda CURMOVESTART
        cmp #45
        bpl move_not_from_column2
            ;move_from_column2:
            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #25
            tax 

            ldy #0
            move_stack_from_column2_loop:
                ; store column card into temp slot
                lda BOARDCOL2, x 
                sta MOVETEMPCARDID, y

                ; remove column card from column
                lda #0
                sta BOARDCOL2, x 

                ; erase column card from column
                lda #0
                sta DRAWBGCARD
                lda #$05
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next card slot is empty OR Y == 13
                inx 
                iny 
                cpy #13
                beq move_stack_from_column2_loop_break
                lda BOARDCOL2, x 
                beq move_stack_from_column2_loop_break
                ; otherwise continue looping
                jmp move_stack_from_column2_loop
            move_stack_from_column2_loop_break:

            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #25
            tax 

            ; get the card below column card if any
            dex 
            cpx #$FF
            bne cont_move_from_column2
                jmp handle_end_card     ; skip rest of move from logic if no card is below column card
            cont_move_from_column2:

            ; flip the card below if it is hidden
            lda BOARDCOL2, x 
            cmp #%10000000
            bmi column2_below_card_already_shown
                sec 
                sbc #%10000000
                sta BOARDCOL2, x 

                txa 
                pha 
                lda #%00000101
                sta SCORECHANGE
                jsr update_score
                pla 
                tax 
            column2_below_card_already_shown:

            ; redraw the card below if there is one
            lda #1
            sta DRAWBGCARD
            lda BOARDCOL2, x 
            sta BGCARDID
            lda #$05
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            jsr draw_bg_card

            jmp handle_end_card
    move_not_from_column2:

    ; move from column 3
    lda CURMOVESTART
    cmp #45
    bmi move_not_from_column3
        lda CURMOVESTART
        cmp #65
        bpl move_not_from_column3
            ;move_from_column3:
            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #45
            tax 

            ldy #0
            move_stack_from_column3_loop:
                ; store column card into temp slot
                lda BOARDCOL3, x 
                sta MOVETEMPCARDID, y

                ; remove column card from column
                lda #0
                sta BOARDCOL3, x 

                ; erase column card from column
                lda #0
                sta DRAWBGCARD
                lda #$09
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next card slot is empty OR Y == 13
                inx 
                iny 
                cpy #13
                beq move_stack_from_column3_loop_break
                lda BOARDCOL3, x 
                beq move_stack_from_column3_loop_break
                ; otherwise continue looping
                jmp move_stack_from_column3_loop
            move_stack_from_column3_loop_break:

            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #45
            tax 

            ; get the card below column card if any
            dex 
            cpx #$FF
            bne cont_move_from_column3
                jmp handle_end_card     ; skip rest of move from logic if no card is below column card
            cont_move_from_column3:

            ; flip the card below if it is hidden
            lda BOARDCOL3, x 
            cmp #%10000000
            bmi column3_below_card_already_shown
                sec 
                sbc #%10000000
                sta BOARDCOL3, x 

                txa 
                pha 
                lda #%00000101
                sta SCORECHANGE
                jsr update_score
                pla 
                tax 
            column3_below_card_already_shown:

            ; redraw the card below if there is one
            lda #1
            sta DRAWBGCARD
            lda BOARDCOL3, x 
            sta BGCARDID
            lda #$09
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            jsr draw_bg_card

            jmp handle_end_card
    move_not_from_column3:

    ; move from column 4
    lda CURMOVESTART
    cmp #65
    bmi move_not_from_column4
        lda CURMOVESTART
        cmp #85
        bpl move_not_from_column4
            ;move_from_column4:
            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #65
            tax 

            ldy #0
            move_stack_from_column4_loop:
                ; store column card into temp slot
                lda BOARDCOL4, x 
                sta MOVETEMPCARDID, y

                ; remove column card from column
                lda #0
                sta BOARDCOL4, x 

                ; erase column card from column
                lda #0
                sta DRAWBGCARD
                lda #$0D
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next card slot is empty OR Y == 13
                inx 
                iny 
                cpy #13
                beq move_stack_from_column4_loop_break
                lda BOARDCOL4, x 
                beq move_stack_from_column4_loop_break
                ; otherwise continue looping
                jmp move_stack_from_column4_loop
            move_stack_from_column4_loop_break:

            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #65
            tax 

            ; get the card below column card if any
            dex 
            cpx #$FF
            bne cont_move_from_column4
                jmp handle_end_card     ; skip rest of move from logic if no card is below column card
            cont_move_from_column4:

            ; flip the card below if it is hidden
            lda BOARDCOL4, x 
            cmp #%10000000
            bmi column4_below_card_already_shown
                sec 
                sbc #%10000000
                sta BOARDCOL4, x 

                txa 
                pha 
                lda #%00000101
                sta SCORECHANGE
                jsr update_score
                pla 
                tax 
            column4_below_card_already_shown:

            ; redraw the card below if there is one
            lda #1
            sta DRAWBGCARD
            lda BOARDCOL4, x 
            sta BGCARDID
            lda #$0D
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            jsr draw_bg_card

            jmp handle_end_card
    move_not_from_column4:

    ; move from column 5
    lda CURMOVESTART
    cmp #85
    bmi move_not_from_column5
        lda CURMOVESTART
        cmp #105
        bpl move_not_from_column5
            ;move_from_column5:
            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #85
            tax 

            ldy #0
            move_stack_from_column5_loop:
                ; store column card into temp slot
                lda BOARDCOL5, x 
                sta MOVETEMPCARDID, y

                ; remove column card from column
                lda #0
                sta BOARDCOL5, x 

                ; erase column card from column
                lda #0
                sta DRAWBGCARD
                lda #$11
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next card slot is empty OR Y == 13
                inx 
                iny 
                cpy #13
                beq move_stack_from_column5_loop_break
                lda BOARDCOL5, x 
                beq move_stack_from_column5_loop_break
                ; otherwise continue looping
                jmp move_stack_from_column5_loop
            move_stack_from_column5_loop_break:

            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #85
            tax 

            ; get the card below column card if any
            dex 
            cpx #$FF
            bne cont_move_from_column5
                jmp handle_end_card     ; skip rest of move from logic if no card is below column card
            cont_move_from_column5:

            ; flip the card below if it is hidden
            lda BOARDCOL5, x 
            cmp #%10000000
            bmi column5_below_card_already_shown
                sec 
                sbc #%10000000
                sta BOARDCOL5, x 

                txa 
                pha 
                lda #%00000101
                sta SCORECHANGE
                jsr update_score
                pla 
                tax 
            column5_below_card_already_shown:

            ; redraw the card below if there is one
            lda #1
            sta DRAWBGCARD
            lda BOARDCOL5, x 
            sta BGCARDID
            lda #$11
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            jsr draw_bg_card

            jmp handle_end_card
    move_not_from_column5:

    ; move from column 6
    lda CURMOVESTART
    cmp #105
    bmi move_not_from_column6
        lda CURMOVESTART
        cmp #125
        bpl move_not_from_column6
            ;move_from_column6:
            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #105
            tax 

            ldy #0
            move_stack_from_column6_loop:
                ; store column card into temp slot
                lda BOARDCOL6, x 
                sta MOVETEMPCARDID, y

                ; remove column card from column
                lda #0
                sta BOARDCOL6, x 

                ; erase column card from column
                lda #0
                sta DRAWBGCARD
                lda #$15
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next card slot is empty OR Y == 13
                inx 
                iny 
                cpy #13
                beq move_stack_from_column6_loop_break
                lda BOARDCOL6, x 
                beq move_stack_from_column6_loop_break
                ; otherwise continue looping
                jmp move_stack_from_column6_loop
            move_stack_from_column6_loop_break:

            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #105
            tax 

            ; get the card below column card if any
            dex 
            cpx #$FF
            bne cont_move_from_column6
                jmp handle_end_card     ; skip rest of move from logic if no card is below column card
            cont_move_from_column6:

            ; flip the card below if it is hidden
            lda BOARDCOL6, x 
            cmp #%10000000
            bmi column6_below_card_already_shown
                sec 
                sbc #%10000000
                sta BOARDCOL6, x 

                txa 
                pha 
                lda #%00000101
                sta SCORECHANGE
                jsr update_score
                pla 
                tax 
            column6_below_card_already_shown:

            ; redraw the card below if there is one
            lda #1
            sta DRAWBGCARD
            lda BOARDCOL6, x 
            sta BGCARDID
            lda #$15
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            jsr draw_bg_card

            jmp handle_end_card
    move_not_from_column6:

    ; move from column 7
    lda CURMOVESTART
    cmp #125
    bmi move_not_from_column7
        lda CURMOVESTART
        cmp #145
        bpl move_not_from_column6
            ;move_from_column7:
            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #125
            tax 

            ldy #0
            move_stack_from_column7_loop:
                ; store column card into temp slot
                lda BOARDCOL7, x 
                sta MOVETEMPCARDID, y

                ; remove column card from column
                lda #0
                sta BOARDCOL7, x 

                ; erase column card from column
                lda #0
                sta DRAWBGCARD
                lda #$19
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next card slot is empty OR Y == 13
                inx 
                iny 
                cpy #13
                beq move_stack_from_column7_loop_break
                lda BOARDCOL7, x 
                beq move_stack_from_column7_loop_break
                ; otherwise continue looping
                jmp move_stack_from_column7_loop
            move_stack_from_column7_loop_break:

            ; get position of column card
            lda CURMOVESTART
            sec 
            sbc #125
            tax 

            ; get the card below column card if any
            dex 
            cpx #$FF
            bne cont_move_from_column7
                jmp handle_end_card     ; skip rest of move from logic if no card is below column card
            cont_move_from_column7:

            ; flip the card below if it is hidden
            lda BOARDCOL7, x 
            cmp #%10000000
            bmi column7_below_card_already_shown
                sec 
                sbc #%10000000
                sta BOARDCOL7, x 

                txa 
                pha 
                lda #%00000101
                sta SCORECHANGE
                jsr update_score
                pla 
                tax 
            column7_below_card_already_shown:

            ; redraw the card below if there is one
            lda #1
            sta DRAWBGCARD
            lda BOARDCOL7, x 
            sta BGCARDID
            lda #$19
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            jsr draw_bg_card

            jmp handle_end_card
    move_not_from_column7:

    ; handle card in end position
    handle_end_card:
    
    ; move to draw pile
    lda CURMOVESTART
    bne move_not_to_draw_pile
        ;move_to_draw_pile:
        lda #1
        sta DRAWBGCARD
        lda MOVETEMPCARDID
        sta BGCARDID
        lda #$05
        sta BGCARDTILEX
        lda #$02
        sta BGCARDTILEY
        jsr draw_bg_card

        jmp done_making_move
    move_not_to_draw_pile:

    ; move to discard piles
    lda CURMOVEEND
    cmp #145
    bmi move_not_to_discard_piles
        lda CURMOVEEND
        cmp #149
        bpl move_not_to_discard_piles
            ;move_to_discard_piles:
            ; add score bonus
            lda #%00001010
            sta SCORECHANGE
            jsr update_score

            lda MOVETEMPCARDID
            and #%01100000
            lsr 
            lsr 
            lsr 
            lsr 
            lsr 
            tax 
            lda MOVETEMPCARDID
            sta DISCARDPILES, x

            lda #1
            sta DRAWBGCARD
            lda MOVETEMPCARDID
            sta BGCARDID

            lda MOVETEMPCARDID
            and #%01100000
            lsr 
            lsr 
            lsr 
            clc 
            adc #$10
            sta BGCARDTILEX

            lda #$02
            sta BGCARDTILEY
            jsr draw_bg_card

            jmp done_making_move
    move_not_to_discard_piles:

    ;TODO: move to columns
    ; move to column 1
    lda CURMOVEEND
    cmp #5
    bmi move_not_to_column1
        lda CURMOVEEND
        cmp #25
        bpl move_not_to_column1
            ;move_to_column1:
            lda CURMOVEEND
            sec 
            sbc #5
            tax 

            ldy #0
            move_stack_to_column1_loop:
                ; store card from temp slot in column
                lda MOVETEMPCARDID, y
                sta BOARDCOL1, x 

                ; draw card in column
                sta BGCARDID
                lda #1
                sta DRAWBGCARD
                lda #$01
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next temp card is empty OR X == 20
                inx 
                iny 
                cpy #13
                beq move_stack_to_column1_loop_break
                lda MOVETEMPCARDID, y
                beq move_stack_to_column1_loop_break
                cpx #13
                beq move_stack_to_column1_loop_break
                ; otherwise continue looping
                jmp move_stack_to_column1_loop
            move_stack_to_column1_loop_break:

            jmp done_making_move
    move_not_to_column1:

    ; move to column 2
    lda CURMOVEEND
    cmp #25
    bmi move_not_to_column2
        lda CURMOVEEND
        cmp #45
        bpl move_not_to_column2
            ;move_to_column2:
            lda CURMOVEEND
            sec 
            sbc #25
            tax 

            ldy #0
            move_stack_to_column2_loop:
                ; store card from temp slot in column
                lda MOVETEMPCARDID, y
                sta BOARDCOL2, x 

                ; draw card in column
                sta BGCARDID
                lda #1
                sta DRAWBGCARD
                lda #$05
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next temp card is empty OR X == 20
                inx 
                iny 
                cpy #13
                beq move_stack_to_column2_loop_break
                lda MOVETEMPCARDID, y
                beq move_stack_to_column2_loop_break
                cpx #14
                beq move_stack_to_column2_loop_break
                ; otherwise continue looping
                jmp move_stack_to_column2_loop
            move_stack_to_column2_loop_break:

            jmp done_making_move
    move_not_to_column2:

    ; move to column 3
    lda CURMOVEEND
    cmp #45
    bmi move_not_to_column3
        lda CURMOVEEND
        cmp #65
        bpl move_not_to_column3
            ;move_to_column3:
            lda CURMOVEEND
            sec 
            sbc #45
            tax 

            ldy #0
            move_stack_to_column3_loop:
                ; store card from temp slot in column
                lda MOVETEMPCARDID, y
                sta BOARDCOL3, x 

                ; draw card in column
                sta BGCARDID
                lda #1
                sta DRAWBGCARD
                lda #$09
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next temp card is empty OR X == 20
                inx 
                iny 
                cpy #13
                beq move_stack_to_column3_loop_break
                lda MOVETEMPCARDID, y
                beq move_stack_to_column3_loop_break
                cpx #15
                beq move_stack_to_column3_loop_break
                ; otherwise continue looping
                jmp move_stack_to_column3_loop
            move_stack_to_column3_loop_break:

            jmp done_making_move
    move_not_to_column3:

    ; move to column 4
    lda CURMOVEEND
    cmp #65
    bmi move_not_to_column4
        lda CURMOVEEND
        cmp #85
        bpl move_not_to_column4
            ;move_to_column4:
            lda CURMOVEEND
            sec 
            sbc #65
            tax 

            ldy #0
            move_stack_to_column4_loop:
                ; store card from temp slot in column
                lda MOVETEMPCARDID, y
                sta BOARDCOL4, x 

                ; draw card in column
                sta BGCARDID
                lda #1
                sta DRAWBGCARD
                lda #$0D
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next temp card is empty OR X == 20
                inx 
                iny 
                cpy #13
                beq move_stack_to_column4_loop_break
                lda MOVETEMPCARDID, y
                beq move_stack_to_column4_loop_break
                cpx #16
                beq move_stack_to_column4_loop_break
                ; otherwise continue looping
                jmp move_stack_to_column4_loop
            move_stack_to_column4_loop_break:

            jmp done_making_move
    move_not_to_column4:

    ; move to column 5
    lda CURMOVEEND
    cmp #85
    bmi move_not_to_column5
        lda CURMOVEEND
        cmp #105
        bpl move_not_to_column5
            ;move_to_column5:
            lda CURMOVEEND
            sec 
            sbc #85
            tax 

            ldy #0
            move_stack_to_column5_loop:
                ; store card from temp slot in column
                lda MOVETEMPCARDID, y
                sta BOARDCOL5, x 

                ; draw card in column
                sta BGCARDID
                lda #1
                sta DRAWBGCARD
                lda #$11
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next temp card is empty OR X == 20
                inx 
                iny 
                cpy #13
                beq move_stack_to_column5_loop_break
                lda MOVETEMPCARDID, y
                beq move_stack_to_column5_loop_break
                cpx #17
                beq move_stack_to_column5_loop_break
                ; otherwise continue looping
                jmp move_stack_to_column5_loop
            move_stack_to_column5_loop_break:

            jmp done_making_move
    move_not_to_column5:

    ; move to column 6
    lda CURMOVEEND
    cmp #105
    bmi move_not_to_column6
        lda CURMOVEEND
        cmp #125
        bpl move_not_to_column6
            ;move_to_column6:
            lda CURMOVEEND
            sec 
            sbc #105
            tax 

            ldy #0
            move_stack_to_column6_loop:
                ; store card from temp slot in column
                lda MOVETEMPCARDID, y
                sta BOARDCOL6, x 

                ; draw card in column
                sta BGCARDID
                lda #1
                sta DRAWBGCARD
                lda #$15
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next temp card is empty OR X == 20
                inx 
                iny 
                cpy #13
                beq move_stack_to_column6_loop_break
                lda MOVETEMPCARDID, y
                beq move_stack_to_column6_loop_break
                cpx #18
                beq move_stack_to_column6_loop_break
                ; otherwise continue looping
                jmp move_stack_to_column6_loop
            move_stack_to_column6_loop_break:

            jmp done_making_move
    move_not_to_column6:

    ; move to column 7
    lda CURMOVEEND
    cmp #125
    bmi move_not_to_column7
        lda CURMOVEEND
        cmp #145
        bpl move_not_to_column7
            ;move_to_column7:
            lda CURMOVEEND
            sec 
            sbc #125
            tax 

            ldy #0
            move_stack_to_column7_loop:
                ; store card from temp slot in column
                lda MOVETEMPCARDID, y
                sta BOARDCOL7, x 

                ; draw card in column
                sta BGCARDID
                lda #1
                sta DRAWBGCARD
                lda #$19
                sta BGCARDTILEX
                txa 
                clc 
                adc #$06
                sta BGCARDTILEY
                txa 
                pha 
                tya 
                pha 
                jsr draw_bg_card
                pla 
                tay 
                pla 
                tax 

                ; increment indices and break out of loop if next temp card is empty OR X == 20
                inx 
                iny 
                cpy #13
                beq move_stack_to_column7_loop_break
                lda MOVETEMPCARDID, y
                beq move_stack_to_column7_loop_break
                cpx #19
                beq move_stack_to_column7_loop_break
                ; otherwise continue looping
                jmp move_stack_to_column7_loop
            move_stack_to_column7_loop_break:

            jmp done_making_move
    move_not_to_column7:

    done_making_move:

    ; clear out all of MOVETEMPCARDID
    lda #0
    sta MOVETEMPCARDID
    sta MOVETEMPCARDID+1
    sta MOVETEMPCARDID+2
    sta MOVETEMPCARDID+3
    sta MOVETEMPCARDID+4
    sta MOVETEMPCARDID+5
    sta MOVETEMPCARDID+6
    sta MOVETEMPCARDID+7
    sta MOVETEMPCARDID+8
    sta MOVETEMPCARDID+9
    sta MOVETEMPCARDID+10
    sta MOVETEMPCARDID+11
    sta MOVETEMPCARDID+12

    rts 

draw_board:
    ; draw the deck
    lda TOPDECKINDEX
    cmp #$FF
    bne draw_deck
        ;erase_deck:
        lda #0
        sta DRAWBGCARD
        lda #$01
        sta BGCARDTILEX
        lda #$02
        sta BGCARDTILEY
        jsr draw_bg_card
    draw_deck:
        lda #1
        sta DRAWBGCARD
        ldx TOPDECKINDEX
        lda DECK, x         ; get top card of deck
        sta BGCARDID
        lda #$01
        sta BGCARDTILEX
        lda #$02
        sta BGCARDTILEY
        jsr draw_bg_card

    ; draw the discard piles
    ; discard piles 0
    lda DISCARDPILES
    sta DRAWBGCARD          ; if discard pile card id is #$00, this will erase the discard pile card instead
    sta BGCARDID
    lda #$10
    sta BGCARDTILEX
    lda #$02
    sta BGCARDTILEY
    jsr draw_bg_card

    ; discard piles 1
    lda DISCARDPILES+1
    sta DRAWBGCARD          ; if discard pile card id is #$00, this will erase the discard pile card instead
    sta BGCARDID
    lda #$14
    sta BGCARDTILEX
    lda #$02
    sta BGCARDTILEY
    jsr draw_bg_card

    ; discard piles 2
    lda DISCARDPILES+2
    sta DRAWBGCARD          ; if discard pile card id is #$00, this will erase the discard pile card instead
    sta BGCARDID
    lda #$18
    sta BGCARDTILEX
    lda #$02
    sta BGCARDTILEY
    jsr draw_bg_card

    ; discard piles 3
    lda DISCARDPILES+3
    sta DRAWBGCARD          ; if discard pile card id is #$00, this will erase the discard pile card instead
    sta BGCARDID
    lda #$1C
    sta BGCARDTILEX
    lda #$02
    sta BGCARDTILEY
    jsr draw_bg_card

    ; draw each column
    ; column 1
    ldx #0
    draw_col_1_loop:
        lda BOARDCOL1, x
        beq skip_draw_card_col_1
            ;lda BOARDCOL1
            sta DRAWBGCARD
            sta BGCARDID
            lda #$01
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            txa 
            pha 
            jsr draw_bg_card
            pla 
            tax 
        skip_draw_card_col_1:
        inx 
        cpx #13
        bne draw_col_1_loop

    ; column 2
    ldx #0
    draw_col_2_loop:
        lda BOARDCOL2, x
        beq skip_draw_card_col_2
            ;lda BOARDCOL2
            sta DRAWBGCARD
            sta BGCARDID
            lda #$05
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            txa 
            pha 
            jsr draw_bg_card
            pla 
            tax 
        skip_draw_card_col_2:
        inx 
        cpx #14
        bne draw_col_2_loop

    ; column 3
    ldx #0
    draw_col_3_loop:
        lda BOARDCOL3, x
        beq skip_draw_card_col_3
            ;lda BOARDCOL3
            sta DRAWBGCARD
            sta BGCARDID
            lda #$09
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            txa 
            pha 
            jsr draw_bg_card
            pla 
            tax 
        skip_draw_card_col_3:
        inx 
        cpx #15
        bne draw_col_3_loop

    ; column 4
    ldx #0
    draw_col_4_loop:
        lda BOARDCOL4, x
        beq skip_draw_card_col_4
            ;lda BOARDCOL4
            sta DRAWBGCARD
            sta BGCARDID
            lda #$0D
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            txa 
            pha 
            jsr draw_bg_card
            pla 
            tax 
        skip_draw_card_col_4:
        inx 
        cpx #16
        bne draw_col_4_loop

    ; column 5
    ldx #0
    draw_col_5_loop:
        lda BOARDCOL5, x
        beq skip_draw_card_col_5
            ;lda BOARDCOL5
            sta DRAWBGCARD
            sta BGCARDID
            lda #$11
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            txa 
            pha 
            jsr draw_bg_card
            pla 
            tax 
        skip_draw_card_col_5:
        inx 
        cpx #17
        bne draw_col_5_loop

    ; column 6
    ldx #0
    draw_col_6_loop:
        lda BOARDCOL6, x
        beq skip_draw_card_col_6
            ;lda BOARDCOL6
            sta DRAWBGCARD
            sta BGCARDID
            lda #$15
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            txa 
            pha 
            jsr draw_bg_card
            pla 
            tax 
        skip_draw_card_col_6:
        inx 
        cpx #18
        bne draw_col_6_loop

    ; column 7
    ldx #0
    draw_col_7_loop:
        lda BOARDCOL7, x
        beq skip_draw_card_col_7
            ;lda BOARDCOL7
            sta DRAWBGCARD
            sta BGCARDID
            lda #$19
            sta BGCARDTILEX
            txa 
            clc 
            adc #$06
            sta BGCARDTILEY
            txa 
            pha 
            jsr draw_bg_card
            pla 
            tax 
        skip_draw_card_col_7:
        inx 
        cpx #19
        bne draw_col_7_loop

    rts 

clear_background:
    ; wait for vblank
    bit $2002
    vblank_wait_clear_bg:
        bit $2002
        bpl vblank_wait_clear_bg

    ; disable sprites and background rendering
    lda #%00000000
    sta $2001

    lda $2002               ; read PPU status to reset the high/low latch
    lda #$20
    sta $2006               ; write the high byte of $2000 address
    lda #$00
    sta $2006               ; write the low byte of $2000 address
    ldx #$00                ; start out at 0
    load_background_clear_loop_0:
        lda #$FF
        sta $2007               ; write to PPU
        inx                     ; increment x by 1
        cpx #$00                ; compare x to hex $00 - copying 256 bytes
        bne load_background_clear_loop_0
    load_background_clear_loop_1:     ; loop for 2nd set of background data
        lda #$FF
        sta $2007
        inx 
        cpx #$00
        bne load_background_clear_loop_1
    load_background_clear_loop_2:     ; loop for 3rd set of background data
        lda #$FF
        sta $2007
        inx 
        cpx #$00
        bne load_background_clear_loop_2
    load_background_clear_loop_3:     ; loop for 4th set of background data
        lda #$FF
        sta $2007
        inx 
        cpx #$C0
        bne load_background_clear_loop_3

    ; enable sprites and background rendering
    lda #%00011110
    sta $2001

    ; reset scrolling
    lda #$00
    sta $2005
    sta $2005

    rts 

draw_win_message:
    ; wait for vblank
    bit $2002
    vblank_wait_win_message:
        bit $2002
        bpl vblank_wait_win_message

    ; disable sprites and background rendering
    lda #%00000000
    sta $2001

    lda $2002
    lda #$21
    sta $2006
    lda #$2C
    sta $2006

    ldx #$00
    load_win_message_loop:
        lda win_message+1, x 
        sta $2007
        inx 
        cpx win_message
        bne load_win_message_loop


    ; enable sprites and background rendering
    lda #%00011110
    sta $2001

    ; reset scrolling
    lda #$00
    sta $2005
    sta $2005

    rts 

; first byte is length of message, rest is message
win_message:
    .byte $08,$18,$0E,$14,$FF,$16,$08,$0D,$1B

draw_score:
    ; wait for vblank
    bit $2002
    vblank_wait_score:
        bit $2002
        bpl vblank_wait_score

    ; disable sprites and background rendering
    lda #%00000000
    sta $2001

    lda $2002
    lda #$23
    sta $2006
    lda #$61
    sta $2006

    lda #$12
    sta $2007
    lda #$02
    sta $2007
    lda #$0E
    sta $2007
    lda #$11
    sta $2007
    lda #$04
    sta $2007
    lda #$2D
    sta $2007

    lda #$FF
    sta $2007

    lda SCORE+3
    clc 
    adc #$20
    sta $2007
    lda SCORE+2
    clc 
    adc #$20
    sta $2007
    lda SCORE+1
    clc 
    adc #$20
    sta $2007
    lda SCORE
    clc 
    adc #$20
    sta $2007

    ; enable sprites and background rendering
    lda #%00011110
    sta $2001

    ; reset scrolling
    lda #$00
    sta $2005
    sta $2005

    rts 