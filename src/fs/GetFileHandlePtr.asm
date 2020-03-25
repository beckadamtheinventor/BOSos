; returns in both HL and IX
; return carry if success
fs_GetFileHandlePtr:
	or a,a
	ret z
	cp a,$20
	ret nc
	ld hl,open_files_table-8
	rlca
	rlca
	rlca
	call sys_AddHLAndA
	push hl
	pop ix
	scf
	ret

