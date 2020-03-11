;@DOES Wait until a key is pressed, then wait until it's released, then return the keycode
;@OUTPUT A = keycode
;@DESTROYS HL,DE,BC,AF
sys_WaitKeyCycle:
	call sys_GetKey
	jr z,sys_WaitKeyCycle
	push af
.loop:
	call kb_AnyKey
	jr z,.loop
	pop af
	ret

