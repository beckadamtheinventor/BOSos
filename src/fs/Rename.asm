;@DOES Rename a file
;@INPUT HL = old file name
;@INPUT DE = directory pointer
;@INPUT BC = new file name
;@OUTPUT C flag set if failed
fs_Rename:
	push bc
	call fs_FindSym
	jr c,.fail
	bit fs_RAM_bit,(ix)
	call z,fs_MoveFileToRAM
	pop hl
	push hl
	lea de,ix + fs_vat_name
	ld bc,11
	ldir
	pop hl
	ld ix,(ix + fs_vat_ptr)
	lea de,ix + fs_file_name
	ld c,11
	ldir
	xor a,a
	ret
.fail:
	pop bc
	ret

