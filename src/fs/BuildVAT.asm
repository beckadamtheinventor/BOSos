;@DOES build the VAT
;@DESTROYS All
fs_BuildVAT:
	ld hl,start_of_user_archive
	scf
	ret

