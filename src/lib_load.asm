
;@DOES load dynamic libraries, such as GraphX
;@INPUT A the file handle to the library to load
;@INPUT DE points to lib functions to load
;@OUTPUT C flag is set if failed
;@OUTPUT HL points to start of lib function jump table
dynamic_lib_load:
	push de
	ld de,(free_RAM_ptr)
	call fs_Read
	ld (free_RAM_ptr),de
	pop de
	scf
	ret




