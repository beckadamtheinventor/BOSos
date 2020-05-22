;@DOES C function for fs_Open
;@INPUT uint8_t c_FOpen(const char *file_name, uint8_t open_mode, dir_t *directory);
;@OUTPUT A = file slot number
;@DESTROYS All
c_Open:
	ld iy,0
	add iy,sp
	ld hl,(iy+3)
	ld a,(iy+6)
	ld de,(iy+9)
	jp fs_Open

;@DOES C function for fs_Delete
;@INPUT uint8_t c_Delete(const char *file_name, dir_t *directory);
;@OUTPUT A = 0 if failed
;@DESTROYS All except IY
c_Delete:
	pop bc
	pop de
	pop hl
	push hl
	push de
	push bc
	call fs_Delete
	ccf
	sbc a,a
	ret

;@DOES C function for fs_GetC
;@INPUT int c_GetC(uint8_t handle);
;@OUTPUT on fail HL = -1
;@OUTPUT on success HL = char
;@DESTROYS All
c_GetC:
	pop bc
	pop hl
	push hl
	push bc
	ld a,l
	call fs_GetC
	jr c,.fail
	ld hl,0      ;this pains me, but I need to conserve the flags :'(
	ld l,c
	ret z
	scf
.fail:
	sbc hl,hl
	ret

;@DOES C function for fs_MoveFileToArc and fs_MoveFileToRAM
;@INPUT uint8_t c_SetArchiveStatus(uint8_t status, uint8_t handle);
;@OUTPUT A = 0 if failed or move is not required
;@DESTROYS All
c_SetArchiveStatus:
	pop bc
	pop hl
	pop de
	push de
	push hl
	push bc
	ld a,e
	push hl
	call fs_GetFileHandlePtr
	pop hl
	ld a,l
	or a,a
	jr nz,.arc
.ram:
	call fs_MoveFileToRAM
	jr .next
.arc:
	call fs_MoveFileToArc
.next:
	ccf
	sbc a,a
	ret

;@DOES C function for fs_PutC
;@INPUT uint8_t c_PutC(uint8_t char,uint8_t handle);
;@OUTPUT A = 0 if failed. Either file is too large or not enough memory
;@DESTROYS All
c_PutC:
	pop bc
	pop hl
	pop de
	push de
	push hl
	push bc
	ld a,e
	ld c,l
	call fs_PutC
	jr z,.success
	xor a,a
	ret
.success:
	xor a,a
	inc a
	ret

;@DOES C function for fs_Read
;@INPUT int c_Read(void *buffer,int len,uint8_t count,uint8_t handle);
;@OUTPUT HL = number of bytes read. zero if failed
;@DESTROYS All
c_Read:
	ld iy,0
	add iy,sp
	ld a,(iy+9)
	ld hl,(iy+6)
	call sys_MultHLA
	ld de,(iy+3)
	ld a,(iy+12)
	call fs_Read
	ret z
	xor a,a
	sbc hl,hl
	ret

;@DOES C function for fs_Write
;@INPUT int c_Write(void *buffer,int len,uint8_t count,uint8_t handle);
;@OUTPUT HL = number of bytes written. zero if failed
;@DESTROYS All
c_Write:
	ld iy,0
	add iy,sp
	ld a,(iy+9)
	ld hl,(iy+6)
	call sys_MultHLA
	ld de,(iy+3)
	ld a,(iy+12)
	call fs_Write
	ret z
	xor a,a
	sbc hl,hl
	ret


;@DOES C function for fs_Seek
;@INPUT int c_Seek(int offset,uint8_t whence,uint8_t handle);
;@OUTPUT HL = new file offset
;@DESTROYS All
c_Seek:
	ld iy,0
	add iy,sp
	ld hl,(iy+3)
	ld c,(iy+6)
	ld a,(iy+9)
	jp fs_Seek

;@DOES C function for fs_Tell
;@INPUT int c_Tell(uint8_t handle);
;@OUTPUT HL = file tell
;@DESTROYS All except IY
c_Tell:
	pop bc
	pop hl
	push hl
	push bc
	ld a,l
	jp fs_Tell

;@DOES C function for fs_Rename
;@INPUT uint8_t c_Rename(char *old_name, char *new_name, dir_t *directory);
;@OUTPUT A = 0 if failed
;@DESTROYS All
c_Rename:
	ld iy,0
	add iy,sp
	ld hl,(iy+3)
	ld bc,(iy+6)
	ld de,(iy+9)
	call fs_Rename
	ccf
	sbc a,a
	ret

;@DOES C function for fs_CloseAll
;@INPUT void c_CloseAll(void);
;@DESTROYS HL,DE,BC,AF
c_CloseAll:=fs_CloseAll

;@DOES C function for fs_Close
;@INPUT void c_Close(uint8_t handle);
;@DESTROYS HL,DE,BC,AF
c_Close:
	pop bc
	pop hl
	push hl
	push bc
	ld a,l
	jp fs_Close

;@DOES C function for fs_Resize
;@INPUT void c_Resize(int size,uint8_t handle);
;@DESTROYS HL,DE,BC,AF,IX
c_Resize:
	pop de
	pop hl
	pop bc
	push bc
	push hl
	push de
	ld a,c
	jr fs_Resize

;@DOES check if a file is archived
;@INPUT uint8_t c_IsArchived(uint8_t handle);
;@DESTROYS HL,DE,BC,AF,IX
c_IsArchived:
	pop hl
	pop bc
	push bc
	push hl
	ld a,c
	call fs_GetFileHandlePtr
	ret nc
	ld hl,(ix+fs_handle_vat)
	bit fs_RAM_bit,(hl)
	jr z,.inRAM
	xor a,a
	inc a
	ret
.inRAM:
	xor a,a
	ret

;@DOES reset the tell of a file handle
;@INPUT void c_Rewind(uint8_t handle);
;@DESTROYS HL,DE,BC,AF,IX
c_Rewind:
	pop hl
	pop bc
	push bc
	push hl
	ld a,c
	call fs_GetFileHandlePtr
	ret nc
	or a,a
	sbc hl,hl
	ld (ix+fs_handle_tell),hl
	ret

;@DOES get the size of a file
;@INPUT int c_GetSize(uint8_t handle);
;@DESTROYS HL,DE,BC,AF,IX
c_GetSize:
	pop hl
	pop bc
	push bc
	push hl
	ld a,c
	call fs_GetFileHandlePtr
	ret nc
	ld ix,(ix+fs_handle_vat)
	ld hl,(ix+fs_vat_len)
	ret

