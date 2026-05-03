# org2026.1

Trabalho 1 da disciplina de **Organização de Computadores** - Semestre 2026.1

## 📋 Descrição do Projeto

Este projeto implementa estruturas de dados e algoritmos fundamentais utilizando **Assembly RISC-V de 32 bits (RV32I)**, seguindo os padrões e convenções definidos no guia de código padronizado.

### Objetivo

Desenvolver e otimizar implementações em linguagem de máquina, aplicando conceitos de:

- Convenção de chamadas (ABI)
- Gerenciamento de memória (heap e stack)
- Estruturas de dados (listas encadeadas, etc.)
- Otimizações microarquiteturais

## 👥 Equipe

| Nome                      | Função                      |
| ------------------------- | --------------------------- |
| Daniel Salvini            | _[Coloque seu nome aqui]_   |
| _[Coloque seu nome aqui]_ | _[Coloque sua função aqui]_ |
| _[Coloque seu nome aqui]_ | _[Coloque sua função aqui]_ |
| _[Coloque seu nome aqui]_ | _[Coloque sua função aqui]_ |

## 🛠️ Tecnologias

- **Linguagem:** Assembly RISC-V 32 bits (RV32I)
- **Simuladores Compatíveis:** RARS, Venus, gem5, Ripes
- **Padrão:** Código único em arquivo `.s`

## 📂 Estrutura do Projeto

```
org2026.1/
├── README.md                    # Este arquivo
├── .github/
│   ├── copilot-instructions.md # Instruções para GitHub Copilot
│   └── trabalho1.instructions.md # Especificações do trabalho
└── lista_encadeada.s           # Implementação de lista encadeada
```

## 🚀 Como Executar

### No RARS

1. Abra o arquivo `.s` no RARS
2. Clique em **Assemble**
3. Clique em **Run** ou use **F5**

### No Venus

1. Acesse [venus.cs.berkeley.edu](https://venus.cs.berkeley.edu)
2. Copie o conteúdo do arquivo `.s`
3. Clique em **Assemble** e depois **Run**


## 📝 Padrões de Código

Este projeto segue rigorosamente as convenções definidas em `.github/copilot-instructions.md`:

- ✅ Arquitetura **RV32I exclusivamente**
- ✅ Diretivas `.data` e `.text` explícitas
- ✅ Comentários em `#` (não `//` ou `/**/`)
- ✅ Labels em `snake_case` e privados com prefixo `.L_`
- ✅ Alinhamento de stack em múltiplos de 16 bytes
- ✅ Sem bibliotecas externas (RISC-V puro)

## 📚 Funções Implementadas

### `malloc_simple`

Aloca memória no heap usando a syscall `sbrk`.

### `print_string`

Imprime uma string terminada em `\0` na saída padrão.

### `print_char`

Imprime um caractere individual.

### `print_hex`

Imprime um valor inteiro em formato hexadecimal (8 dígitos).

## 🔧 Dependências

Nenhuma. O projeto utiliza **RISC-V puro** sem dependências externas.

## 📖 Referências

- [RISC-V Specifications](https://riscv.org/specifications/)
- [RARS Simulator](https://github.com/TheThirdOne/rars)
- [Venus Simulator](https://venus.cs.berkeley.edu)
- Guia de Código RISC-V Padronizado (`.github/copilot-instructions.md`)

## 📄 Licença

Este é um trabalho acadêmico. Consulte os termos da instituição.

---

**Última atualização:** 2 de maio de 2026
