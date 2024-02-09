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
    cmp #1
    beq draw_on_bg
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
                jmp top_left_done
            black_card:
                lda BGCARDID
                and #%00011111
                clc 
                adc #$40    ; card value
                sta $2007
            top_left_done:
            lda #$71 
            sta $2007
            lda #$72
            sta $2007
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

        lda #$3F
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

        lda #$3F
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

        lda #$3F
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