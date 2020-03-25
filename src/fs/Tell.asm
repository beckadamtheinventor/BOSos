;@DOES get the tell of a file handle
;@INPUT A = file handle
;@OUTPUT HL = file tell
;@OUTPUT HL = -1 on fail
;@DESTROYS AF,BC,IX
fs_Tell:
	call fs_GetFileHandlePtr
	jr nc,.failed
	ld hl,(ix+1) ;file tell
	ret
.failed:
	scf
	sbc hl,hl
	ret

