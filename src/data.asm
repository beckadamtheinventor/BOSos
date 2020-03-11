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

os_config_file_dir:=os_root_dir
os_config_file:
	db fs_system+fs_read+fs_exists,'config',0,0,'dat'
os_root_dir:
	db fs_system+fs_dir+fs_read+fs_exists, 'sys',0,0,0,0,0,   'dir'
	dl 0,0
	db fs_system+fs_dir+fs_read+fs_exists, 'config',0,0,     'dir'
	dl 0,0
	db fs_dir+fs_read+fs_write+fs_exists,  'home',0,0,0,0,   'dir'
	dl 0,0
	db fs_dir+fs_read+fs_write+fs_exists,  'share',0,0,0,0,  'dir'
	dl 0,0
	db fs_dir+fs_read+fs_write+fs_exists,  'bin',0,0,0,0,0,  'dir'
	dl 0,0
	db fs_dir+fs_read+fs_write+fs_exists,  'lib',0,0,0,0,0,  'dir'
	dl 0,0
	db fs_dir+fs_read+fs_write+fs_exists,  'usr',0,0,0,0,0,  'dir'
	dl 0,0
	db fs_dir+fs_read+fs_write+fs_exists,  'tmp',0,0,0,0,0,  'dir'
	dl 0,0
	db $FF,$FF,$FF,$FF
.len:=$-os_root_dir

defaultflags:
	db $BF,$00,$BF,$00
	dl data_font_spacing,data_font_data
	dl 0,0,0,0,0,0
	db 0,0,0,0,0,0

data_strings:
.hello_world:
	db "Hello World!",0
.welcome_to_bos:
	db "Welcome to BOS!",0
.happy_emoji:
	db ":D",0
.lets_start:
	db "Let's Start!",0



