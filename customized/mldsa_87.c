#include <jni.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <openssl/evp.h>
#include <oqs/oqs.h>

#define MESSAGE_LEN 100
#define PREFIX_LEN 5 // bytes

OQS_STATUS rc;

// array for size_t to bytes
uint8_t st2bytes[8];

uint8_t public_key[OQS_SIG_ml_dsa_87_length_public_key];
uint8_t secret_key[OQS_SIG_ml_dsa_87_length_secret_key];
uint8_t message[MESSAGE_LEN];
uint8_t signature[OQS_SIG_ml_dsa_87_length_signature];
size_t message_len = MESSAGE_LEN;
size_t signature_len;

/* Cleaning up memory etc */
void cleanup_stack(uint8_t *secret_key, size_t secret_key_len);

// Function to compute SHA-256 hash of a string
void sha256(const uint8_t *text, uint8_t *md) {
  EVP_MD_CTX *mdctx;
  const EVP_MD *md_type;
  
  md_type = EVP_sha256();
  mdctx = EVP_MD_CTX_new();
  EVP_DigestInit_ex(mdctx, md_type, NULL);
  EVP_DigestUpdate(mdctx, text, strlen(text));
  EVP_DigestFinal_ex(mdctx, md, NULL);
  EVP_MD_CTX_free(mdctx);
}

bool same_prefix(uint8_t stra[], uint8_t *strb, size_t prefix_length) {
  for (size_t i = 0; i < prefix_length; i++) {
    if (stra[i] != strb[i]) return false;
  }
  return true;
}

void convert_size_t_to_uint8_array(size_t x, uint8_t array[8]) {
  memset(array, 0, 8);
  for (int i = 0; i < 8; i++) {
      array[i] = (uint8_t)(x >> (8 * i) & 0xFF);
  }
}

jbyteArray genKey(JNIEnv *env) {
  rc = OQS_SIG_ml_dsa_87_keypair(public_key, secret_key);

  if (rc != OQS_SUCCESS) {
      fprintf(stderr, "ERROR: OQS_SIG_ml_dsa_87_keypair failed!\n");
      cleanup_stack(secret_key, OQS_SIG_ml_dsa_87_length_secret_key);
  }

  jbyteArray jResult = (*env)->NewByteArray(env, OQS_SIG_ml_dsa_87_length_public_key + OQS_SIG_ml_dsa_87_length_secret_key);
  if (jResult == NULL) {
      return NULL;
  }

  (*env)->SetByteArrayRegion(env, jResult, 0, OQS_SIG_ml_dsa_87_length_public_key, (const jbyte *)public_key);
  (*env)->SetByteArrayRegion(env, jResult, OQS_SIG_ml_dsa_87_length_public_key, OQS_SIG_ml_dsa_87_length_secret_key, (const jbyte *)secret_key);

  return jResult;
}

jbyteArray sign(JNIEnv *env, jbyte *input) {
  // Extract secret key
  for (size_t i = PREFIX_LEN; i < PREFIX_LEN + OQS_SIG_ml_dsa_87_length_secret_key; i++) {
    secret_key[i - PREFIX_LEN] = input[i];
  }

  // Extract message
  for (size_t i = PREFIX_LEN + OQS_SIG_ml_dsa_87_length_secret_key; i < PREFIX_LEN + OQS_SIG_ml_dsa_87_length_secret_key + MESSAGE_LEN; i++) {
    message[i - (PREFIX_LEN + OQS_SIG_ml_dsa_87_length_secret_key)] = input[i];
  }

  rc = OQS_SIG_ml_dsa_87_sign(signature, &signature_len, message, message_len, secret_key);

  if (rc != OQS_SUCCESS) {
      fprintf(stderr, "ERROR: OQS_SIG_ml_dsa_87_sign failed!\n");
      cleanup_stack(secret_key, OQS_SIG_ml_dsa_87_length_secret_key);
  }

  jbyteArray jResult = (*env)->NewByteArray(env, OQS_SIG_ml_dsa_87_length_signature + 8);
  if (jResult == NULL) {
      return NULL;
  }

  convert_size_t_to_uint8_array(signature_len, st2bytes);

  (*env)->SetByteArrayRegion(env, jResult, 0, OQS_SIG_ml_dsa_87_length_signature, (const jbyte *)signature);
  (*env)->SetByteArrayRegion(env, jResult, OQS_SIG_ml_dsa_87_length_signature, 8, (const jbyte *)st2bytes);

  return jResult;
}

jbyteArray verify(JNIEnv *env, jbyte *input) {
  // Extract public key
  for (size_t i = PREFIX_LEN; i < PREFIX_LEN + OQS_SIG_ml_dsa_87_length_public_key; i++) {
    public_key[i - PREFIX_LEN] = input[i];
  }

  // Extract message
  for (size_t i = PREFIX_LEN + OQS_SIG_ml_dsa_87_length_public_key; i < PREFIX_LEN + OQS_SIG_ml_dsa_87_length_public_key + MESSAGE_LEN; i++) {
    message[i - (PREFIX_LEN + OQS_SIG_ml_dsa_87_length_public_key)] = input[i];
  }

  // Extract signature
  for (size_t i = PREFIX_LEN + OQS_SIG_ml_dsa_87_length_public_key + MESSAGE_LEN; i < PREFIX_LEN + OQS_SIG_ml_dsa_87_length_public_key + MESSAGE_LEN + OQS_SIG_ml_dsa_87_length_signature; i++) {
    signature[i - (PREFIX_LEN + OQS_SIG_ml_dsa_87_length_public_key + MESSAGE_LEN)] = input[i];
  }

  signature_len = OQS_SIG_ml_dsa_87_length_signature;
  rc = OQS_SIG_ml_dsa_87_verify(message, message_len, signature, signature_len, public_key);

  jbyteArray jResult = (*env)->NewByteArray(env, 1);
  if (jResult == NULL) {
      return NULL;
  }

  uint8_t verifyStatus[1] = {1};

  if (rc != OQS_SUCCESS) {
    fprintf(stderr, "ERROR: OQS_SIG_ml_dsa_87_verify failed!\n");
    cleanup_stack(secret_key, OQS_SIG_ml_dsa_87_length_secret_key);
    verifyStatus[0] = 0;
  }

  (*env)->SetByteArrayRegion(env, jResult, 0, 1, (const jbyte *)verifyStatus);

  return jResult;
}

JNIEXPORT jbyteArray JNICALL Java_org_hyperledger_besu_evm_precompile_MLDSA87PrecompiledContract_processWithNative
  (JNIEnv *env, jobject obj, jbyteArray input) {

  jsize length = (*env)->GetArrayLength(env, input);
  jbyte *inputBytes = (*env)->GetByteArrayElements(env, input, NULL);

  printf("Input: ");
  for (jsize i = 0; i < length; i++) {
    printf(" %d", inputBytes[i]);
  }
  printf("\n");

  uint8_t genKeyFnHash[EVP_MAX_MD_SIZE], signFnHash[EVP_MAX_MD_SIZE], verifyFnHash[EVP_MAX_MD_SIZE];
  sha256("genKey(bytes)", genKeyFnHash);
  sha256("sign(bytes)", signFnHash);
  sha256("verify(bytes)", verifyFnHash);

  jbyteArray byteArray = (*env)->NewByteArray(env, 10);

  if (PREFIX_LEN <= (length * 2)) {
    if (same_prefix(genKeyFnHash, inputBytes, PREFIX_LEN)) {
      return genKey(env);
    } else if (same_prefix(signFnHash, inputBytes, PREFIX_LEN)) {
      return sign(env, inputBytes);
    } else if (same_prefix(verifyFnHash, inputBytes, PREFIX_LEN)) {
      return verify(env, inputBytes);
    } else {
      printf("Unkown function call!");
      exit(1);
    }
  }

  (*env)->ReleaseByteArrayElements(env, input, inputBytes, 0);
  return input;
}

void cleanup_stack(uint8_t *secret_key, size_t secret_key_len) {
  OQS_MEM_cleanse(secret_key, secret_key_len);
}