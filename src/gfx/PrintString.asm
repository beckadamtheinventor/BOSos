;@DOES print a string to the back buffer
;@INPUT HL pointer to string
;@DESTROYS HL,DE,BC,AF
gfx_PrintString:
	ld	a,(lcd_y)
	cp	a,TEXT_MAX_ROW
	ret nc
	ld	de,LCD_WIDTH - 10
.loop:
	ld	a,(hl)
	or	a,a
	ret	z
	call	gfx_PrintChar			; saves de
	push	hl
	ld	hl,(lcd_x)
	or	a,a
	sbc	hl,de
	jr	c,.next
	ld	a,(lcd_y)
	add a,9
	ld	(lcd_y),a
	or a,a
	sbc hl,hl
	ld	(lcd_x),hl
	cp	a,TEXT_MAX_ROW
	jr	c,.next
	pop hl
	ret
.next:
	pop	hl
	inc	hl
	jr	.loop

