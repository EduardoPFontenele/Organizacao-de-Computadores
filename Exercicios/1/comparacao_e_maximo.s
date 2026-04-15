.section .data
    N1: .word 2
    N2: .word 3

.section .text
.globl _start

_start:

    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    # Carrega o endereço de N1 para t0
    la t0, N1

    # Carrega o endereço de N2 para t1
    la t1, N2   

    # Carrega o valor de N1 (3) para t0
    lw t0, 0(t0)

    # Carrega o valor de N1 (3) para t0
    lw t1, 0(t1)

    blt t0, t1, t1_maior # if (t0 < t1) {t1 é maior}
    j fim

t1_maior:

    # Valor de t1 é copiado para t0
    mv t0, t1
    j fim

fim:
    li t2, 0
    j fim