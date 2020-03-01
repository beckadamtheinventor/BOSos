table:
; $=0020108h
	jp handle_boot
	jp handle_int
	jp handle_rst10
	jp handle_rst18
	jp handle_rst20
	jp handle_rst28
	jp handle_rst30
; $=0020128
; $=002012Ch
;-------------------------------------------------------------------------------
; OS functions
;-------------------------------------------------------------------------------
	jp sys_MemSet
	jp sys_AddHLAndA
	jp sys_HLToString
	jp kb_Scan
	jp kb_AnyKey
	jp sys_GetKey
	jp sys_WaitKey
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING

;-------------------------------------------------------------------------------
; string functions
;-------------------------------------------------------------------------------
	jp str_len
	jp str_set
	jp str_cpy
	jp str_cmp
	jp str_upper
	jp str_lower
	jp str_n_cpy
	jp str_n_cmp
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING

;-------------------------------------------------------------------------------
; VAT and FS functions
;-------------------------------------------------------------------------------
	jp fs_BuildVAT
	jp fs_FindSym
	jp fs_CreateFile
	jp fs_GetC
	jp fs_PutC
	jp fs_Open
	jp fs_Read
	jp fs_Write
	jp fs_Tell
	jp fs_Seek
	jp fs_Delete
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING

;-------------------------------------------------------------------------------
; built-in graphics functions
;-------------------------------------------------------------------------------
	jp gfx_Set8bpp
	jp gfx_Set16bpp
	jp gfx_InitStdPalette
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp gfx_PutS
	jp gfx_LcdClear
	jp gfx_BufClear
	jp gfx_BlitBuffer
	jp gfx_PrintUInt
	jp gfx_Compute
	jp gfx_HorizLine
	jp gfx_VertLine
	jp gfx_Rectangle
	jp gfx_FillRectangle
	jp gfx_Sprite
	jp gfx_PutC
	jp gfx_NextLine
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING
	jp DONOTHING


