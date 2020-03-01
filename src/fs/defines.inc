fs_read_bit         := 7
fs_write_bit        := 6
fs_directory_bit    := 2
fs_RAM_bit          := 1
fs_exists_bit       := 0

fs_read             := 1 shl 7 ; file can be read / open file for reading
fs_write            := 1 shl 6 ; file can be written / open file for writing

fs_directory        := 1 shl 2 ; file is a directory
fs_RAM              := 1 shl 1 ; file is in RAM
fs_exists           := 1 shl 0 ; file exists. If this is unset then the file has been marked for deletion

fs_open_mode_mask   := 3 shl 6 ; use this to get read/write flags. Use to compare with open flags

