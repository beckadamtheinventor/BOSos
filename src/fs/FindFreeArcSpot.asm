;@DOES find a spot in archive suitable for a file
;@INPUT IX = file handle pointer
;@OUTPUT C flag set if failed
;@OUTPUT DE = free archive spot
;@DESTROYS All
fs_FindFreeArcSpot:
	ld de,start_of_user_archive
	push ix
	ld ix,(ix+4)
	ld bc,(ix+15)
	pop ix
.loop:
	ld hl,15
	ld a,(de)
	bit 0,a
	jr z,.check
	add hl,de
	ld hl,(hl)
	add hl,de
	ex hl,de
	jr .loop
.check:
	add hl,de
	ld hl,(hl)
	or a,a
	sbc hl,bc
	jr c,.loop
.found:
	
	ret


