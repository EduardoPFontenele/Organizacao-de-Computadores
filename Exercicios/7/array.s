.section .data
    array: .word 5, 6, 7, 8, 30, -1

.section .text
.globl _start

_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    la s0, array 
    mv t0, s0 # t0 = &array[0]

    li t1, 0 # i = 0 (indice para percorrer vetor)
    li t3, 6 # tamanho do array = 6

    slli t2, t1, 2 # t2 = (indice * 4)
    add t2, t0, t2 # t2 = endereço base + (indice * 4)
    lw t5, 0(t2) # t5(maior) = array[0]

    j busca_maior

busca_maior:

    bge t1,t3, fim
    slli t2, t1, 2 # t2 = (indice * 4)
    add t2, t0, t2 # t2 = endereço base + (indice * 4)

    lw t2, 0(t2) # t2 = vetor[i]
    
    bge t5, t2, continue
    mv t5, t2
    addi t1, t1, 1

    j busca_maior

continue:   
    addi t1, t1 ,1 # i++
    j busca_maior

fim:
    li t0, 0
    j fim