;@DOES create a new file, in RAM
;@INPUT HL = file name (8b name, 3b extension = 11 bytes)
;@INPUT DE = file size
;@OUTPUT HL = pointer to VAT entry
;@OUTPUT DE = pointer to file data section
;@OUTPUT C flag is set if failed
;@DESTROYS AF,BC
fs_CreateFile:
	ex hl,de
	ld bc,12
	add hl,bc
	push hl
	push de
	call fs_GetFreeVATEntry
	jr c,.fail
	ld a,fs_write+fs_read+fs_RAM
	ld (de),a
	inc de
	pop hl     ;file name
	ld bc,11
	ldir
	push de
	ex hl,de
	pop bc     ;file size
	ld (hl),bc
	inc hl
	inc hl
	inc hl
	ld bc,11
	ex hl,de
	ldir
	pop hl
	ld bc,-12
	add hl,bc
	ret
.fail:
	pop hl
	pop de
	ret

