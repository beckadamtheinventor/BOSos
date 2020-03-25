;@DOES increase the size of a file
;@INPUT IX = pointer to file slot
;@INPUT HL = amount to increase file size by
;@OUTPUT C flag is set if failed
fs_IncreaseFileSize:
	ld iy,(ix+4) ;VAT pointer
	ld bc,(iy+15) ;file size
	add hl,bc
	ld (iy+15),hl
	jq fs_CopyFileToRAM.entry

