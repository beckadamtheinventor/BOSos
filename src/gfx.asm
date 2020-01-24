


; lcd handling routines for the pl1111

;@DOES set the lcd to 8bpp mode
;@DESTROYS all
gfx_Set8bpp:
lcd_init:
	di
	call	lcd_clear
.setup:
	ld	a,LCD_8BPP
	ld	(LCD_CTRL),a		; operate in 8bpp
	ld	hl,LCD_PAL
	ld	b,0
.loop:
	ld	d,b
	ld	a,b
	and	a,192
	srl	d
	rra
	ld	e,a
	ld	a,31
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,.loop
	ret

;@DOES set the lcd to 16bpp mode
;@DESTROYS all
gfx_Set16bpp:
lcd_normal:
	ld	hl,LCD_VRAM
	ld	bc,((LCD_WIDTH * LCD_HEIGHT) * 2) - 1
	ld	a,255
	call	sys_MemSet
	ld	a,LCD_16BPP
	ld	(LCD_CTRL),a
	ret

;@DOES clears the lcd
;@INPUT A color to fill with
;@DESTROYS all except A
gfx_LcdClear:
lcd_clear:
	ld	hl,LCD_VRAM
	ld	bc,LCD_WIDTH * LCD_HEIGHT - 1
	jr	lcd_fill.clear

;@DOES clears the back buffer
;@INPUT A color to fill with
;@DESTROYS all except A
gfx_BufClear:
lcd_fill:
	ld	hl,LCD_BUFFER
	ld	bc,LCD_WIDTH * LCD_HEIGHT - 1
.clear:
	push hl
	pop de
	inc de
	ld (hl),a
	ldir

;@DOES copies the back buffer to the lcd
;@DESTROYS all except A
gfx_BlitBuffer:
lcd_blit:
	ld	hl,LCD_BUFFER
	ld	de,LCD_VRAM
	ld	bc,LCD_WIDTH * LCD_HEIGHT
	ldir
	ret

;@DOES draws a sprite to the back buffer
;@INPUT HL pointer to sprite
;@INPUT BC X<<8 + Y
;@DESTROYS all
gfx_Sprite:
lcd_sprite:
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

;@DOES draws a filled rectangle to the back buffer
;@INPUT BC rectangle width
;@INPUT HL rectangle X coordinate
;@INPUT E rectangle Y coordinate
;@INPUT A rectangle height
;@DESTROYS all
gfx_FillRectangle:
lcd_rectangle:
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


;@DOES draws a rectangle outline to the back buffer
;@INPUT BC rectangle width
;@INPUT HL rectangle X coordinate
;@INPUT E rectangle Y coordinate
;@INPUT D rectangle height
;@DESTROYS all
gfx_Rectangle:
lcd_rectangle_outline:
.computed:
	ld	a,(color_primary)		; always use primary color
	push	bc
	push	hl
	push	de
	call	lcd_horizontal			; top horizontal line
	pop	bc
	push	bc
	call	lcd_vertical.computed		; left vertical line
	pop	bc
	pop	hl
	ld	e,c
	call	lcd_vertical			; right vertical line
	pop	bc
	jr	lcd_horizontal.computed		; bottom horizontal line


;@DOES draws a horizontal line
;@INPUT HL line X coordinate
;@INPUT E line Y coordinate
;@INPUT BC line length
;@DESTROYS all
gfx_HorizLine:
lcd_horizontal:
	call	lcd_compute			; hl -> drawing location
.computed:
	jp	sys_MemSet


;@DOES draws a vertical line
;@INPUT HL line X coordinate
;@INPUT E line Y coordinate
;@INPUT B line length
;@DESTROYS all
gfx_VertLine:
lcd_vertical:
	dec	b
	call	lcd_compute			; hl -> drawing location
.computed:
	ld a,(color_primary)
	ld	de,LCD_WIDTH
.loop:
	ld	(hl),a				; loop for height
	add	hl,de
	djnz	.loop
	ret


;@DOES compute draw location on the back buffer from XY coodinate.
;@INPUT HL X coordinate
;@INPUT E Y coordinate
;@OUTPUT HL pointer to draw location
;@DESTROYS AF, DE
gfx_Compute:
lcd_compute:
	ld	d,LCD_WIDTH / 2
	mlt	de
	add	hl,de
	add	hl,de
	ld	de,LCD_BUFFER
	add	hl,de
	ret

;@DOES print a string to the back buffer
;@INPUT HL pointer to string
;@DESTROYS all
gfx_PutS:
lcd_string:
	ld	a,(lcd_y)
	cp	a,TEXT_MAX_ROW
	ret nc
	ld	de,LCD_WIDTH - 10
.loop:
	ld	a,(hl)
	or	a,a
	ret	z
	call	lcd_char			; saves de
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

;@DOES print a character to the back buffer
;@INPUT A character to draw
;@DESTROYS all except DE
gfx_PutC:
lcd_char:
character_width := 8
character_height := 8
	push	hl
	push	af
	push	de
	ld	bc,(lcd_x)
	push	bc
	ld	hl,lcd_y
	ld	l,(hl)
	ld	h,LCD_WIDTH / 2
	mlt	hl
	add	hl,hl
	ld	de,LCD_BUFFER
	add	hl,de
	add	hl,bc				; add x value
	push	hl
	sbc	hl,hl
	ld	l,a
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de,hl
	ld	hl,(font_data)
	add	hl,de				; hl -> correct character
	pop	de				; de -> correct location
	ld	a,character_width
.vert_loop:
	ld	c,(hl)
	ld	b,character_height
	ex	de,hl
	push	de
	push	hl
	ld	hl,lcd_text_fg
	ld	de,(hl)
	pop	hl
.horiz_loop:
	ld	(hl),d
	rlc	c
	jr	nc,.bg
	ld	(hl),e
.bg:
	inc	hl
	djnz	.horiz_loop
	ld	(hl),d
	ld	bc,LCD_WIDTH - character_width
	add	hl,bc
	pop	de
	ex	de,hl
	inc	hl
	dec	a
	jr	nz,.vert_loop
	pop	bc
	pop	de
	pop	af				; character
	ld	hl,(font_spacing)
	call sys_AddHLAndA
	ld	a,(hl)				; amount to step per character
	or	a,a
	sbc	hl,hl
	ld	l,a
	add	hl,bc
	ld	(lcd_x),hl
	pop	hl
	ret

;@DOES moves the text position 9 rows ahead, and zeroes the collumn.
;@DESTROYS HL,A
gfx_NextLine:
	or a,a
	sbc hl,hl
	ld (lcd_x),hl
	ld a,(lcd_y)
	add a,9
	ld (lcd_y),a
	ret

; a = amount of characters to display
lcd_num_7:
	ld	a,1
	jr	lcd_num
lcd_num_6:
	ld	a,2
	jr	lcd_num
lcd_num_5:
	ld	a,3
	jr	lcd_num
lcd_num_4:
	ld	a,4
	jr	lcd_num
lcd_num_3:
	ld	a,5
	jr	lcd_num

;@DOES print a number to the back buffer
;@INPUT HL number to display
;@INPUT A characters to use (8-nchars)
;@OUTPUT string stored at gfx_string_temp
gfx_PrintUInt:
lcd_num:
	dec	a
	push	af
	call	util_num_convert
	ex	de,hl
	pop	af
	call	sys_AddHLAndA
	jp	lcd_string

;@DOES convert a number to a string
;@INPUT HL number to convert
;@OUTPUT string stored at gfx_string_temp
sys_HLToString:
util_num_convert:
	ld	de,gfx_string_temp
	push	de
	call	.entry
	xor	a,a
	ld	(de),a
	pop	de
	ret
.entry:
	ld	bc,-1000000
	call	.aqu
	ld	bc,-100000
	call	.aqu
	ld	bc,-10000
	call	.aqu
	ld	bc,-1000
	call	.aqu
	ld	bc,-100
	call	.aqu
	ld	c,-10
	call	.aqu
	ld	c,b
.aqu:
	ld	a,'0' - 1
.under:
	inc	a
	add	hl,bc
	jr	c,.under
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret


