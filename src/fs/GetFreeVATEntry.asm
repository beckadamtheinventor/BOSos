;@DOES find a free VAT entry
;@OUTPUT DE = VAT entry
;@OUTPUT C flag is set if failed
;@DESTROYS HL,BC
fs_GetFreeVATEntry:
	ld hl,first_VAT_section+1
.reloop:
	ld bc,16
.loop:
	ld a,(hl)
	or a,a
	jr z,.found
	inc a
	jr z,.next
	add hl,bc
	jr .loop
.found:
	ex hl,de
	ret
.next:       ; next VAT section
	inc hl
	ld hl,(hl)
	ld c,0
	or a,a
	sbc hl,bc
	jr nz,.reloop
	push hl
	ld hl,512      ; malloc a new VAT section
	push hl
	call sys_Malloc
	pop bc
	push de
	xor a,a
	call sys_MemSet
	pop de
	pop hl
	ld (hl),de     ; link to the new VAT section
	ret

