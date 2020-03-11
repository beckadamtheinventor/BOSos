;-------------------------------------------------------------------------------
handle_boot:
	call	setup
	call	os_setup
	call	os_main

handle_int:
.trap:
	jr	.trap

handle_rst10:
handle_rst18:
handle_rst20:
handle_rst28:
handle_rst30:
	jp	$3ac

;-------------------------------------------------------------------------------
setup:=gfx_InitStdPalette


;-------------------------------------------------------------------------------
os_setup:
	ld hl,flag_start
	xor a,a
	call sys_MemSet
	ld hl,data_font_data
	ld (font_data),hl
	ld hl,data_font_spacing
	ld (font_spacing),hl
	xor a,a
	ld (lcd_text_bg),a
	call gfx_BufClear
	dec a
	ld (lcd_text_fg),a
	ld  hl,os_config_file
	ld  de,os_config_file_dir
	ld  a,fs_read
	call  fs_Open
	call  fs_GetFileHandlePtr
	jr  nc,.load
	ld de,flags
	ld hl,defaultflags
	ld bc,32
	ldir
	ld  hl,os_config_file
	ld  de,os_config_file_dir
	ld  a,fs_write
	call fs_Open
	jr c,.fail
	ret
.fail:
	set bos_read_only_fs, (iy + flags.sys_flags)
	ret
.load:

	ret

;-------------------------------------------------------------------------------
os_main:
	xor a,a
	ld hl,InputBuffer
	ld bc,256
	call sys_MemSet
.draw:
	ld  iy,flags
	ld  hl,(iy + flags.text_fg)
	ld  (iy + flags.lcd_text_fg),l
	ld  (iy + flags.lcd_text_bg),h
	ld  a,(iy + flags.lcd_bg_color)
	call  gfx_BufClear
	call  gfx_BlitBuffer
	ld b,32
.loop:
	push bc
	bit  cursor_2nd, (iy + flags.cursor_flags)
	call  nz,TurnOffIfOnKeyPressed
	call  sys_GetKey
	pop bc
	cp  a,ti.sk2nd
	jr  z,set_2nd
	djnz .loop
	ld  hl, (iy + flags.cursor_x)
	ld  e,  (iy + flags.cursor_y)
	ld  bc, 9
	ld  a,  (iy + flags.cursor_color)
	ld  (iy + flags.color_primary),a
	ld  a,  9
	call  gfx_FillRectangle
	bit  cursor_2nd, (iy + flags.cursor_flags)
	call  nz,draw_2nd_cursor
	jr .loop
draw_2nd_cursor:
	ld  de, (iy + flags.cursor_x)
	or a,a
	sbc hl,hl
	ld  l,  (iy + flags.cursor_y)
	inc de
	inc hl
	ld  (iy + flags.lcd_x),de
	ld  (iy + flags.lcd_y),hl
	ld  hl, (iy + flags.lcd_text_fg)
	ld  (iy + flags.lcd_text_fg),h
	ld  (iy + flags.lcd_text_bg),l
	ld  a,$18   ;up arrow
	jp  gfx_PrintChar

checkOnKey:
	ld hl,$F0202C
	ld (hl),l
	ld l,h
	bit 0,(hl)
	ret

set_2nd:
	set  cursor_2nd, (iy + flags.cursor_flags)
	jr os_main.loop

TurnOffIfOnKeyPressed:
	call checkOnKey
	ret z
TurnCalcOff:
	ld a,$C0
	out0 (0),a
	ex af,af'
	ei
	halt

;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------


