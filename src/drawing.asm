.segment "ZEROPAGE"
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