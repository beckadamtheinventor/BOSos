;@DOES Allocate space for a file, defragmenting RAM as needed
;@INPUT HL = bytes to alloc
;@OUTPUT DE = allocated space
;@NOTE can move files around in RAM, and will update VAT pointers if so.
;@NOTE does not damage malloc'd memory, but will likely change its pointer.
fs_Alloc:
	push hl
	ex hl,de
	ld bc,(free_file_RAM_ptr)
	ld hl,end_of_file_RAM
	or a,a
	sbc hl,bc
	or a,a
	sbc hl,de
	call c,fs_RAMCollect
	pop bc
	ld hl,(free_file_RAM_ptr)
	push hl
	add hl,bc
	ld (free_file_RAM_ptr),hl
	ld hl,(remaining_file_RAM)
	or a,a
	sbc hl,bc
	ld (remaining_file_RAM),hl
	pop de
	ret

