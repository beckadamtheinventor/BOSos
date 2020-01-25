
;VAT structure:
; Each file:
;  1b file & entry flags             +0
;  8b file name, 3b file extension   +1,+9
;  3b file pointer                   +12
;  3b file size                      +15
; End of VAT section has the first byte of the file name set to 0xFF, followed by a 3b pointer to the next VAT section
; If that pointer is null, we are at the end of the VAT.


;file handle table structure:
; Each handle:
;  1b open flags
;  3b file tell
;  3b file VAT pointer
;  1b reserved for future use


fs_read             := 1 shl 7 ; file can be read / open file for reading
fs_write            := 1 shl 6 ; file can be written / open file for writing

fs_directory        := 1 shl 2 ; file is a directory
fs_RAM              := 1 shl 1 ; file is in RAM
fs_exists           := 1 shl 0 ; file exists. If this is unset then the file has been marked for deletion

fs_open_mode_mask   := 3 shl 6 ; use this to get read/write flags. Use to compare with open flags

;@DOES get the tell of a file handle
;@INPUT A = file handle
;@OUTPUT HL = file tell
;@DESTROYS AF,BC,IX
fs_FTell:
	call sys_GetFileHandlePtr
	ld hl,(ix+1) ;file tell
	ret

;@DOES set the tell of a file handle
;@INPUT A = file handle
;@INPUT HL = offset or new tell
;@INPUT C = seek mode
;@DESTROYS All
;@NOTE acceptable seek mode values: seek from (0: start, 1: current, 2: end). Higher values will have the same effect as 2.
fs_FSeek:
	push hl
	push bc
	call sys_GetFileHandlePtr
	pop bc
	pop hl
	ld iy,(ix+4) ;VAT pointer
	ld a,c
	cp a,1 ;seek_cur
	jr nz,.next
	ld de,(ix+1) ;file tell
	add hl,de
	jr .set
.next:
	or a,a
	jr z,.set
	ex hl,de
	ld hl,(iy+15) ;file size
	or a,a
	sbc hl,de
.set:
	ld de,(iy+15) ;file size
	or a,a
	sbc hl,de
	add hl,de
	ld (ix+1),hl ;file tell
	ret


;@DOES read data from a file into a buffer
;@INPUT A = file handle
;@INPUT DE = data buffer
;@INPUT HL = bytes to read
;@OUTPUT HL = number of bytes read
;@OUTPUT Z flag set if success, else failed
;@DESTROYS All
fs_FRead:
	push de
	push hl
	call sys_GetFileHandlePtr
	bit fs_read,(ix)
	jr z,.failed
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(ix+1)  ; file tell
	ld bc,(iy+15) ; file size
	or a,a
	sbc hl,bc
	jr z,.eof
	pop bc ; read size
	or a,a
	sbc hl,bc
	add hl,bc
	jr nc,.read
	push hl
	pop bc
.read:
	ld hl,(iy+12) ; file pointer
	ld de,(ix+1)  ; file tell
	add hl,de
	pop de
	push bc
	ldir
	pop hl
	ret
.eof:
	pop hl
	pop de
	ld hl,0
	ret
.failed:
	pop hl
	pop de
	xor a,a
	inc a
	ret


;@DOES write a buffer into a file
;@INPUT A = file handle
;@INPUT DE = data buffer
;@INPUT HL = write length
;@OUTPUT Z flag if success, else failed
;@OUTPUT C flag if not enough memory or file too large
;@DESTROYS All
;@NOTE when checking the return of this call, make sure to check the Carry flag <i>first</i>
fs_FWrite:
	push de
	push hl
	call sys_GetFileHandlePtr
	ld a,(ix)
	bit fs_write,a
	jr z,.failed
	ld iy,(ix+4)  ; VAT pointer
	bit fs_RAM,a
	pop hl
	push hl
	jr z,.toRAM
	call .checkspace
	jr c,.toRAM_2
.cont:
	ld hl,(iy+12) ; file pointer
	ld de,(ix+1)  ; file tell
	add hl,de
	ex hl,de
	pop bc        ; write length
	pop hl        ; write data
	ldir
	ret
.toRAM:
	call .checkspace
.toRAM_2:
	jr nc,.movetoRAM
	ex hl,de
	ld hl,(iy+15)
	or a,a
	sbc hl,de
	ld (iy+15),hl
.movetoRAM:
	call fs_MoveFileToRAM
	jr nc,.cont
	pop hl
	pop de
	ret
.failed:
	pop hl
	pop de
	xor a,a
	inc a
	ret
.checkspace:
	ld de,(ix+1)  ; file tell
	add hl,de
	ex hl,de
	ld hl,(iy+15) ; file size
	or a,a
	sbc hl,de
	ret

;@DOES read a character from a file
;@INPUT A = file handle
;@OUTPUT C = character
;@OUTPUT C flag set if EOF reached
;@OUTPUT Z flag set if success, else failed
;@DESTROYS All
;@NOTE when checking the return of this call, make sure to check the Carry flag <i>first</i>
fs_FGetC:
	call sys_GetFileHandlePtr
	bit fs_read,(ix)
	jr z,.failed
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(ix+1)  ; file tell
	ld de,(iy+15) ; file size
	or a,a
	sbc hl,de
	add hl,de
	jr nc,.eof
	ld bc,(iy+12) ; file pointer
	add hl,bc
	ld c,(hl)
	or a,a
	sbc hl,bc
	inc hl       ; increment the file tell
	ld (ix+1),hl ; save the new file tell
	xor a,a
	ret
.eof:
	scf
	ret
.failed:
	xor a,a
	inc a
	ret


;@DOES write a character to a file
;@INPUT A = file handle
;@INPUT C = character
;@OUTPUT Z flag set if success, else failed
;@OUTPUT C flag if not enough memory or file too large
;@DESTROYS All
;@NOTE when checking the return of this call, make sure to check the Carry flag <i>first</i>
fs_FPutC:
	push bc
	call sys_GetFileHandlePtr
	ld a,(ix)
	bit fs_write,a
	jr z,.failed
	push bc
	bit fs_RAM,a
; move it to RAM
	call z,sys_MoveFileToRAM
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



;@DOES open a file and return a handle
;@INPUT HL points to file name
;@INPUT A = file open mode
;@OUTPUT C flag set if failed
;@OUTPUT A = file handle if success
;@DESTROYS All
fs_FOpen:
	or a,a
	ret z ; no open mode flags set
	ld c,a
	push bc
	call sys_FindSym
	pop bc
	jr c,.does_not_exist
	ld a,c
	or a,a
	bit fs_read,a
	jr z,.checkwrite
.tryread:
	bit fs_read,c
	jr z,.fail
.checkwrite:
	bit fs_write,a
	jr z,.fail
	bit fs_write,c
	jr z,.fail
.wecanopen:
	call sys_NextAvalibleFileSlot
	ld a,(ix)
	and a,fs_open_mode_mask
.write_handle:
	ld (de),a
	inc de
	or a,a
	sbc hl,hl
	ld (de),hl
	inc de
	inc de
	inc de
	ld (de),ix
	ld a,c
	ret
.does_not_exist:
	bit fs_write,c
	jr z,.fail
	call sys_CreateFile
	call sys_NextAvalibleFileSlot
	jr z,.write_handle
.fail:
	scf
	ret

;@DOES move a file into RAM
;@INPUT IX = file handle pointer
;@OUTPUT Z flag set if success
;@OUTPUT C flag set if malloc failed
;@DESTROYS All
;@NOTE file handle pointer returned from sys_GetFileHandlePtr
;@NOTE does nothing if the file is already in RAM
fs_MoveFileToRAM:
	bit fs_RAM,(ix)
	ret nz ;in RAM already
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(iy+15) ; file size
	push hl
	call sys_Malloc
	pop bc
	ret c
	ld hl,(iy+12) ; file data pointer
	ld (iy+12),de
	ldir
	set fs_RAM,(ix)
	xor a,a
	ret


;@DOES move a file into archive
;@INPUT IX = file handle pointer
;@OUTPUT Z flag set if success
;@OUTPUT C flag set if not enough memory
;@DESTROYS All
;@NOTE does nothing if file is already in archive
fs_MoveFileToArc:
	bit fs_RAM,(ix)
	jr z,.inarc ;in archive already
	ld iy,(ix+4)  ; VAT pointer
	ld hl,(iy+15) ; file size
	push hl
	call sys_FindFreeArcSpot
	jr c,.failed
	call flash_unlock
	pop bc
	ld hl,(iy+12) ; file data pointer
	ld (iy+12),de
	ldir
	res fs_RAM,(ix)
	call flash_lock
	xor a,a
	ret
.inarc:
	xor a,a
	inc a
	ret
.failed:
	pop hl
	ret

; returns in both HL and IX
sys_GetFileHandlePtr:
	ld hl,open_files_table-8
	call sys_AddHLAndA
	push hl
	pop ix
	ret


;find the next avalible file handle
;saves HL
;returns:
; DE = file slot handle pointer
; C = file slot
; Z flag set if success, else failed
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
;@INPUT HL = file name (8b name, 3b extension = 11 bytes)
;@INPUT DE = file size
;@OUTPUT HL = pointer to VAT entry
;@OUTPUT DE = pointer to file data section
;@OUTPUT C flag is set if failed
;@DESTROYS AF,BC
sys_CreateFile:
	ex hl,de
	ld bc,12
	add hl,bc
	push hl
	push de
	call sys_GetFreeVATEntry
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


;@DOES find a free VAT entry
;@OUTPUT DE = VAT entry
;@OUTPUT C flag is set if failed
;@DESTROYS HL,BC
sys_GetFreeVATEntry:
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


;@DOES search the VAT for a file
;@INPUT HL points to file name
;@OUTPUT DE points to VAT entry
;@OUTPUT C flag is set if failed
;@DESTROYS AF,BC
;@NOTE saves HL
sys_FindSym:
	ex hl,de
	ld hl,first_VAT_section ;first file name
	jr .entry
.loop:
	push hl ;save the current VAT pointer
	push de ;save the file name we're looking for
	ld bc,11 ;maximum file name length
	call str_n_cmp
	pop hl
	pop de
	ret z
	ex hl,de
	ld c,16 ;B and BCU should already be 0
	add hl,bc
.entry:
	ld a,(hl) ;check if we're at the end of this VAT section
	inc a
	jr nz,.loop
	inc hl
	ld de,(hl) ;check if we're at the end of the VAT
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
	ld hl,start_of_user_archive
	
	ret




