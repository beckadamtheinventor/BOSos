;@DOES read a character from a file
;@INPUT A = file handle
;@OUTPUT C = character
;@OUTPUT C flag set if EOF reached
;@OUTPUT Z flag set if success, else failed
;@DESTROYS All
;@NOTE when checking the return of this call, make sure to check the Carry flag <i>first</i>
fs_GetC:
	call fs_GetFileHandlePtr
	bit fs_read_bit,(ix)
	jr z,.failed
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(ix+1)  ; file tell
	ld de,(iy+15) ; file size
	or a,a
	sbc hl,de
	add hl,de
	jr nc,.eof
	ld bc,(iy+12) ; file pointer
	add hl,bc
	ld c,(hl)
	or a,a
	sbc hl,bc
	inc hl       ; increment the file tell
	ld (ix+1),hl ; save the new file tell
	xor a,a
	ret
.eof:
	scf
	ret
.failed:
	xor a,a
	inc a
	ret
