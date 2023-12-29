.segment "ZEROPAGE"
    DRAWBGCARD: .res 1
    BGCARDID: .res 1
    BGCARDTILENUM: .res 1
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
    ; TODO: calculate the value of the cursor as high and low byte
    lda #$21
    sta BGCARDHBYTE
    lda #0
    sta BGCARDLBYTE

    ; TODO: calculate the card value and suit for drawing the card

    ; draw the card
    lda DRAWBGCARD
    cmp #1
    bne erase_from_bg
    draw_on_bg:
        ; draw top of card
        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        sta $2006

        lda #$30    ; card value
        sta $2007
        lda #$61 
        sta $2007
        lda #$62
        sta $2007

        ; draw middle of card
        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        clc 
        adc #$20
        sta $2006

        lda #$70
        sta $2007
        lda #$40    ; suite top-left
        sta $2007
        lda #$41    ; suite top-right
        sta $2007

        ; draw bottom of card
        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        clc 
        adc #$40
        sta $2006

        lda #$80 
        sta $2007
        lda #$50    ; suite bottom-left
        sta $2007
        lda #$51    ; suite bottom-right
        sta $2007
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
        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        clc 
        adc #$20
        sta $2006

        lda #$3F
        sta $2007
        sta $2007
        sta $2007
        
        ; erase bottom of card
        lda $2002
        lda BGCARDHBYTE
        sta $2006
        lda BGCARDLBYTE
        clc 
        adc #$40
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