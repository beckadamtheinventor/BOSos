;-------------------------------------------------------------------------------
; some data stored in rom since not much point copying to ram
include 'font.asm'

data_key_map:
	dl data_key_map_0
	db 'a'
	dl data_key_map_1
	db 'A'
	dl data_key_map_2
	db '1'

data_key_map_0:
	db 0,'"wrmh',0,0
	db '?!vqlg@',0
	db ':zupkfc',0
	db ' ytojeb',0
	db 0,'xsnida'
data_key_map_1:
	db 0,'"WRMH',0,0
	db '?!VQLG#',0
	db ':ZUPKFC',0
	db ' YTOJEB',0
	db 0,'XSNIDA'
data_key_map_2:
	db 0,'+-*/^',0,0
	db '~369)&$',0
	db '.258(]}',0
	db '0147,[{',0
	db 0,$1A,"<=>\\'"


data_strings:
.hello_world:
	db "Hello World!",0
.welcome_to_bos:
	db "Welcome to BOS!",0
.happy_emoji:
	db ":D",0
.lets_start:
	db "Let's Start!",0

;-------------------------------------------------------------------------------

