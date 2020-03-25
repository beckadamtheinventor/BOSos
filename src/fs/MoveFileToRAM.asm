;@DOES move a file into RAM
;@INPUT IX = file handle pointer
;@OUTPUT Z flag set if success
;@OUTPUT C flag set if malloc failed
;@DESTROYS All
;@NOTE file handle pointer returned from sys_GetFileHandlePtr
;@NOTE IY is set to the file's VAT pointer
;@NOTE does nothing if the file is already in RAM
fs_MoveFileToRAM:
	bit fs_RAM_bit,(ix)
	ret nz ;in RAM already
fs_CopyFileToRAM:
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(iy+15) ; file size
.entry:
	push hl
	call fs_Alloc
	pop bc
	ret c
	ld hl,(iy+12) ; file old data pointer
	ld (iy+12),de ; file new data pointer
	ldir
	set fs_RAM,(ix)
	xor a,a
	ret


