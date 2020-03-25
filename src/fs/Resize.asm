;@DOES Resize a file
;@INPUT A = file handle ptr
;@INPUT HL = new file size
;@DESTROYS All
fs_Resize:
	push hl
	call fs_GetFileHandlePtr
	pop hl
	ret nc
	ld a,(ix)
	bit fs_write_bit,a
	ret nz
	ld iy,(ix+4) ; VAT pointer
	ld bc,(iy+15) ;old file size
	add hl,bc
	ld (iy+15),hl ;new file size
	jq fs_CopyFileToRAM.entry


