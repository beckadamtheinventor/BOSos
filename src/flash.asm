
;heapBot:=$D1887C

;write_port:
;	ld	de,$C979ED
;	ld	hl,heapBot - 3
;	ld	(hl),de
;	jp	(hl)

;read_port:
;	ld	de,$C978ED
;	ld	hl,heapBot - 3
;	ld	(hl),de
;	jp	(hl)


; since we're an OS, we can use the in/out instructions

;@DOES unlock flash
;@DESTROYS AF,BC
flash_unlock:
	ld	bc,$24
	ld	a,$8c
	out (bc),a
	ld	bc,$06
	in	a,(bc)
	or	a,4
	out (bc),a
	ld	bc,$28
	ld	a,$4
	out (bc),a
	ret

;@DOES lock flash
;@DESTROYS AF,BC
flash_lock:
	ld	bc,$28
	xor	a,a
	out (bc),a
	ld	bc,$06
	in a,(bc)
	res	2,a
	out (bc),a
	ld	bc,$24
	ld	a,$88
	out (bc),a
	ret

