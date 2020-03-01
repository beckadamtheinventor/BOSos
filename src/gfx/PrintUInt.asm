;@DOES print a number to the back buffer
;@INPUT HL number to display
;@INPUT A characters to use (8-nchars)
;@OUTPUT string stored at gfx_string_temp
gfx_PrintUInt:
	dec	a
	push	af
	call	util_num_convert
	ex	de,hl
	pop	af
	call	sys_AddHLAndA
	jp	lcd_string

