# Instruções para GitHub Copilot: Desenvolvimento em Assembly RISC-V

⚠️ **REQUISITO OBRIGATÓRIO: TODO CÓDIGO GERADO DEVE SER RISC-V 32 BITS (RV32I)**

Este documento serve como diretriz de contexto para guiar o GitHub Copilot na escrita, otimização e estruturação de código assembly RISC-V conforme o *Guia de Código RISC-V Padronizado* e os requisitos do *Trabalho 1 de Organização de Computadores*.

---

## 1. Regras Gerais de Projeto e Ambiente

* **Arquitetura de 32 bits (RV32I):** 🔴 **TODO código DEVE ser desenvolvido EXCLUSIVAMENTE para RISC-V de 32 bits (RV32I)**. Utilize `lw`/`sw` para operações de memória e registradores de 32 bits. **NÃO gere código RV64I ou qualquer outra variante.**
* **Diretivas de Seção:** Organize o código utilizando explicitamente `.data` para dados estáticos e `.text` para instruções executáveis, no topo do arquivo.
* **Comentários:** Todo comentário deve ser feito utilizando `#`. Não use `/**/` ou qualquer outro formato.
* **Nomenclatura de Rótulos (Labels):** Utilize `snake_case` para os pontos de entrada de funções e utilize o prefixo `.L_` para rótulos locais (privados ao escopo da função).
* **Arquivo Único:** Toda a implementação **DEVE** ser realizada em um **único arquivo `.s`**. Todas as funções são locais ao escopo do arquivo.
* **Sem Bibliotecas Externas:** É **EXPRESSAMENTE PROIBIDO** o uso de qualquer biblioteca externa. O trabalho deve ser desenvolvido **estritamente com RISC-V puro**, implementando manualmente todas as funcionalidades necessárias.

---

## 2. Convenção de Chamadas (Calling Convention - ABI)

* **Alinhamento da Pilha (Stack Frame):** O ponteiro de pilha (`sp`) deve ser obrigatoriamente alinhado a múltiplos de 16 bytes na entrada de qualquer rotina.
* **Funções Non-Leaf:** Funções que chamam outras sub-rotinas devem salvar o registrador de retorno (`ra`) no prólogo e restaurá-lo no epílogo.
* **Funções Leaf:** Funções que não chamam sub-rotinas não necessitam salvar o `ra` na pilha.
* **Preservação de Registradores:** 
  * Os registradores `s0`-`s11` são *Callee-Saved* (devem ser preservados pela função chamada).
  * Os registradores `a0`-`a7` e `t0`-`t6` são *Caller-Saved*.

---

## 3. Dinâmica de Alocação de Memória

* **Alocação no Heap:** Simule o comportamento de `malloc()` utilizando a chamada de sistema (syscall) `sbrk` passando a quantidade de bytes requerida para o registrador `a0` com `a7 = 9`, seguido pela instrução `ecall`.
* **Gerenciamento de Espaço:** Como os emuladores (RARS/Venus) têm suporte a retrocesso limitado em `sbrk`, implemente estruturas de *Free List* ou controle manual de alocação caso o algoritmo precise liberar memória.

---

## 4. Otimização Microarquitetural

* **Escalonamento de Instruções (Pipeline RAW Hazards):** Evite *Load-Use hazards* interpondo instruções independentes entre operações de leitura da memória (`lw`) e o uso de seus dados.
* **Predição de Desvio (BTFNT Aware):** Ao estruturar laços (loops), posicione o salto para trás (*Backward Branch*) de modo que seja avaliado como *TAKEN*, e evite saltos longos para a frente (*Forward Branch*) no caminho principal (*hot path*), a menos que seja para exceções residuais.
* **Programação Branchless:** Em situações de alta imprevisibilidade ou onde os dados devem ser protegidos contra vazamento de tempo (operações *Data-Oblivious*), utilize lógica bit a bit (ex: `srai`, `xor`, `sub`) em vez de saltos condicionais (`beq`/`bne`).

---

## 5. Simuladores Suportados

* O código gerado deve ser compatível e testável em um dos seguintes ambientes:
  * **gem5**
  * **RARS**
  * **Venus**
  * **Ripes**

---

## 6. Estrutura do Arquivo e Organização

* **Localização da `main`:** A função `main` **DEVE** estar localizada no **topo do arquivo**, imediatamente após as diretivas de seção e antes de qualquer outra função.
* **Ordem de Seções:** Estruture o arquivo conforme:
  1. Diretivas de seção (`.section .data`, `.section .text`)
  2. Função `main`
  3. Demais funções auxiliares
* **Visibilidade das Funções:** Todas as funções devem ser declaradas como locais (sem `.global`), já que o projeto é um arquivo único.

---

## 7. Padronização de Comentários

### 7.1 Regras Gerais

* **Todo comentário usa `#`:** Não utilize `//`, `/**/` ou qualquer outro delimitador.
* **Comentários de linha:** Cada linha de código deve possuir um comentário explicativo, a menos que seja óbvia (ex: labels).
* **Separação de Seções:** Divida o código em seções lógicas usando quebras de linha (`\n`) e comentários de cabeçalho com a descrição da seção.
* **Indentação de comentários:** Comentários de linha devem estar alinhados a partir da coluna 40 (use tabs/espaços para alinhar).

### 7.2 Formato de Comentários

```assembly
# ===== SEÇÃO: Descrição da Seção =====
# Explicação geral do que essa seção faz

    instrução                           # Comentário explicativo

# ===== FIM DA SEÇÃO =====
```

### 7.3 Documentação de Funções

Toda função deve incluir:
1. **Comentário de descrição** (o que faz)
2. **Equivalente em C** (assinatura e lógica)
3. **Argumentos** (registradores `a0`-`a7`)
4. **Retorno** (`a0` para resultado)

```assembly
# ===== FUNÇÃO: nome_da_funcao =====
# Descrição: Explica brevemente o propósito da função
#
# Equivalente em C:
# int nome_da_funcao(int x, int y) {
#     int resultado = x + y;
#     return resultado;
# }
#
# Argumentos:
#   a0 = primeiro argumento (x)
#   a1 = segundo argumento (y)
#
# Retorno:
#   a0 = resultado da operação

nome_da_funcao:
    # ...código...
    ret
```

---

## 8. Estrutura de Exemplo de Função Canônica

```assembly
# ===== FUNÇÃO: soma_dois_numeros =====
# Descrição: Realiza a soma de dois números inteiros
#
# Equivalente em C:
# int soma_dois_numeros(int a, int b) {
#     int resultado = a + b;
#     return resultado;
# }
#
# Argumentos:
#   a0 = primeiro número (a)
#   a1 = segundo número (b)
#
# Retorno:
#   a0 = soma dos dois números

.text


soma_dois_numeros:
    # Prólogo: Aloca espaço na pilha (Non-Leaf, pois chama outras funções)
    addi sp, sp, -16                    # Reduz stack pointer em 16 bytes (mantém alinhamento de 16)
    sw ra, 12(sp)                       # Salva registrador de retorno na pilha
    sw s0, 8(sp)                        # Salva registrador callee-saved s0

    # ===== SEÇÃO: Processamento Principal =====
    # Realiza a operação de soma dos dois argumentos

    add a0, a0, a1                      # Soma a1 ao a0, resultado fica em a0
    mv s0, a0                           # Move o resultado para s0 (registrador preservado)

    # ===== SEÇÃO: Preparação de Retorno =====
    # Restaura os registradores e retorna

    mv a0, s0                           # Move resultado de volta para a0 (convenção de retorno)
    lw s0, 8(sp)                        # Restaura s0 da pilha
    lw ra, 12(sp)                       # Restaura registrador de retorno
    addi sp, sp, 16                     # Incrementa stack pointer em 16 bytes
    ret                                 # Retorna à função chamadora

# ===== FIM DA FUNÇÃO: soma_dois_numeros =====
```

---

## 9. Exemplo Completo com Múltiplas Funções

```assembly
# ===== FUNÇÃO: multiplicar_por_dois =====
# Descrição: Multiplica um número inteiro por 2
#
# Equivalente em C:
# int multiplicar_por_dois(int x) {
#     return x * 2;
# }
#
# Argumentos:
#   a0 = número a ser multiplicado
#
# Retorno:
#   a0 = número multiplicado por 2

.text

multiplicar_por_dois:
    # ===== SEÇÃO: Operação de Multiplicação =====
    # Utiliza shift left para multiplicar por 2 (mais eficiente que mul)

    slli a0, a0, 1                      # Shift left lógico em 1 posição (equivale a x * 2)
    ret                                 # Retorna com resultado em a0

# ===== FIM DA FUNÇÃO: multiplicar_por_dois =====


# ===== FUNÇÃO: main =====
# Descrição: Função principal que orquestra o programa
#
# Equivalente em C:
# int main() {
#     int x = 5;
#     int resultado = multiplicar_por_dois(x);
#     return resultado;
# }

main:
    # Prólogo: Aloca espaço para variáveis locais
    addi sp, sp, -16                    # Aloca 16 bytes na pilha
    sw ra, 12(sp)                       # Salva registrador de retorno

    # ===== SEÇÃO: Inicialização de Variáveis =====
    # Define valor inicial para x

    li a0, 5                            # Carrega 5 em a0 (x = 5)
    sw a0, 8(sp)                        # Armazena x na pilha

    # ===== SEÇÃO: Chamada de Função =====
    # Chama multiplicar_por_dois com x como argumento

    call multiplicar_por_dois           # Chama função (resultado retorna em a0)
    sw a0, 4(sp)                        # Armazena resultado na pilha

    # ===== SEÇÃO: Encerramento =====
    # Libera recursos e retorna

    lw ra, 12(sp)                       # Restaura registrador de retorno
    addi sp, sp, 16                     # Libera espaço na pilha
    ret                                 # Retorna (fim do programa)

# ===== FIM DA FUNÇÃO: main =====
```
