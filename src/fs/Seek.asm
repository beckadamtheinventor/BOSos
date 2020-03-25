;@DOES set the tell of a file handle
;@INPUT A = file handle
;@INPUT HL = offset or new tell
;@INPUT C = seek mode
;@OUTPUT HL = new file tell
;@OUTPUT HL = -1 on fail
;@DESTROYS All
;@NOTE acceptable seek mode values: seek from (0: start, 1: current, 2: end). Higher values will have the same effect as 2.
fs_Seek:
	push hl
	push bc
	call fs_GetFileHandlePtr
	pop bc
	pop hl
	jr nc,.fail
	ld iy,(ix+4) ;VAT pointer
	ld a,c
	cp a,1 ;seek_cur
	jr nz,.next
	ld de,(ix+1) ;file tell
	add hl,de
	jr .set
.next:
	or a,a
	jr z,.set
	ex hl,de
	ld hl,(iy+15) ;file size
	or a,a
	sbc hl,de
.set:
	ld de,(iy+15) ;file size
	or a,a
	sbc hl,de
	add hl,de
	ld (ix+1),hl ;file tell
	ret
.fail:
	scf
	sbc hl,hl
	ret

