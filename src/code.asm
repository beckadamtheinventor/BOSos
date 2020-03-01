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
setup:=gfx_initStdPalette


;-------------------------------------------------------------------------------
os_setup:
	ld hl,data_font_data
	ld (font_data),hl
	ld hl,data_font_spacing
	ld (font_spacing),hl
	xor a,a
	ld (lcd_text_bg),a
	call gfx_BufClear
	dec a
	ld (lcd_text_fg),a
	jp gfx_BlitBuffer

;-------------------------------------------------------------------------------
os_main:
	ld a,$FF
intro_completed:=$-1
	or a,a
	call nz,intro_main
	ld a,$BF
	call gfx_BufClear
	call gfx_BlitBuffer
.loop:
	call sys_GetKey
	jr .loop
intro_main:
	jp ti.boot.ClearVRAM

;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------


