.equ MTIME,    0x0200BFF8
.equ MTIMECMP, 0x02004000
.equ INTERVAL, 10000000             # 1 seggundo

.section .text
.globl trap_handler

trap_handler:

    # Salva o contexto
    addi sp, sp, -16
    sd ra, 0(sp)
    sd t0, 8(sp)

    csrr t0, mcause                                     # t0 = causa da interrupcao

    bgez t0, trap_exit                                  # Se mcause for >= 0, encerra
    andi t1, t0, 0x0F                                   # t1 = ultimos 4 bits de mcause que informam qual tipo de interrupção é

    li t2, 7                                            # t2 = 7 (código para interrupção de timer)
    beq t1, t2, interrupcao_timer                       # verifica se é uma interrução de timer

    li t2, 11                                           # t2 = 11 (código para interrupção externa)
    beq t1, t2, interrupcao_externa                     # verifica se é uma interrupção externa

    j trap_exit                                         # se não for nada, encerra

interrupcao_timer:
    jal timer_isr                                       # salta para o handler do timer
    j trap_exit                                         # encerra

interrupcao_externa:
    jal uart_isr                                        # salta para o handler da interrupção externa

trap_exit:

    # Restaura o contexto
    ld ra, 0(sp)
    ld t0, 8(sp)
    addi sp, sp, 16
    mret

.globl timer_set
timer_set:
    li t0, MTIME                                        # t0 = endereço do timer global
    ld t1, 0(t0)                                        # t1 = tempo atual
    
    li t2, INTERVAL                                     # t2 = 1 segundo
    add t1, t1, t2                                      # t1 = tempo atual + 1 segundo

    li t0, MTIMECMP                                     # t0 = endereço do "alarme" de interrupção
    sd t1, 0(t0)                                        # salva tempo atual + 1 em MTIMECMP
    ret

.globl timer_isr
timer_isr:
    addi sp, sp, -16                                    # aloca espaço na pilha
    sd ra, 0(sp)                                        # salva o ra na pilha
    sd s0, 8(sp)                                        # salva s0 na pilha

    jal timer_set                                       # agenda a interrupção

    la s0, clock_seconds                                # s0 = endereço do buffer que armazena os SEGUNDOS
    lbu t0, 0(s0)                                       # t0 = SEGUNDOS
    addi t0, t0, 1                                      # t0 = SEGUNDOS + 1
    li t1, 60                                           # t1 = 60
    blt t0, t1, salva_segundos                          # verica se segundos atingiram 60
    sb zero, 0(s0)                                      # grava 0 em segundos quando SEGUNDOS == 60

    la s0, clock_minutes                                # s0 = endereço do buffer que armazena os MINUTOS
    lbu t0, 0(s0)                                       # t0 = MINUTOS
    addi t0, t0, 1                                      # t0 = MINUTOS + 1
    li t1, 60                                           # t1 = 60
    blt t0, t1, salva_minutos                           # verica se os minutos atingiram 60
    sb zero, 0(s0)                                      # grava 0 em minutos quando MINUTOS == 60

    la s0, clock_hours                                  # s0 = endereço do buffer que armazena as HORAS
    lbu t0, 0(s0)                                       # t0 = HORAS    
    addi t0, t0, 1                                      # t0 = HORAS + 1
    li t1, 24                                           # t1 = 24
    blt t0, t1, salva_horas                             # verifica se as horas atingiram 24
    sb zero, 0(s0)                                      # grava 0 em horas quando HORAS == 24

    j exibe_horario

salva_horas:
    sb t0, 0(s0)                                        # grava a HORA atual no buffer das HORAS
    j exibe_horario                                     # imprime o horário no terminal

salva_minutos:
    sb t0, 0(s0)                                        # grava o MINUTO atual no buffer dos MINUTOS
    j exibe_horario                                     # imprime o horário no terminal

salva_segundos:
    sb t0, 0(s0)                                        # salva o SEGUNDO atual no buffer dos SEGUNDOS

exibe_horario:
    jal uart_print_time                                 # salta para funçao de imprimir o horário

    ld ra, 0(sp)                                        # restaura ra
    ld s0, 8(sp)                                        # restaura s0
    addi sp, sp, 16                                     # desaloca espaço na pilha
    ret
