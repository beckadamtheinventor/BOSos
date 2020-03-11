;@DOES Erase flash sector
;@INPUT A sector to erase
;@DESTROYS All
;@NOTE calls boot routine $2DC
sys_EraseFlashSector:
	ld hl,$F8
	push hl
	jp $2DC
