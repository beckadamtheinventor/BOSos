;@DOES find a spot in archive suitable for a file
;@INPUT IX = file handle pointer
;@OUTPUT C flag set if failed
;@OUTPUT DE = free archive spot
;@DESTROYS HL,DE,BC,AF
fs_FindFreeArcSpot:
	ld de,start_of_user_archive
	push ix
	ld ix,(ix+4)
	ld bc,(ix+15)
	ld hl,18
	add hl,bc
	push hl
	pop bc
	pop ix
.loop:
	ld hl,15
	ld a,(de)
	cp a,$FF
	jr z,.endofsec
	add hl,de
	ld hl,(hl)
	bit fs_exists,a
	jr z,.check
	inc hl
	inc hl
	inc hl
	add hl,de
	ex hl,de
	jr .loop
.check:
	or a,a
	sbc hl,bc
	jr c,.loop
	ex hl,de
	ld bc,18
	add hl,bc
	ex hl,de
	xor a,a
	ret
.endofsec:
	inc de
	push de
	ex hl,de
	add hl,de
	ex (sp),hl
	ld hl,(hl)
	ex hl,de
	push bc
	ld bc,-1
	or a,a
	sbc hl,bc
	add hl,bc
	pop bc
	pop de
	add hl,de
	ex hl,de
	ret z
	jr .loop

