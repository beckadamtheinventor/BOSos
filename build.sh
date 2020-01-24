#!/bin/bash
#----------------------------------------
#Put your program name in place of "DEMO"
name='BOSOS.8xp'
#----------------------------------------

mkdir "bin"

echo "compiling to $name"
fasmg src/main.asm bin/$name
echo $name
echo "Wrote binary to $name."

echo "----------------------------------------"
echo "building bos.inc"
echo "----------------------------------------"
python3 build_bos.inc.py
echo "building \"docs/\" folder"
echo "----------------------------------------"
python3 build_docs.py
read -p "Finished. Press any key to exit"
