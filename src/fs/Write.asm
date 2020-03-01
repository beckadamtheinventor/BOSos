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
	call sys_GetFileHandlePtr
	ld a,(ix)
	bit fs_write_bit,a
	jr z,.failed
	ld iy,(ix+4)  ; VAT pointer
	bit fs_RAM_bit,a
	pop hl
	push hl
	jr z,.toRAM
	call .checkspace
	jr c,.toRAM_2
.cont:
	ld hl,(iy+12) ; file pointer
	ld de,(ix+1)  ; file tell
	add hl,de
	ex hl,de
	pop bc        ; write length
	pop hl        ; write data
	ldir
	ret
.toRAM:
	call .checkspace
.toRAM_2:
	jr nc,.movetoRAM
	ex hl,de
	ld hl,(iy+15)
	or a,a
	sbc hl,de
	ld (iy+15),hl
.movetoRAM:
	call fs_MoveFileToRAM
	jr nc,.cont
	pop hl
	pop de
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
