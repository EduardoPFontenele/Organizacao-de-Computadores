.section .data
    N: .word 5

.section .text
.globl _start

_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    la s0, N # carrega o ENDEREÇO de N em s0
    lw s0, 0(s0) # carrega o VALOR de N em s0
    li t1, 1 # t1 = 1 (contador)
    li t0, 0 # t2 = 0 (acumulador da soma)
    addi s0, s0 , 1 # N = 6

loop:
    beq t1, s0, fim # if (contador == num) {return}
    add t0, t0, t1 # t0 += t1
    addi t1, t1 , 1 # t1 ++
    j loop

fim:
    li t1, 0
    j fim

