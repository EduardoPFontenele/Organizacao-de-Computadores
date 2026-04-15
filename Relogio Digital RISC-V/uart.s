.equ UART_BASE, 0x10000000
.equ UART_RHR,  0
.equ UART_THR,  0
.equ UART_IER,  1
.equ UART_IRQ,  10

.equ PLIC_BASE,      0x0C000000
.equ PLIC_PRIORITY,  (PLIC_BASE + 0x0)
.equ PLIC_ENABLE,    (PLIC_BASE + 0x2000)
.equ PLIC_THRESHOLD, (PLIC_BASE + 0x200000)
.equ PLIC_CLAIM,     (PLIC_BASE + 0x200004)

.section .text
.globl uart_putc
uart_putc:
putc_aguarda_tx:
    li t0, UART_BASE                            # t0 = endereço do registrador de DADOS da UART
    lbu t1, 5(t0)                               # t1 = bits do registrador de STATUS da UART
    andi t1, t1, 0x20                           # t1 = bit 5 do registrador de STATUS da UART
    beqz t1, putc_aguarda_tx                    # verificação da habilitação do bit 5

    sb a0, UART_THR(t0)                         # grava caracter no registrador de DADOS da UART
    ret                                         # retorna ao chamador

.globl uart_puts
uart_puts:
    addi sp, sp, -16                            # aloca espaço na pilha
    sd ra, 0(sp)                                # salva ra na pilha
    sd s0, 8(sp)                                # salva s0 na pilha

    mv s0, a0                                   # s0 = endereço base da string

    puts_proximo_char:
        lbu a0, 0(s0)                           # a0 = string[i]
        beqz a0, puts_fim                       # verifica se chegou ao final da string

        jal uart_putc                           # salva caracter no registrador de DADOS da UART

        addi s0, s0, 1                          # vai para o próximo caracter da string
        j puts_proximo_char                     # loop

    puts_fim:
        ld ra, 0(sp)                            # restaura ra
        ld s0, 8(sp)                            # restaura s0
        addi sp, sp, 16                         # desaloca espaço reservado na pilha
        ret

uart_print_digit2:
    addi sp, sp, -24                            # aloca espaço na pilha
    sd ra, 0(sp)                                # salva ra na pilha                   
    sd s0, 8(sp)                                # salva s0 na pilha
    sd s1, 16(sp)                               # salva s1 na pilha

    mv s0, a0                                   # s0 = numero a ser imprimido na tela
    li s1, 10                                   # s1 = 10

    divu a0, s0, s1                             # a0 = valor / 10
    addi a0, a0, '0'                            # converto o numero para ASCII

    jal uart_putc                               # salva caracter no registrador de DADOS da UART

    remu a0, s0, s1                             # a0 = valor % 10
    addi a0, a0, '0'                            # converte o numero para ASCII

    jal uart_putc                               # salva caracter no registrador de DADOS da UART

    ld ra,  0(sp)                               # restaura ra
    ld s0,  8(sp)                               # restaura s0
    ld s1, 16(sp)                               # restaura s1
    addi sp, sp, 24                             # desaloca espaço reservado na pilha
    ret                                         

.globl uart_print_time
uart_print_time:
    addi sp, sp, -8                             # aloca espaço na pilha
    sd ra, 0(sp)                                # salva ra na pilha

    la t0, clock_hours                          # t0 = endereço base do buffer que armazena as HORAS
    lbu a0, 0(t0)                               # a0 = horas
    jal uart_print_digit2                       # imprime as horas no terminal

    li a0, ':'                                  # a0 = ':'
    jal uart_putc                               # adiciona ':' depois dos digitos das horas

    la t0, clock_minutes                        # t0 = endereço base do buffer que armazena os MINUTOS
    lbu a0, 0(t0)                               # a0 = minutos
    jal uart_print_digit2                       # imprime os minutos no terminal

    li a0, ':'                                  # a0 = ':'
    jal uart_putc                               # adiciona ':' depois dos digitos dos minutos

    la t0, clock_seconds                        # t0 = endereço base do buffer que armazena os SEGUNDOS
    lbu a0, 0(t0)                               # a0 = segundos
    jal uart_print_digit2                       # imprime os segundos no terminal

    li a0, '\n'                                 # a0 = '\n'
    jal uart_putc                               # adiciona '\n' ao final da string

    ld ra, 0(sp)                                # restaura ra
    addi sp, sp, 8                              # desaloca espaço reservado na pilha
    ret

.globl uart_isr
uart_isr:
    addi sp, sp, -24                            # aloca espaço na pilha
    sd ra, 0(sp)                                # salva ra na pilha
    sd s0, 8(sp)                                # salva s0 na pilha
    sd s1, 16(sp)                               # salva s1 na pilha

    li t0, PLIC_CLAIM                           # t0 = end. do registrador que armazena o ID do periférico que gerou a interrupção
    lw s0, 0(t0)                                # s0 = ID do periférico

    li t1, UART_IRQ                             # t1 = ID da UART no PLIC
    bne s0, t1, uart_done                       # se ID do periferico != ID da UART no plic, encerra

    li t0, UART_BASE                            # t0 = endereço do registrador de dados UART
    lbu s1, UART_RHR(t0)                        # s1 = dado recebido do teclado

    mv a0, s1                                   # a0 = dado recebido do teclado
    jal uart_putc                               # coloca caracter no registrador de dados (eco)

    li t0, '\r'                                 # t0 = \r
    beq s1, t0, uart_processa_cmd               # Verifica que o usuario ja terminou de digitar pressionou enter
    li t0, '\n'                                 # t0 = \n
    beq s1, t0, uart_processa_cmd               # Verifica que o usuario ja terminou de digitar pressionou enter

    la t0, rx_len                               # t0 = endereço do buffer que armazena o tamanho do dado que o usuario digitou
    lbu t1, 0(t0)                               # t1 = tamanho do buffer

    la t2, rx_buffer                            # t2 = endereço do buffer que armazena o novo horario digitado pelo usuario 
    add t2, t2, t1                              # t2 = endereço do buffer + tamanho do buffer
    sb s1, 0(t2)                                # salva o dado recebido do teclado no ultimo espaço livre do rx_buffer

    addi t1, t1, 1                              # t1 = tamanho do dado digitado + 1
    sb t1, 0(t0)                                # grava o novo tamanho em rx_len
    j uart_done

    uart_processa_cmd:

        jal parse_command                       # salva as horas, minutos e segundos nos buffers
        la t0, rx_len                           # quantidade de bytes recebidos (dados digitados pelo usuario)
        sb zero, 0(t0)                          # zera o buffer do tamanho para não prejudicar o buffer

    uart_done:
        li t0, PLIC_CLAIM                       # t0 = end. do registrador que armazena o ID do periférico que gerou a interrupção
        sw s0, 0(t0)                            # armazena o ID no registrador do PLIC, indicando o fim do tratamento da interrupção

        ld ra,  0(sp)                           # restaura ra
        ld s0,  8(sp)                           # restaura s0
        ld s1, 16(sp)                           # restaura s1   
        addi sp, sp, 24                         # desaloca espaço reservado na pilha
        
    ret

# rx_buffer = ['T',' ','1','4',':','0','7',':','3','3']
parse_command:

    addi sp, sp, -8                             # aloca espaço na pilha
    sd ra, 0(sp)                                # salva ra ba oukha

    la t0, rx_buffer                            # t0 = endereço do buffer que armazena o novo horario digitado pelo usuario

    lbu t1,2(t0)                                # t1 = primeiro caracter da HORA
    addi t1, t1, -'0'                           # t1 = caracter em inteiro

    li t3, 10                                   # t3 = 10
    mul t1, t1, t3                              # t1 = numero * 10

    lbu t2, 3(t0)                               # t2 = segundo caracter da HORA
    addi t2, t2, -'0'                           # t2 = caracter em inteiro
    add t1, t1, t2                              # t1 = (numero * 10) + segundo digito de hora

    lbu t2, 5(t0)                               # t2 = primeiro caracter de MINUTOS
    addi t2, t2, -'0'                           # t2 = caracter em inteiro

    li t3, 10                                   # t3 = 10
    mul t2, t2, t3                              # t2 = primeiro digito de MINUTOS * 10

    lbu t4, 6(t0)                               # t4 = segundo caracter de MINUTOS
    addi t4, t4, -'0'                           # t4 = caracter em inteiro
    add t2, t2, t4                              # t2 = (primeiro digito de minutos * 10) + segundo digito

    lbu t4, 8(t0)                               # t4 = primeiro caracter de SEGUNDOS
    addi t4, t4, -'0'                           # t4 = caracter em inteiro

    li t3, 10                                   # t3 = 10
    mul t4, t4, t3                              # t4 = primeiro digito de SEGUNDOS *  10

    lbu t5, 9(t0)                               # t5 = segundo caracter de SEGUNDOS
    addi t5, t5, -'0'                           # t5 = caracter em inteiro

    add t4, t4, t5                              # t4 = (primeiro digito de SEGUNDOS *  10) + segundo digito de SEGUNDOS

    la t3, clock_hours                          # t3 = endereço do buffer em que as HORAS serão armazenadas
    sb t1, 0(t3)                                # armazena os digitos das HORAS no buffer

    la t3, clock_minutes                        # t3 = endereço do buffer em que os MINUTOS serão armazenados
    sb t2, 0(t3)                                # armazena os digitos dos MINUTOS no buffer

    la t3, clock_seconds                        # t3 = endereço do buffer em que os SEGUNDOS serão armazenados
    sb t4, 0(t3)                                # armazena os digitos dos SEGUNDOS no buffer

    la a0, msg_set_ok                           # a0 = endereço do buffer de mensagem de sucesso
    jal uart_puts                               # imprime a mensagem de sucesso (coloca no registrador de dados)
    jal uart_print_time                         # imprime o tempo atualizado

    ld ra, 0(sp)                                # restaura ra
    addi sp, sp, 8                              # desaloca espaço na pilha
    ret