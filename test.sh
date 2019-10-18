#!/bin/bash
#for testing assembly
#usage: ./test.sh [filename no filetype]
fname=$1

nasm -f elf64 -o $fname.o $fname.asm
ld $fname.o -o $fname

./$fname
