.section .data
    N: .word 5

.section .text
.globl _start

_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    la a0, N
    lw a0, 0(a0)

    jal fibonacci
    j fim

fibonacci:

    addi sp, sp, -12
    sw s1, 0(sp)
    sw ra, 4(sp)
    sw s0, 8(sp)

    li t0, 1 # t0 = 1
    mv s0, a0 # s0 = N inicial

    # Verificar caso base
    ble a0, t0, caso_base

    # Passo recursivo
    addi a0, a0, -1
    jal fibonacci

    mv s1, a0 # s0 = fibonacci(n - 1)

    addi a0, s0, -2 # a0 = n - 2
    jal fibonacci

    add a0, s1, a0 # return fibonacci(n - 1) + (fibonacci - 2)
    j epilogo

caso_base:
    li a0, 1
    j epilogo

epilogo:
    lw s1, 0(sp)
    lw s0, 8(sp)
    lw ra, 4(sp)
    addi sp, sp, 12
    jr ra

fim:
    li t0, 0
    j fim