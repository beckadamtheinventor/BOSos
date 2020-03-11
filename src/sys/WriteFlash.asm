;@DOES write BC bytes to flash from HL to DE.
;@INPUT HL, DE, BC
;@NOTE flash must be unlocked prior to use
;@NOTE this is a boot call
sys_WriteFlash:=$2E0
