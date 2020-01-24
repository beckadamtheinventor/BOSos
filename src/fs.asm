
;VAT structure:
; Each file:
;  9b file name
;  1b file flags
;  3b file pointer
;  1b file size (in 256 byte sectors)
; End of VAT section has the first byte of the file name set to 0xFF, followed by a 3b pointer to the next VAT section
; If that pointer is null, we are at the end of the VAT.

;first VAT section size is optimally 256 entries long


fs_read             := 1 shl 7 ; file can be read / open file for reading
fs_write            := 1 shl 6 ; file can be written / open file for writing

fs_RAM              := 1 shl 1 ; file is in RAM
fs_exists           := 1 shl 0 ; file exists. If this is unset then the file has been marked for deletion

fs_file_prop_mask   := 3 shl 6 ; use this to get read/write flags. Use to compare with open flags

;@DOES read a character from a file
;@INPUT A file handle
;@OUTPUT C character
;@DESTROYS AF,DE,HL
fs_FGetC:
	ld hl,open_files_table-8
	call sys_AddHLAndA
	




;@DOES open a file and return a handle
;@INPUT HL points to file name
;@INPUT A file open mode
;@OUTPUT - C flag set if failed
;@OUTPUT A open mode flags that couldn't be applied to the file (only if C flag set)
;@OUTPUT A file handle (only if C flag not set)
fs_FOpen:
	or a,a
	ret z ; no open mode flags set
	ld c,a
	push bc
	call sys_FindSym
	pop bc
	jr c,.does_not_exist
	ld a,c
	ld bc,9
	add hl,bc
	ld c,(hl)
	or a,a
	sbc hl,bc
	bit fs_read,a
	jr nz,.tryread
.checkwrite:
	bit fs_write
	jr nz,.trywrite
.wecanopen:
	push hl ; file VAT entry
	ld l,a  ; save the file mode
	ld a,c
	and a,-fs_file_prop_mask
	or a,l
	ld l,a  ; now we have merged the desired file properties
	push hl
	call sys_NextAvalibleFileSlot
	pop hl
	ld a,l
	ld (de),a ; set the file handle's file properties
	inc de
	pop hl
	ld (de),hl ; set the file handle's VAT entry
	inc de
	inc de
	inc de
	or a,a
	sbc hl,hl
	ld (de),hl ; set the file handle's file tell
	ld a,c
	ret
.tryread:
	bit fs_read,c
	jr z,.fail
	jr .checkwrite
.trywrite:
	bit fs_write,c
	jr z,.fail
	jr .wecanopen
.does_not_exist:
	bit fs_write,c
	jr z,.fail
	call sys_CreateFile
	call sys_NextAvalibleFileSlot
	jr nz,.fail
	ld (de),a
	inc de
	ld (de),hl
	xor a,a
	ld a,c
	ret
.fail:
	scf
	ret


;@DOES find the next avalible file handle
;@OUTPUT DE handle
;@OUTPUT C file slot
;@OUTPUT Z flag set if success, else failed
sys_NextAvalibleFileSlot:
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


;@DOES create a new file, in RAM
;@INPUT HL file name
;@INPUT A number of sectors to reserve
;@OUTPUT HL pointer to VAT entry
;@OUTPUT DE pointer to file data section
sys_CreateFile:
	ld de,(free_VAT_entry_ptr)
	push de
	push hl
	push af
	ld bc,9
	ldir
	ld a,fs_write+fs_read
	ld (de),a
	inc de
	pop af
	ld (de),a
	inc de
	ld hl,(next_free_RAM)
	push hl
	call sys_AddHLAndASectors
	ld (next_free_RAM),hl
	pop de
	pop hl
	call sys_str_cpy
	pop hl
	ret

;@DOES search the VAT for a file
;@INPUT HL points to file name
;@OUTPUT DE points to VAT entry
;@OUTPUT C flag is set if failed
;@DESTROYS AF,BC
sys_FindSym:
	ex hl,de
	ld hl,first_VAT_section ;first file name
	jr .entry
.loop:
	push hl ;save the file name we're looking for
	push de
	ld bc,9 ;maximum file name length
	call str_n_cmp
	pop de
	pop hl
	ret z
	ex hl,de
	ld c,9 ;B and BCU should already be 0
	add hl,bc
	ld c,5
	add hl,bc
.entry:
	ld a,(hl) ;check if we're at the end of this VAT section
	inc a
	jr nc,.loop
	inc hl
	ld de,(hl)
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

;@DOES build the VAT
;@DESTROYS All
sys_BuildVAT:
	
	ret




