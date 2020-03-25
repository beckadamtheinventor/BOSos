;@DOES write a buffer into a file
;@INPUT A = file handle
;@INPUT DE = data buffer
;@INPUT HL = write length
;@OUTPUT Z flag if success, else failed
;@OUTPUT C flag if not enough memory or file too large
;@DESTROYS All
;@NOTE when checking the return of this call, make sure to check the Carry flag <i>first</i>
fs_Write:
	push de
	push hl
	call fs_GetFileHandlePtr
	jr nc,.failed
	ld a,(ix)
	bit fs_write_bit,a
	jr z,.failed
	bit fs_RAM_bit,a
	call z,fs_MoveFileToRAM
	pop hl
	push hl
	call .checkspace
	call nc,fs_IncreaseFileSize
.cont:
	ld hl,(iy+12) ; file pointer
	ld de,(ix+1)  ; file tell
	add hl,de
	ex hl,de
	pop bc        ; write length
	pop hl        ; write data
	ldir
	ret
.failed:
	pop hl
	pop de
	xor a,a
	inc a
	ret
.checkspace:
	ld de,(ix+1)  ; file tell
	add hl,de
	ex hl,de
	ld hl,(iy+15) ; file size
	or a,a
	sbc hl,de
	ret
