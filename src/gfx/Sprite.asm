;@DOES draws a sprite to the back buffer
;@INPUT HL pointer to sprite
;@INPUT BC X<<8 + Y
;@DESTROYS all
gfx_Sprite:
	push	hl
	or	a,a
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	ld	de,LCD_BUFFER
	add	hl,de
	ld	b,LCD_WIDTH / 2
	mlt	bc
	add	hl,bc
	add	hl,bc				; draw location
	ld	b,0
	ex	de,hl
	pop	hl
	ld	a,(hl)
	ld	(ScrapByte),a			; width
	inc	hl
	ld	a,(hl)				; height
	inc	hl
	ld	ix,0
.loop:
	push af
	ld a,(ScrapByte)
	ld	c,a
	pop af
	add	ix,de
	lea	de,ix
	ldir
	ld	de,LCD_WIDTH
	dec	a				; for height
	jr	nz,.loop
	ret

