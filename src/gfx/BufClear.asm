;@DOES clears the back buffer
;@INPUT A color to fill with
;@DESTROYS all except A
gfx_BufClear:
	ld	hl,LCD_BUFFER
	ld	bc,LCD_WIDTH * LCD_HEIGHT - 1
.clear:
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	ret

