.section .data
    N: .word 5

.section .text
.globl _start

_start:

    la a0, N # Carrega o ENDEREÇO de N em a0 
    lw a0, 0(a0) # Carrega o VALOR de N em a0

    jal fatorial
    j fim

fatorial:

    addi sp, sp, -8 
    sw s0, 0(sp)
    sw ra, 4(sp)

    mv s0, a0 # Salva o N inicial

    addi a0, a0, -1  # a0 = N - 1

    # Definir caso base
    beq a0, zero, caso_base # if (N == 0) {return 1;}

    # Passo recursivo
    jal fatorial
    mul a0, s0, a0 # return N * fatorial(N - 1)

    j epilogo

caso_base:

    li a0, 1
    j epilogo

fim:
    li t1, 0
    j fim

epilogo:
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8 
    jr ra

