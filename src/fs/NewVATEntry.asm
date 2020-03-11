;@DOES Create a new VAT entry
;@INPUT HL = 8.3 file name
;@INPUT DE = pointer to directory to put the entry
;@OUTPUT C flag set if failed
;@OUTPUT IX = new VAT entry
fs_NewVATEntry:
	scf
	ret

