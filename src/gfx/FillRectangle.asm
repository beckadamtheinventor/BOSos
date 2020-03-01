;@DOES draws a filled rectangle to the back buffer
;@INPUT BC rectangle width
;@INPUT HL rectangle X coordinate
;@INPUT E rectangle Y coordinate
;@INPUT A rectangle height
;@DESTROYS all
gfx_FillRectangle:
	ld	d,LCD_WIDTH / 2
	mlt	de
	add	hl,de
	add	hl,de
	ex	de,hl
.computed:
	ld	ix,LCD_BUFFER			; de -> place to begin drawing
	ld	(ScrapWord),bc
.loop:
	add	ix,de
	lea	de,ix
	ld	bc,(ScrapWord)
	ld	hl,color_primary		; always just fill with the primary color
	ldi					; check if we only need to draw 1 pixel
	jp	po,.skip
	scf
	sbc	hl,hl
	add	hl,de
	ldir					; draw the current line
.skip:
	ld	de,LCD_WIDTH			; move to next line
	dec	a
	jr	nz,.loop
	ret

