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

    li t3,2 # t3 = 3

    rem t2, t2, t3 # t2 = N1 % 2

    beq t2, zero, eh_par # if (N1 % 2) == 0 {é par}
    li t0,0
    j fim


eh_par:
    li t0, 1
    j fim

fim:
    li t1, 0
    j fim