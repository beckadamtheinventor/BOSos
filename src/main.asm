include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'
format ti executable 'BOSOS'

include 'include/os.inc'
include 'include/defines.inc'

call ti.HomeUp
ld hl,installing_string
call ti.PutS

;-------------------------------------------------------------------------------
	os_create
;-------------------------------------------------------------------------------

installing_string:
	db "Installing BOS...",0

;-------------------------------------------------------------------------------
	os_rom
;-------------------------------------------------------------------------------

include 'jump-table.asm'

include 'code.asm'
include 'sys.inc'
include 'gfx.inc'
include 'fs.inc'
include 'str.inc'
include 'util.inc'
include 'lib.inc'
include 'lib_load.asm'

;@DOES Prove Riemann Hypothesis? Fail.
DONOTHING:
	ret

include 'flash.asm'
include 'data.asm'

