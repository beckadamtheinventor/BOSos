;@DOES build the VAT
;@DESTROYS All
sys_BuildVAT:
	ld hl,start_of_user_archive
	
	ret

