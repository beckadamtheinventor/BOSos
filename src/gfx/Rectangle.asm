;@DOES draws a rectangle outline to the back buffer
;@INPUT BC rectangle width
;@INPUT HL rectangle X coordinate
;@INPUT E rectangle Y coordinate
;@INPUT D rectangle height
;@DESTROYS all
gfx_Rectangle:
.computed:
	ld	a,(color_primary)		; always use primary color
	push	bc
	push	hl
	push	de
	call	gfx_HorizLine			; top horizontal line
	pop	bc
	push	bc
	call	gfx_VertLine.computed		; left vertical line
	pop	bc
	pop	hl
	ld	e,c
	call	gfx_Vertline			; right vertical line
	pop	bc
	jr	gfx_HorizLine.computed		; bottom horizontal line


