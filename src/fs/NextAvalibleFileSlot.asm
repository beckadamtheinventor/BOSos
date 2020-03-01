;find the next avalible file handle
;saves HL
;returns:
; DE = file slot handle pointer
; C = file slot
; Z flag set if success, else failed
fs_NextAvalibleFileSlot:
	push hl
	ld de,open_files_table
	ld c,1
	ld hl,8 ; length of file handle
.loop:
	ld a,(de)
	or a,a
	jr z,.success
	inc a
	jr z,.fail
	inc c
	ex hl,de
	add hl,de
	ex hl,de
	jr .loop
.success:
	pop hl
	ret
.fail:
	pop hl
	inc a
	ret

