;@DOES get the tell of a file handle
;@INPUT A = file handle
;@OUTPUT HL = file tell
;@DESTROYS AF,BC,IX
fs_Tell:
	call fs_GetFileHandlePtr
	ld hl,(ix+1) ;file tell
	ret
