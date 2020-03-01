;@DOES find a spot in archive suitable for a file
;@INPUT IX = file handle pointer
;@OUTPUT C flag set if failed
;@DESTROYS All
;@NOTE Just sets carry flag for now. Haven't made the actual routine yet.
sys_FindFreeArcSpot:
	scf
	ret

