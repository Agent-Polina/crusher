#pragma once

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;
typedef signed char int8_t;
typedef signed short int16_t;
typedef signed int int32_t;
typedef signed long long int64_t;
typedef int bool;
#define true 1
#define false 0

void printf(const char *str, ...);

static int strlen(const char *s)
{
  int i = 0;
  while (s[i] != '\0') {
    i++;
  }
  return i;
}

static void strcpy(char *dst, const char *src)
{
  int i = 0;
  while (src[i] != '\0') {
    dst[i] = src[i];
    ++i;
  }
  dst[i] = '\0';
}

