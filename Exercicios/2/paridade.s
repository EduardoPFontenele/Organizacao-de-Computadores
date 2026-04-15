.section .data
    N1: .word 10

.section .text
.globl _start

_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    la t1, N1 # Carrega o ENDEREÇO de N1 em t1
    lw t2, 0(t1) # Carrega o VALOR de N1 em t2

    andi t1, t2, 1 # t1 = N1 and 0x00000001

    beq t1, zero, eh_par # se t1 == 0, o número é par
    li t0, 0 
    j fim


eh_par:
    li t0, 1 # t0 = 1
    j fim

fim:
    li t1, 0
    j fim