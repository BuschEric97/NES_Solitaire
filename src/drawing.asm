.segment "ZEROPAGE"
    DRAWBGCARD: .res 1
    BGCARDID: .res 1
    BGCARDTILEX: .res 1
    BGCARDTILEY: .res 1
    BGCARDTILENUM: .res 2
    BGCARDHBYTE: .res 1
    BGCARDLBYTE: .res 1

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

draw_cursor:
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

erase_cursor:
    lda #0
    sta $0200
    sta $0201
    sta $0202
    sta $0203

    jsr draw_sprites

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


    ; draw the draw piles
    ; draw pile 0
    lda DRAWPILE
    sta DRAWBGCARD          ; if draw pile card id is #$00, this will erase the draw pile card instead
    sta BGCARDID
    lda #$05
    sta BGCARDTILEX
    lda #$02
    sta BGCARDTILEY
    jsr draw_bg_card

    ; draw pile 1
    lda DRAWPILE+1
    sta DRAWBGCARD
    sta BGCARDID
    lda #$08
    sta BGCARDTILEX
    lda #$02
    sta BGCARDTILEY
    jsr draw_bg_card

    ; draw pile 2
    lda DRAWPILE+2
    sta DRAWBGCARD
    sta BGCARDID
    lda #$0B
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
        cpx #20
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
        cpx #20
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
        cpx #20
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
        cpx #20
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
        cpx #20
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
        cpx #20
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
        cpx #20
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