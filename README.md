# Organização de Computadores

Atividades em Assembly da disciplina **Organização de Computadores** (Ciência da Computação – UFMT).

## Projeto principal

**[Relógio Digital RISC-V (bare metal)](Relogio%20Digital%20RISC-V/)**: relógio HH:MM:SS escrito inteiramente em Assembly RISC-V (RV64), rodando sem sistema operacional no QEMU. Usa interrupções do temporizador (CLINT) a cada segundo, um tratador de interrupções unificado e comunicação serial pela UART, incluindo ajuste do horário pelo terminal.

## Exercícios

| Pasta | Exercício |
|---|---|
| `Exercicios/1` | Comparação e máximo entre dois números |
| `Exercicios/2`, `Exercicios/3` | Verificação de paridade |
| `Exercicios/4` | Soma com laço |
| `Exercicios/5` | Fatorial (iterativo e recursivo) |
| `Exercicios/6` | Fibonacci (iterativo e recursivo) |
| `Exercicios/7` | Manipulação de array |

Os arquivos-fonte são os `.s`. Arquivos gerados na montagem (`.o`, `.exe`, `.elf`) não são versionados.
