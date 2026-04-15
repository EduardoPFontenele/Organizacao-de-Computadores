.section .data
    N: .word 10

.section .text
.globl _start

_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    la s0, N # Carrega o ENDEREÇO de N
    lw s0, 0(s0) # Carrega o VALOR de N

    mv t0, s0 
    
    addi t0, t0, -3 # t0 = N - 3 (2)
    li t1, 0 # i = 0

    li t2, 1 # t2 (a) = 1
    li t3, 1 # t2 (b) = 1

    ble s0, t2, caso_base # if (N <= 1)

fibonacci:
    bgt t1, t0, fim # if (t1 > 3t0) {fim} 
    add t4, t2, t3 # proximo = a + b
    mv t2, t3 # a = b
    mv t3, t4 # b = proximo
    addi t1, t1, 1 # i ++
    j fibonacci


caso_base:
    li t4, 1
    j fim

fim:
    li t0, 0
    j fim