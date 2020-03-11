fs_read_bit         := 7
fs_write_bit        := 6
fs_system_bit       := 3
fs_dir_bit          := 2
fs_RAM_bit          := 1
fs_exists_bit       := 0

fs_read             := 1 shl 7 ; file can be read / open file for reading
fs_write            := 1 shl 6 ; file can be written / open file for writing

fs_system           := 1 shl 3 ; file is a system file. Probably shouldn't be displayed in file browsers.
fs_dir              := 1 shl 2 ; file is a directory
fs_RAM              := 1 shl 1 ; file is in RAM
fs_exists           := 1 shl 0 ; file exists. If this is unset then the file has been marked for deletion

fs_open_mode_mask   := 3 shl 6 ; use this to get read/write flags. Use to compare with open flags


fs_vat_flags        := 0
fs_vat_name         := 1
fs_vat_ext          := 9
fs_vat_ptr          := 12
fs_vat_len          := 15


fs_handle_flags     := 0
fs_handle_tell      := 1
fs_handle_vat       := 4
fs_handle_unused    := 7


fs_file_flags       := 0
fs_file_name        := 1
fs_file_ext         := 9
fs_file_parent      := 12
fs_file_len         := 15
fs_file_data        := 18

