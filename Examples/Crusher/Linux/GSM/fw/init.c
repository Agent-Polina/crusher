#include <gsm.h>

volatile unsigned int * const USART1_PTR = (unsigned int *)0x40011004;
volatile unsigned int * const USART2_PTR = (unsigned int *)0x40004404;
volatile unsigned int * const USART3_PTR = (unsigned int *)0x40004804;
volatile unsigned int * const UART4_PTR = (unsigned int *)0x40004c04;
volatile unsigned int * const UART5_PTR = (unsigned int *)0x40005004;
volatile unsigned int * const USART6_PTR = (unsigned int *)0x40011404;

void display(const char *string, volatile unsigned int * uart_addr)
{
  while(*string != '\0'){
    *uart_addr = *string;
    string++;
  }
}

void printf(const char *str, ...)
{
  display(str, USART1_PTR);
}

int my_init()
{
  printf("INIT\n");
  gsm_init();
  gsm_loop();
  return 0;
}
