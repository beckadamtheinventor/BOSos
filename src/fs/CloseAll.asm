;@DOES Close all file slots
;@INPUT A = file handle
;@DESTROYS HL,DE,BC,AF
fs_Close:
	ld de,open_files_table
	ld bc,8
	jq util_VoidPtr

