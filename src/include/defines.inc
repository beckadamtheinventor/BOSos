;-------------------------------------------------------------------------------
; RAM defines
;-------------------------------------------------------------------------------

RAM_START  := 0D00000h

;-------------------------------------------------------------------------------
; LCD defines
;-------------------------------------------------------------------------------

LCD_PAL    := 0E30200h
LCD_CTRL   := 0E30018h
LCD_VRAM   := 0D40000h
LCD_BUFFER := LCD_VRAM + LCD_WIDTH*LCD_HEIGHT
LCD_WIDTH  := 320
LCD_HEIGHT := 240
LCD_8BPP   := $27
LCD_16BPP  := $2D

;-------------------------------------------------------------------------------
; OS defines
;-------------------------------------------------------------------------------
TEXT_MAX_ROW           := 231

_SaveData              := RAM_START+6
_TextShadow            := _SaveData+32
_TextShadow_numcols    := 27
_TextShadow_numlines   := 10
_TextShadow_len        := 270  ;need null afer every line
lcd_text_fg            := _TextShadow+_TextShadow_len
lcd_text_bg            := lcd_text_fg+1
font_spacing           := lcd_text_bg+1
font_data              := font_spacing+3
color_primary          := font_data+3
ScrapByte              := color_primary+1
ScrapWord              := ScrapByte+1
lcd_x                  := ScrapWord+3
lcd_y                  := lcd_x+3
_InputBuffer           := lcd_y+1

free_RAM_ptr           := _InputBuffer+257
remaining_free_RAM     := free_RAM_ptr+3
gfx_string_temp        := remaining_free_RAM+3
open_files_table       := gfx_string_temp+16
free_VAT_entry_ptr     := open_files_table+256
first_VAT_section      := free_VAT_entry_ptr+3


start_of_user_archive  := $100000 ;sector $10, gives OS plenty of room




