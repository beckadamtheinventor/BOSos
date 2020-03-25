;@DOES defragment RAM
;@NOTE does not damage malloc'd memory, but will likely change its pointer.
fs_RAMCollect:
	ld bc,(remaining_file_RAM)
	ld hl,total_file_RAM
	or a,a
	sbc hl,bc
	ld (ScrapMem),hl
	ld de,start_of_file_RAM
	push de
	pop hl
.loop:
	ld a,(hl)
	push hl
	ld bc,fs_file_len
	add hl,bc
	ld bc,(hl)
	inc bc
	inc bc
	inc bc
	add hl,bc
	push hl
	ld hl,15
	add hl,bc
	push hl
	pop bc
	pop hl
	pop ix
	bit fs_exists,a
	jr z,.loop
	or a,a
	ex hl,de
	ld bc,start_of_file_RAM
	or a,a
	sbc hl,bc
	ex hl,de
	jr z,.loop
	lea hl,ix
	push bc
	ldir
	pop bc
	push hl
	ld hl,(ScrapMem)
	or a,a
	sbc hl,bc
	ld (ScrapMem),hl
	pop hl
	jr nc,.loop
	ret

