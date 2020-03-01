;@DOES move a file into RAM
;@INPUT IX = file handle pointer
;@OUTPUT Z flag set if success
;@OUTPUT C flag set if malloc failed
;@DESTROYS All
;@NOTE file handle pointer returned from sys_GetFileHandlePtr
;@NOTE does nothing if the file is already in RAM
fs_MoveFileToRAM:
	bit fs_RAM_bit,(ix)
	ret nz ;in RAM already
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(iy+15) ; file size
	push hl
	call sys_Malloc
	pop bc
	ret c
	ld hl,(iy+12) ; file data pointer
	ld (iy+12),de
	ldir
	set fs_RAM,(ix)
	xor a,a
	ret


