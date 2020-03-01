;@DOES write a character to a file
;@INPUT A = file handle
;@INPUT C = character
;@OUTPUT Z flag set if success, else failed
;@OUTPUT C flag if not enough memory or file too large
;@DESTROYS All
;@NOTE when checking the return of this call, make sure to check the Carry flag <i>first</i>
fs_PutC:
	push bc
	call sys_GetFileHandlePtr
	ld a,(ix)
	bit fs_write_bit,a
	jr z,.failed
	push bc
	bit fs_RAM_bit,a
; move it to RAM
	call z,fs_MoveFileToRAM
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(iy+15) ; file size
	ld de,(ix+1)  ; file tell
	or a,a
	sbc hl,bc
	add hl,bc
	jr c,.putc
.eof:
	push hl
	inc hl
	call sys_Malloc
	pop bc
	jr c,.nomem
	ld hl,(iy+12) ; file pointer
	ldir
	ex hl,de
	jr .putc_entry
.putc:
	ld de,(iy+15) ; file pointer
	add hl,de
.putc_entry:
	pop bc
	ld (hl),c
	inc hl
	or a,a
	sbc hl,de
	inc hl       ; increment the file tell
	ld (ix+1),hl ; save the new file tell
	xor a,a
	ret
.nomem:
	pop bc
	scf
	ret
.failed:
	xor a,a
	inc a
	ret

