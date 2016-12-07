#!/bin/bash

echo '[+] Assembling with Nasm'
nasm -f elf32 -o $1.o $1.nasm

echo '[+] Linking'
ld -z execstack -o $1 $1.o

echo '[+] Extracting Opcodes'
shellcode=$(objdump -d ./$1|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g';)

echo $shellcode

length=$(printf "%s" "$shellcode"|wc -c)

echo "[+] Size: $(( length / 4)) bytes"
