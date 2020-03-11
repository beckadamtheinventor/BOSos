;@DOES search the VAT for a file
;@INPUT HL points to file name
;@INPUT DE = directory pointer. If this points to null, this function will search root.
;@OUTPUT IX and DE point to VAT entry
;@OUTPUT C flag is set if failed
;@DESTROYS DE,BC,AF
fs_FindSym:
	ld (ScrapWord),hl
	ld a,(de)
	or a,a
	jr z,.root
	ex hl,de
	bit fs_dir_bit,a
	jr z,.entry         ;if the VAT entry is a file
	ld bc,fs_vat_ptr    ;otherwise go to the directory's files
	ex hl,de
	add hl,bc
	ld hl,(hl)
	jr .entry           
.root:
	ld hl,os_root_dir
	jr .entry
.outer:
	ex hl,de
	ld hl,(hl)
.loop:
	ld a,(hl)
	bit fs_exists_bit,a
	jr nz,.next
	push hl ;save the current VAT pointer
	inc hl  ;skip the flag byte
	ld de,(ScrapWord)
	ld bc,11
	call memcmp
	pop hl
	jr z,.success
.next:
	ld bc,18 ;size of a VAT entry
	add hl,bc
.entry:
	ld a,(hl) ;check if we're at the end of this VAT section
	inc a
	jr nz,.loop
	inc hl
	ld bc,(hl) ;check if we're at the end of the VAT
	ex hl,de
	ld hl,-1
	or a,a
	sbc hl,bc
	jr nz,.outer
.fail:
	scf
	ret
.success:
	ex hl,de
	push de
	pop ix
	ld hl,(ScrapWord)
	ret

