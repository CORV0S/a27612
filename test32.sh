#!/bin/bash
#for testing assembly
#usage: ./test32.sh [filename no filetype]
fname=$1

nasm -f elf -g $fname.asm
ld -m elf_i386 -o $fname $fname.o

./$fname
