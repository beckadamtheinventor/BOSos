;@DOES read data from a file into a buffer
;@INPUT A = file handle
;@INPUT DE = data buffer
;@INPUT HL = bytes to read
;@OUTPUT HL = number of bytes read
;@OUTPUT Z flag set if success, else failed
;@DESTROYS All
fs_Read:
	push de
	push hl
	call fs_GetFileHandlePtr
	jr nc,.failed
	bit fs_read_bit,(ix)
	jr z,.failed
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(ix+1)  ; file tell
	ld bc,(iy+15) ; file size
	or a,a
	sbc hl,bc
	jr z,.eof
	pop bc ; read size
	or a,a
	sbc hl,bc
	add hl,bc
	jr nc,.read
	push hl
	pop bc
.read:
	ld hl,(iy+12) ; file pointer
	ld de,(ix+1)  ; file tell
	add hl,de
	pop de
	push bc
	ldir
	pop hl
	ret
.eof:
	pop hl
	pop de
	ld hl,0
	ret
.failed:
	pop hl
	pop de
	xor a,a
	inc a
	ret

