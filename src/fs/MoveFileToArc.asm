;@DOES move a file into archive
;@INPUT IX = file handle pointer
;@OUTPUT Z flag set if success
;@OUTPUT C flag set if not enough memory
;@DESTROYS All
;@NOTE does nothing if file is already in archive
fs_MoveFileToArc:
	bit fs_RAM_bit,(ix)
	jr z,.inarc ;in archive already
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(iy+15) ; file size
	push hl
	call fs_FindFreeArcSpot
	pop bc
	jr c,.failed
	push de
	call sys_WriteFlash
	pop de
	res fs_RAM,(ix)
	ld (ix+4),de
	xor a,a
	ret
.inarc:
	xor a,a
	inc a
	ret
.failed:
	pop hl
	ret

