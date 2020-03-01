include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'
format ti executable 'BOSOS'

include 'include/os.inc'
include 'include/defines.inc'
;-------------------------------------------------------------------------------
	os_create
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
	os_rom
;-------------------------------------------------------------------------------

include 'jump-table.asm'

include 'code.asm'
include 'sys.asm'
include 'gfx.asm'
include 'fs.asm'
include 'data.asm'
include 'lib_load.asm'

;@DOES Prove Riemann Hypothesis? Fail.
DONOTHING:
	ret

include 'flash.asm'

