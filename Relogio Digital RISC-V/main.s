.section .bss
.space 4096
stack_top:

# Variaveis do relogio
.globl clock_hours
.globl clock_minutes
.globl clock_seconds
clock_hours: .byte 0
clock_minutes: .byte 0
clock_seconds: .byte 0

# Buffer de recepcao UART
.globl rx_buffer
.globl rx_len
.align 2
rx_buffer: .space 16
rx_len:.byte 0

.option norvc                                   # desabilita instrucoes comprimidas (garante alinhamento de 4 bytes)

# UART
.equ UART_BASE, 0x10000000                      # endereco base da UART
.equ UART_RHR,  0                               # offset para receber dados
.equ UART_THR,  0                               # offset para transmitir dados
.equ UART_IER,  1                               # offset do registrador de habilitacao de interrupcoes
.equ UART_IRQ,  10

# PLIC (Platform-Level Interrupt Controller)
.equ PLIC_BASE,      0x0C000000
.equ PLIC_PRIORITY,  (PLIC_BASE + 0x0)
.equ PLIC_ENABLE,    (PLIC_BASE + 0x2000)
.equ PLIC_THRESHOLD, (PLIC_BASE + 0x200000)
.equ PLIC_CLAIM,     (PLIC_BASE + 0x200004)

# Timer (CLINT)
.equ MTIME,    0x0200BFF8
.equ MTIMECMP, 0x02004000
.equ INTERVAL, 10000000                         # 1 segundo

.section .rodata
.globl msg_start
.globl msg_set_ok
msg_start: .string "\n=== Relogio Digital ===\nUse \"T HH:MM:SS\" para ajustar\n"
msg_set_ok: .string "\n[OK] Horario atualizado!\n"

.section .text
.globl _start
_start:
    # Inicializa o apontador de pilha
    la sp, stack_top

    # Instala a rotina de tratamento de interrupcao
    la t0, trap_handler
    csrw mtvec, t0

    # Habilita interrupcao de recepcao na UART
    li t0, UART_BASE
    li t1, 1
    sb t1, UART_IER(t0)

    # Configura a prioridade da UART no PLIC
    li t0, PLIC_PRIORITY
    li t1, UART_IRQ
    slli t1, t1, 2                              # UART_IRQ * 4 = offset da entrada no PLIC
    add t0, t0, t1
    li t2, 1                                    # prioridade minima
    sw t2, 0(t0)

    # Habilita a interrupcao da UART no PLIC
    li t0, PLIC_ENABLE
    li t1, 1
    slli t1, t1, UART_IRQ                       # bit 10 = fonte UART
    sw t1, 0(t0)

    # Define o limiar de prioridade (0 = aceita tudo)
    li t0, PLIC_THRESHOLD
    sw zero, 0(t0)

    # Exibe mensagem inicial e horario
    la a0, msg_start
    jal uart_puts
    jal uart_print_time

    # Agenda o primeiro disparo do timer
    jal timer_set

    # Habilita interrupcao de timer (MTIE = bit 7)
    li t0, (1 << 7)
    csrs mie, t0

    # Habilita interrupcao externa M-mode (MEIE = bit 11)
    li t0, (1 << 11)
    csrs mie, t0

    # Habilita interrupcoes globais (MIE = bit 3 de mstatus)
    li t0, (1 << 3)
    csrs mstatus, t0

main_loop:
    wfi                                         # aguarda interrupcao
    j main_loop
