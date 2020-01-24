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
setup:
; setup common items
	ld	a,$27
	ld	(LCD_CTRL),a
	ld	de,LCD_PAL  ; address of mmio palette
	ld	b,e         ; b = 0
.loop:
	ld	a,b
	rrca
	xor	a,b
	and	a,224
	xor	a,b
	ld	(de),a
	inc	de
	ld	a,b
	rla
	rla
	rla
	ld	a,b
	rra
	ld	(de),a
	inc	de
	inc	b
	jr	nz,.loop		; loop for 256 times to fill palette
	ret

;-------------------------------------------------------------------------------
os_setup:
	ld hl,data_font_data
	ld de,data_font_spacing
	call gfx_LoadFont
	xor a,a
	ld (lcd_text_bg),a
	call gfx_BufClear
	ld a,$FF
	ld (lcd_text_fg),a
	ld a,12
	ld (lcd_y),a
	or a,a
	sbc hl,hl
	ld (lcd_x),hl
	ld hl,data_strings.hello_world
	call gfx_PutS
	call gfx_NextLine
	ld hl,data_strings.welcome_to_bos
	call gfx_PutS
	call gfx_NextLine	
	ld hl,data_strings.happy_emoji
	call gfx_PutS
	call gfx_NextLine
	ld hl,_InputBuffer
	push hl
	pop de
	inc de
	xor a,a
	ld (hl),a
	ld bc,256
	ldir
	jp gfx_BlitBuffer

;-------------------------------------------------------------------------------
os_main:
	ld a,$FF
intro_completed:=$-1
	or a,a
	call nz,intro_main
	ld a,$BF
	call gfx_BufClear
	
.loop:
	call sys_GetKey
	jr .loop
intro_main:
	jp ti.boot.ClearVRAM

;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------

include 'macros.inc'

