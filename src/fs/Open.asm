;@DOES open a file and return a handle
;@INPUT HL points to file name
;@INPUT A = file open mode
;@OUTPUT C flag set if failed
;@OUTPUT A = file handle if success
;@DESTROYS All
fs_Open:
	or a,a
	ret z ; no open mode flags set
	ld c,a
	push bc
	call fs_FindSym
	pop bc
	jr c,.does_not_exist
	ld a,c
	or a,a
	bit fs_read_bit,a
	jr z,.checkwrite
.tryread:
	bit fs_read_bit,(ix)
	jr z,.fail
	bit fs_write_bit,a
	jr nz,.checkcanwrite
	jr .wecanopen
.checkwrite:
	bit fs_write_bit,a
	jr z,.fail
.checkcanwrite:
	bit fs_write_bit,(ix)
	jr z,.fail
.wecanopen:
	call fs_NextAvalibleFileSlot
	jr nz,.fail
	ld a,(ix)
	and a,fs_open_mode_mask
.write_handle:
	ld (de),a
	inc de
	or a,a
	sbc hl,hl
	ex hl,de
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld (hl),ix
	ld a,c
	ret
.does_not_exist:
	bit fs_write_bit,(ix)
	jr z,.fail
	call fs_CreateFile
	ret c
	call fs_NextAvalibleFileSlot
	jr z,.write_handle
.fail:
	scf
	ret
