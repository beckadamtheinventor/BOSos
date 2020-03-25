;@DOES Close an open file slot
;@INPUT A = file handle
;@DESTROYS HL,DE,BC,AF,IX
;@NOTE does nothing if A==0 or A>31
fs_Close:
	call fs_GetFileHandlePtr
	ret nc
	ex hl,de
	ld bc,8
	jq util_VoidPtr

