;@DOES copies the back buffer to the lcd
;@DESTROYS all except A
gfx_BlitBuffer:
	ld	hl,LCD_BUFFER
	ld	de,LCD_VRAM
	ld	bc,LCD_WIDTH * LCD_HEIGHT
	ldir
	ret

