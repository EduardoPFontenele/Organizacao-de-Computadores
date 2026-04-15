
# Digital Clock RISC-V Bare Metal
Este repositório contém a implementação de um relógio digital funcional escrito inteiramente em Assembly RISC-V (RV64). O projeto opera em modo bare metal, ou seja, sem a presença de um sistema operacional, interagindo diretamente com o hardware emulado pelo QEMU.

# Visão Geral
O relógio exibe o horário continuamente no formato HH:MM:SS através da interface UART. O sistema é capaz de:
- Contagem Precisa: Utiliza o temporizador de hardware (CLINT) para gerar interrupções a cada 1 segundo;
- Ajuste via Terminal: Recebe comandos no formato T HH:MM:SS para atualizar o horário em tempo real;
- Gestão de Interrupções: Implementa um tratador unificado (trap_handler) para gerenciar eventos externos e de temporizador;

# Estrutura do Projeto
O código está organizado em módulos funcionais para garantir a legibilidade e facilitar a manutenção:
- main.s: Realiza a inicialização do sistema, incluindo a configuração da pilha (SP), instalação do vetor de interrupções (MTVEC), configuração do PLIC e habilitação global de interrupções.
- trap.s: Contém a lógica de tratamento de exceções. Gerencia o salvamento/restauração de contexto e despacha o controle para as rotinas de serviço de interrupção (ISR).
- uart.s: Implementa a comunicação serial, incluindo funções para transmissão de caracteres, strings, formatação de dígitos e processamento dos comandos de entrada.

# Detalhes de Hardware (Mapeamento)
| Periférico | Endereço / Valor | Descrição |
|------------|------------------|-----------|
| UART_BASE  | 0x10000000       | Endereço base para comunicação serial. |
| PLIC_BASE  | 0x0C000000       | Controlador de Interrupções de Nível de Plataforma. |
| MTIME      | 0x0200BFF8       | Registrador de tempo real do CLINT. |
| MTIMECMP   | 0x02004000       | Registrador de comparação para o "alarme" do timer. |
| INTERVAL   | 10.000.000       | Ciclos necessários para 1 segundo no QEMU. |

# Compilação e Execução
Para compilar e rodar o projeto, utilize o toolchain do RISC-V e o QEMU:

```bash
# 1. Montagem dos objetos
riscv64-unknown-elf-as -march=rv64imac_zicsr main.s -o main.o
riscv64-unknown-elf-as -march=rv64imac_zicsr trap.s -o trap.o
riscv64-unknown-elf-as -march=rv64imac_zicsr uart.s -o uart.o

# 2. Ligação (Linking)
riscv64-unknown-elf-ld -Ttext=0x80000000 --entry=_start main.o trap.o uart.o -o main.elf

# 3. Execução no QEMU
qemu-system-riscv64 -machine virt -nographic -bios none -kernel main.elf

```
