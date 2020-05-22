;@DOES build the VAT
;@DESTROYS All
fs_BuildVAT:
	ld ix,start_of_user_archive
.loop:
	call .build_one
	push ix
	pop de
	ld hl,end_of_user_archive
	or a,a
	sbc hl,de
	jr nc,.loop
	ret
.build_one:
	ld hl,18
	call sys_Malloc ;returns in DE
	push ix
	pop hl
	ld bc,fs_file_parent ;copy up until the parent dir ptr
	push de
	push hl
	ldir
	pop iy
	ld hl,(iy+fs_file_len) ;grab file length
	lea de,iy+fs_file_data ;grab file data pointer
	pop iy
	ld (iy+fs_vat_len),hl
	ld (iy+fs_vat_ptr),de
	add hl,de
	push hl
	pop ix
	ret

