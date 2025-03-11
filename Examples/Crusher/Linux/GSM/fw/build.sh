#!/bin/bash

set -e #stop on error

OPS="-DDEMOTEST -I . -I gsm_v5 -Wno-builtin-declaration-mismatch"

echo "############################################################################"
echo \#Assemble the startup.s file:
arm-none-eabi-as -mcpu=cortex-m4 -g startup.s -o startup.o

echo \#Compile init.c:
arm-none-eabi-gcc -c -mcpu=cortex-m4 -mthumb -g $OPS init.c -o init.o

echo \#Compile gsm.c:
arm-none-eabi-gcc -c -mcpu=cortex-m4 -mthumb -g $OPS gsm_v5/gsm.c -o gsm.o

echo \#Compile gsmCallback.c:
arm-none-eabi-gcc -c -mcpu=cortex-m4 -mthumb -g $OPS gsm_v5/gsmCallback.c -o gsmCallback.o

echo \#Link the object files into an ELF file:
arm-none-eabi-ld -T linker.ld init.o startup.o gsm.o gsmCallback.o -o firmware.elf

echo \#Objcopy:
arm-none-eabi-objcopy -O binary firmware.elf firmware.bin

exit 0

#qemu-system-arm -M netduino2 -nographic -kernel firmware.bin [-S -s]

