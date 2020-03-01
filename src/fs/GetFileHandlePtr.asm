; returns in both HL and IX
fs_GetFileHandlePtr:
	ld hl,open_files_table-8
	call sys_AddHLAndA
	push hl
	pop ix
	ret

