# Passo a Passo: Implementar Lista Encadeada em RISC-V Assembly

Vou guiá-lo através de um processo estruturado para converter a lógica C para RISC-V.

---

## **Passo 1: Entender a Estrutura de Dados em Memória**

Na versão C, cada nó ocupa:

```
struct No {
    int valor;           // 4 bytes (offset 0)
    struct No *proximo;  // 8 bytes (offset 4)
}
// Total: 12 bytes por nó
```

Em RISC-V, você precisa manipular isso manualmente:

- **valor** está no endereço `[base + 0]`
- **proximo** está no endereço `[base + 4]`

---

## **Passo 2: Implementar `sbrk()` - Alocação de Memória**

Comece com uma função que aloca memória no heap:

````assembly
// filepath: /home/daniel/projetos/org2026.1/lista_encadeada.S

/**
 * @brief Aloca memória no heap usando sbrk
 * 
 * @param[in] a0 Número de bytes a alocar
 * @return a0 Endereço alocado (ou -1 se falha)
 */
.section .text
.balign 4
.global malloc_simple
.type malloc_simple, @function

malloc_simple:
    # a0 já contém o número de bytes
    # Usa syscall sbrk: a7 = 9
    li a7, 9
    ecall
    # a0 retorna o endereço antigo (novo bloco alocado)
    ret

.size malloc_simple, .-malloc_simple
````

---

## **Passo 3: Implementar `criar_no()` - Criar um Nó**

````assembly
/**
 * @brief Cria um novo nó da lista encadeada
 * 
 * @param[in] a0 Valor inteiro a armazenar
 * @return a0 Endereço do novo nó (ou 0 se falha)
 */
.section .text
.balign 4
.global criar_no
.type criar_no, @function

criar_no:
    # Prólogo Non-Leaf (chama malloc_simple)
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    
    # s0 salva o valor que será armazenado
    mv s0, a0
    
    # Aloca 12 bytes (tamanho do nó: 4 bytes valor + 8 bytes ponteiro)
    li a0, 12
    call malloc_simple
    
    # Se malloc falhou (a0 == 0), retorna 0
    beq a0, zero, .L_criar_no_erro
    
    # a0 contém o endereço do novo nó
    # Armazena o valor em offset 0
    sw s0, 0(a0)
    
    # Armazena NULL (0) no ponteiro proximo (offset 4)
    sd zero, 4(a0)
    
    # Epílogo
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.L_criar_no_erro:
    # Retorna 0 indicando erro
    li a0, 0
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.size criar_no, .-criar_no
````

---

## **Passo 4: Implementar `inserir_inicio()` - Inserir no Começo**

````assembly
/**
 * @brief Insere um valor no início da lista
 * 
 * @param[in] a0 Endereço do ponteiro para cabeça (ponteiro duplo)
 * @param[in] a1 Valor a inserir
 */
.section .text
.balign 4
.global inserir_inicio
.type inserir_inicio, @function

inserir_inicio:
    # Prólogo Non-Leaf
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    
    # s0 salva o endereço do ponteiro cabeça
    mv s0, a0
    
    # Cria um novo nó com o valor em a1
    mv a0, a1
    call criar_no
    
    # Se criação falhou, retorna
    beq a0, zero, .L_inserir_inicio_fim
    
    # a0 agora contém o endereço do novo nó
    # Carrega o valor atual da cabeça
    ld a1, 0(s0)
    
    # Faz o novo nó apontar para o antigo início
    # novo->proximo = *cabeca
    sd a1, 4(a0)
    
    # Atualiza a cabeça para apontar ao novo nó
    # *cabeca = novo
    sd a0, 0(s0)

.L_inserir_inicio_fim:
    # Epílogo
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.size inserir_inicio, .-inserir_inicio
````

---

## **Passo 5: Implementar `inserir_final()` - Inserir no Final**

````assembly
/**
 * @brief Insere um valor no final da lista
 * 
 * @param[in] a0 Endereço do ponteiro para cabeça
 * @param[in] a1 Valor a inserir
 */
.section .text
.balign 4
.global inserir_final
.type inserir_final, @function

inserir_final:
    # Prólogo Non-Leaf
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)
    
    # s0 = endereço do ponteiro cabeça
    # s1 = valor a inserir
    mv s0, a0
    mv s1, a1
    
    # Cria novo nó
    mv a0, s1
    call criar_no
    beq a0, zero, .L_inserir_final_fim
    
    # a0 = novo nó
    # Carrega a cabeça
    ld s2, 0(s0)
    
    # Se lista vazia, novo nó vira cabeça
    beq s2, zero, .L_inserir_final_vazio
    
    # Percorre lista até encontrar o último nó
.L_inserir_final_loop:
    # s2 = nó atual
    # Carrega proximo de s2
    ld a1, 4(s2)
    
    # Se proximo == NULL, encontrou o último
    beq a1, zero, .L_inserir_final_encontrado
    
    # Avança para próximo
    mv s2, a1
    jal zero, .L_inserir_final_loop

.L_inserir_final_encontrado:
    # s2 aponta para o último nó
    # Liga o último ao novo: ultimo->proximo = novo
    sd a0, 4(s2)
    jal zero, .L_inserir_final_fim

.L_inserir_final_vazio:
    # Lista vazia: novo nó vira cabeça
    sd a0, 0(s0)

.L_inserir_final_fim:
    # Epílogo
    ld s2, 0(sp)
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

.size inserir_final, .-inserir_final
````

---

## **Passo 6: Implementar `buscar()` - Procurar um Valor**

````assembly
/**
 * @brief Busca um valor na lista
 * 
 * @param[in] a0 Endereço da cabeça
 * @param[in] a1 Valor a procurar
 * @return a0 1 se encontrado, 0 caso contrário
 */
.section .text
.balign 4
.global buscar
.type buscar, @function

buscar:
    # a0 = cabeça
    # a1 = valor procurado
    
    # Se lista vazia, retorna 0
    beq a0, zero, .L_buscar_nao_encontrado

.L_buscar_loop:
    # Carrega valor do nó atual
    lw a2, 0(a0)
    
    # Se valor == procurado, encontrou
    beq a2, a1, .L_buscar_encontrado
    
    # Carrega próximo nó
    ld a0, 4(a0)
    
    # Se proximo != NULL, continua loop
    bne a0, zero, .L_buscar_loop

.L_buscar_nao_encontrado:
    li a0, 0
    ret

.L_buscar_encontrado:
    li a0, 1
    ret

.size buscar, .-buscar
````

---

## **Passo 7: Implementar `exibir()` - Mostrar a Lista**

Para exibir, você precisará chamar `printf`. Aqui está uma versão simplificada que imprime endereços:

````assembly
/**
 * @brief Exibe todos os elementos da lista
 * 
 * @param[in] a0 Endereço da cabeça
 */
.section .data
.align 3
fmt_inicio: .string "Lista: "
fmt_valor:  .string "%d -> "
fmt_nulo:   .string "NULL\n"

.section .text
.balign 4
.global exibir
.type exibir, @function

exibir:
    # Prólogo Non-Leaf
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    
    # s0 = cabeça
    mv s0, a0
    
    # Imprime "Lista: "
    la a0, fmt_inicio
    call printf
    
.L_exibir_loop:
    # Se nó nulo, termina
    beq s0, zero, .L_exibir_fim
    
    # Carrega valor do nó
    lw a1, 0(s0)
    
    # Imprime "%d -> "
    la a0, fmt_valor
    call printf
    
    # Avança para próximo
    ld s0, 4(s0)
    jal zero, .L_exibir_loop

.L_exibir_fim:
    # Imprime "NULL\n"
    la a0, fmt_nulo
    call printf
    
    # Epílogo
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.size exibir, .-exibir
````

---

## **Checklist de Implementação**

- [ ] Implementar `malloc_simple()` (syscall sbrk)
- [ ] Implementar `criar_no()` (aloca e inicializa)
- [ ] Implementar `inserir_inicio()` (adiciona no começo)
- [ ] Implementar `inserir_final()` (percorre até o fim)
- [ ] Implementar `buscar()` (loop linear)
- [ ] Implementar `exibir()` (printf de cada valor)
- [ ] Testar em **RARS** ou **Venus**

---

## **Próximos Passos**

Quer que eu implemente também `remover_inicio()` e uma `main()` em assembly para testar?
