

;@DOES Input a string of HL bytes from user input
;@INPUT HL input length
;@INPUT DE input buffer
;@OUTPUT HL length of user input
;@DESTROYS IX,BC
sys_InputString:
	ld ix,0
	add ix,sp
	add hl,de
	push hl
	push de
	push de
	xor a,a
	sbc hl,hl
	push hl
	ld hl,(ix+6)
	ld (hl),a
	jr .loop
.nextover:
	ld a,(ix+3)
	inc a
	cp a,3
	jr nz,.setover
	xor a,a
.setover:
	ld (ix+3),a
	jr .loop
.prevover:
	ld a,(ix+3)
	or a,a
	jr nz,.setover2
	ld a,4
.setover2:
	dec a
	ld (ix+3),a
	jr .loop
.char:
	ld de,(ix+12)
	ld hl,(ix+6)
	sbc hl,de
	jr nc,.loop
	or a,a
	sbc hl,hl
	ld l,(ix+3)
	add hl,hl
	add hl,hl
	ex hl,de
	ld hl,data_key_map
	add hl,de
	ld hl,(hl)
	call sys_AddHLAndA
	ld a,(de)
	ld (ix+4),a
	ld a,(hl)
	ld hl,(ix+6)
	ld (hl),a
	inc hl
	xor a,a
	ld (hl),a
	ld (ix+6),hl
.loop:
	ld hl,(lcd_x)
	ld a,(lcd_y)
	push hl
	push af
	ld hl,(ix+9)
	call gfx_PutS
	ld a,(ix+4)
	call lcd_char
	pop af
	pop hl
	ld (lcd_x),hl
	ld (lcd_y),a
	call sys_GetKey
	cp a,54
	jr z,.prevover
	cp a,9
	jr z,.done
	jr c,.loop
	cp a,48
	jr z,.nextover
	jr nc,.loop
	cp a,15
	jr nz,.char
	ld hl,(ix+6)
	xor a,a
	ld (hl),a
.done:
	pop bc
	pop bc
	pop de
	pop hl
	ret

;-------------------------------------------------------------------------------
;@DOES Scans the keypad and updates data registers
;@NOTE Disables interrupts during execution, and restores on exit
;@DESTROYS HL,AF
kb_Scan:
	di
	ld	hl,$f50200		; DI_Mode = $f5xx00
	ld	(hl),h
	xor	a,a
.loop:
	cp	a,(hl)
	jr	nz,.loop
	ret

;-------------------------------------------------------------------------------
;@DOES Scans the keypad and updates data registers; checking if a key was pressed
;@NOTE Disables interrupts during execution
;@DESTROYS HL,AF
;@OUTPUT 0 if no keys pressed
kb_AnyKey:
	di
	ld	hl,$f50200		; DI_Mode = $f5xx00
	ld	(hl),h
	xor	a,a
.loop:
	cp	a,(hl)
	jr	nz,.loop
	ld	l,$12			; kbdG1 = $f5xx12
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	ret

;@DOES Wait until a key is pressed and return it
;@DESTROYS HL,DE,BC,AF
sys_WaitKey:
	call kb_AnyKey
	jr z,sys_WaitKey

;@DOES Wait until a key is pressed, then wait until it's released, then return the keycode
;@DESTROYS HL,DE,BC,AF
sys_WaitKeyAndUnpress:
	call kb_AnyKey
	jr z,sys_WaitKeyAndUnpress
.loop:
	call kb_AnyKey
	jr nz,.loop
	ret

;@DOES Return current keypress
;@OUTPUT A keypress
;@OUTPUT z if no key pressed
;@DESTROYS HL,DE,BC,AF
sys_GetKey:
	call kb_Scan
	ld hl,$F50012
.loop:
	cp a,(hl)
	jr nz,.loop
	ld b,7
	ld c,49
.scanloop:
	ld a,(hl)
	or a,a
	jr nz,.keyispressed
	inc hl
	inc hl
	ld a,c
	sub a,8
	ld c,a
	djnz .scanloop
	xor a,a
	ret
.keyispressed:
	ld b,8
.keybitloop:
	rrca
	jr c,.this
	inc c
	djnz .keybitloop
.this:
	ld a,c
	ret

;@DOES Clear text shadow
;@OUTPUT _TextShadow reset to null
;@DESTROYS HL,DE,BC,AF
sys_ClearTextShadow:
	ld hl,_TextShadow          ;clear textshadow
	ld bc,_TextShadow_len
	xor a,a
	;flow into the next routine -> memset

;@DOES set BC bytes of HL to the value A
;@INPUT HL pointer to set
;@INPUT BC amount to set
;@INPUT A byte to set memory to
;@OUTPUT HL HL+BC
;@OUTPUT DE HL+BC+1
;@DESTROYS AF
sys_MemSet:
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	ret

;@DOES Allocate memory
;@INPUT HL = number of bytes to malloc
;@OUTPUT DE = malloc'd bytes
;@OUTPUT C flag set if failed
;@DESTROYS AF,DE
sys_Malloc:
	ld de,(remaining_free_RAM)
	or a,a
	ex hl,de
	sbc hl,de
	ret c
	ld (remaining_free_RAM),hl
	ld hl,(free_RAM_ptr)
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ex hl,de
	add hl,de
	ld (free_RAM_ptr),hl
	or a,a
	ret

;@DOES Free a block of memory returned by sys_Malloc
;@INPUT HL = memory to free
;@DESTROYS AF,DE
sys_Free:
	dec hl
	dec hl
	dec hl
	ld de,(hl)
	push de
	ld de,0
	ld (hl),de
	pop de
	inc hl
	inc hl
	inc hl
	ld (hl),de
	ret

;@DOES HL+=A
;@INPUT HL number
;@INPUT A increment
;@OUTPUT HL number+increment
;@DESTROYS AF
sys_AddHLAndA:
	push bc
	ld	bc,0
	ld	c,a
	add	hl,bc
	pop bc
	ret

;@DOES find length of null-terminated string
;@INPUT HL pointer to string
;@OUTPUT BC length of string
;@DESTROYS AF
str_len:
	push hl
	ld bc,0
	xor a,a
.loop:
	cpir
	sbc hl,hl
	sbc hl,bc
	push hl
	pop bc
	pop hl
	ret

;@DOES set the bytes of null-terminated string
;@INPUT HL pointer to string
;@INPUT C value to set bytes to
;@OUTPUT HL HL+strlen(HL)
;@DESTROYS AF
str_set:
	xor a,a
.loop:
	cp a,(hl)
	ret z
	ld (hl),c
	inc hl
	jr .loop


;@DOES copy null-terminated string
;@INPUT HL pointer to null-terminated string
;@INPUT DE pointer to destination
;@OUTPUT HL pointer to null-terminated string
;@OUTPUT DE DE+HL+strlen(HL)
;@OUTPUT BC BC-strlen(HL)
;@DESTROYS AF
str_cpy:
	xor a,a
	ld bc,0
.loop:
	cp a,(hl)
	ldi
	jr nz,.loop
	ex hl,de
	add hl,bc
	ret

;@DOES copy null-terminated string, with maximum copy amount
;@INPUT HL pointer to null-terminated string
;@INPUT DE pointer to destination
;@INPUT BC maximum bytes to copy
;@OUTPUT HL pointer to null-terminated string
str_n_cpy:
	xor a,a
.loop:
	cp a,(hl)
	ldi
	ret po
	jr nz,.loop
	ex hl,de
	add hl,bc
	ret


;@DOES convert a string to uppercase
;@INPUT HL pointer to string
;@OUTPUT HL HL+strlen(HL)
;@DESTROYS AF
str_upper:
.loop:
	ld (hl),a
.next:
	inc hl
str_upper:
	ld a,(hl)
	or a,a
	ret z
	sub a,'a'
	cp a,26
	jr nc,_str_upper.next
	add a,'A'
	jr _str_upper.loop

;@DOES convert a string to lowercase
;@INPUT HL pointer to string
;@OUTPUT HL HL+strlen(HL)
;@DESTROYS AF
str_lower:
.loop:
	ld (hl),a
.next:
	inc hl
str_lower:
	ld a,(hl)
	or a,a
	ret z
	sub a,'A'
	cp a,26
	jr nc,_str_lower.next
	add a,'a'
	jr _str_lower.loop

;@DOES compare two strings
;@INPUT HL pointer to string
;@INPUT DE pointer to string
;@OUTPUT return z if the strings are equal, else nz
;@OUTPUT BC BC-min(strlen(HL),strlen(DE))
str_cmp:
	ld a,(de)
	or a,a
	ret z
	inc de
	cpi
	jr z,str_cmp
	ret

;@DOES compare two strings, stopping at the maximum length
;@INPUT HL pointer to string
;@INPUT DE pointer to string
;@INPUT BC maximum string length
;@OUTPUT return z if the strings are equal, else nz
;@DESTROYS AF
str_n_cmp:
	ld a,(de)
	or a,a
	ret z
	inc de
	cpi
	jp po,.fail
	jr z,str_cmp
	ret
.fail:
	xor a,a
	inc a
	ret


