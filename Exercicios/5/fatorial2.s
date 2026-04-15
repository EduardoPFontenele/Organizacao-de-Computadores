.section .data
    N: .word 5

.section .text
.globl _start

_start:

    la s0, N # Carrega o ENDEREÇO de N em s0 
    lw s0, 0(s0) # Carrega o VALOR de N em s0

    mv t0, s0 # t0 = N
    addi t1, t0, -1 # t1 = N - 1 (4)

fatorial:
    beq t1, zero, fim
    mul t0, t0, t1 # t0 *= (N - 1)
    addi t1, t1, -1
    j fatorial
fim:
    li t1, 0
    j fim

