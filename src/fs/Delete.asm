;@DOES mark a file for deletion
;@INPUT HL = file name
;@OUTPUT carry flag is set if failed.
;@NOTE you can do this in software by resetting the fs_exists bit of a VAT entry's flag byte.
fs_Delete:
	call fs_FindSym
	ret c
	ex hl,de
	res fs_exists,(hl)
	ret
