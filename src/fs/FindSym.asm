;@DOES search the VAT for a file
;@INPUT HL points to file name
;@OUTPUT DE points to VAT entry
;@OUTPUT C flag is set if failed
;@DESTROYS AF,BC
;@NOTE saves HL
fs_FindSym:
	ex hl,de
	ld hl,first_VAT_section ;first file name
	jr .entry
.loop:
	push hl ;save the current VAT pointer
	push de ;save the file name we're looking for
	ld bc,11 ;maximum file name length
	call str_n_cmp
	pop hl
	pop de
	ret z
	ex hl,de
	ld c,16 ;B and BCU should already be 0
	add hl,bc
.entry:
	ld a,(hl) ;check if we're at the end of this VAT section
	inc a
	jr nz,.loop
	inc hl
	ld de,(hl) ;check if we're at the end of the VAT
	ex hl,de
	or a,a
	sbc hl,bc
	adc hl,bc
	jr z,.fail
	inc de
	inc de
	inc de
	jr .loop
.fail:
	pop hl
	scf
	ret

