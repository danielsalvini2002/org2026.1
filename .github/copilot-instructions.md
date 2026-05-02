# Instruções para GitHub Copilot: Desenvolvimento em Assembly RISC-V

Este documento serve como diretriz de contexto para guiar o GitHub Copilot na escrita, otimização e estruturação de código assembly RISC-V conforme o *Guia de Código RISC-V Padronizado* e os requisitos do *Trabalho 1 de Organização de Computadores*.

---

## 1. Regras Gerais de Projeto e Ambiente

* **Extensão dos arquivos:** Sempre utilize a extensão `.S` (maiúscula) em vez de `.s`, para que o código seja submetido ao pré-processador do C, permitindo diretivas como `#include` e macros.
* **Diretivas de Seção:** Organize o código utilizando explicitamente as seções `.data` para dados estáticos e `.text` para instruções executáveis.
* **Documentação Doxygen:** Todo símbolo global (função) deve ser precedido por comentários no formato Doxygen, incluindo `@brief`, `@param[in]`, `@param[out]` e `@return`.
* **Metadados da Função:** Inclua as diretivas `.type name, @function` e `.size name, .-name` para cada função implementada.
* **Nomenclatura de Rótulos (Labels):** Utilize `snake_case` para os pontos de entrada de funções e utilize o prefixo `.L_` para rótulos locais (privados ao escopo da função).

---

## 2. Convenção de Chamadas (Calling Convention - ABI)

* **Alinhamento da Pilha (Stack Frame):** O ponteiro de pilha (`sp`) deve ser obrigatoriamente alinhado a múltiplos de 16 bytes na entrada de qualquer rotina.
* **Funções Non-Leaf:** Funções que chamam outras sub-rotinas devem salvar o registrador de retorno (`ra`) no prólogo e restaurá-lo no epílogo.
* **Funções Leaf:** Funções que não chamam sub-rotinas não necessitam salvar o `ra` na pilha.
* **Preservação de Registradores:** * Os registradores `s0`-`s11` são *Callee-Saved* (devem ser preservados pela função chamada).
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

## 6. Estrutura de Exemplo de Função Canônica

```assembly
/**
 * @brief Exemplo de função canônica em RISC-V.
 *
 * @param[in] a0 Ponteiro de entrada
 * @param[in] a1 Quantidade de elementos
 * @return a0 Status (0 para sucesso, -1 para erro)
 */
.section .text
.balign 4
.global minha_funcao
.type minha_funcao, @function

minha_funcao:
    # Prólogo Non-Leaf
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    addi s0, sp, 16

    # Lógica da função
    # ...

    # Epílogo
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.size minha_funcao, .-minha_funcao
```
