.section INTERRUPT_VECTOR, "x"

.word stack_top
.word _Reset
.thumb_func

.global _Reset

_Reset:
  B Reset_Handler /* Reset */
  B . /* Undefined */
  B . /* SWI */
  B . /* Prefetch Abort */
  B . /* Data Abort */
  B . /* reserved */
  B . /* IRQ */
  B . /* FIQ */
 
Reset_Handler:
  BL my_init
  B .

