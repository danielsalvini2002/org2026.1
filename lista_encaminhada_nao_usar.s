# ================================================================================
# LISTA ENCADEADA EM ASSEMBLY RISC-V
# Disciplina: Organização de Computadores
# Compatível com: RARS e Venus
# ================================================================================
# Este programa implementa uma lista encadeada simples com:
# - Inserção de nós no final da lista
# - Impressão de todos os valores
# - Alocação dinâmica de memória (heap)
# - Convenção de chamadas RISC-V (salvamento de ra e registradores salvos)
# ================================================================================

.data
    # Mensagens para interação com o usuário
    msg_menu:       .string "\n=== LISTA ENCADEADA EM RISC-V ===\n"
    msg_opcoes:     .string "1. Inserir valor na lista\n2. Imprimir lista\n3. Sair\nEscolha: "
    msg_input:      .string "Digite o valor a inserir: "
    msg_lista:      .string "\nConteúdo da lista: "
    msg_vazia:      .string "Lista vazia!\n"
    msg_seta:       .string " -> "
    msg_null:       .string "NULL\n"
    msg_inserido:   .string "Valor inserido com sucesso!\n"
    msg_saindo:     .string "Encerrando programa...\n"
    
    # Ponteiro para o início da lista (head)
    # Inicialmente NULL (0)
    head:           .word 0

.text
.globl main

# ================================================================================
# FUNÇÃO PRINCIPAL (main)
# ================================================================================
# Descrição: Controla o menu principal e coordena as operações da lista
# Registradores usados:
#   s0 - salva o valor de escolha do menu
#   s1 - salva valores temporários
# ================================================================================
main:
    # PROLOGUE: Salvar registradores na pilha
    addi sp, sp, -8          # Reserva 8 bytes na pilha (2 words)
    sw   ra, 4(sp)           # Salva o endereço de retorno (ra)
    sw   s0, 0(sp)           # Salva o registrador s0 (será usado para escolha)

menu_loop:
    # Exibe o menu
    la   a0, msg_menu        # Carrega endereço da mensagem do menu
    li   a7, 4               # Syscall 4: print_string
    ecall
    
    la   a0, msg_opcoes      # Carrega endereço das opções
    li   a7, 4               # Syscall 4: print_string
    ecall
    
    # Lê a escolha do usuário
    li   a7, 5               # Syscall 5: read_int
    ecall
    mv   s0, a0              # Salva a escolha em s0
    
    # Verifica a escolha
    li   t0, 1
    beq  s0, t0, opcao_inserir   # Se escolha == 1, vai para inserir
    
    li   t0, 2
    beq  s0, t0, opcao_imprimir  # Se escolha == 2, vai para imprimir
    
    li   t0, 3
    beq  s0, t0, opcao_sair      # Se escolha == 3, sai do programa
    
    # Escolha inválida, volta ao menu
    j    menu_loop

opcao_inserir:
    # Solicita o valor a ser inserido
    la   a0, msg_input       # Carrega mensagem
    li   a7, 4               # Syscall 4: print_string
    ecall
    
    li   a7, 5               # Syscall 5: read_int
    ecall
    mv   s1, a0              # Salva o valor lido em s1
    
    # Chama a função para inserir na lista
    mv   a0, s1              # Passa o valor como argumento em a0
    jal  ra, insert_node     # Chamada de função: jal salva PC+4 em ra
    
    # Mensagem de confirmação
    la   a0, msg_inserido
    li   a7, 4
    ecall
    
    j    menu_loop           # Volta ao menu

opcao_imprimir:
    # Chama a função para imprimir a lista
    jal  ra, print_list      # Chamada de função
    j    menu_loop           # Volta ao menu

opcao_sair:
    # Mensagem de saída
    la   a0, msg_saindo
    li   a7, 4
    ecall
    
    # EPILOGUE: Restaurar registradores e retornar
    lw   s0, 0(sp)           # Restaura s0
    lw   ra, 4(sp)           # Restaura ra
    addi sp, sp, 8           # Libera espaço da pilha
    
    # Encerra o programa
    li   a7, 10              # Syscall 10: exit
    ecall

# ================================================================================
# FUNÇÃO: insert_node
# ================================================================================
# Descrição: Insere um novo nó no final da lista encadeada
# Argumentos:
#   a0 - valor a ser inserido no nó
# Retorno: nenhum
# Registradores usados:
#   s0 - valor a ser inserido (preservado)
#   s1 - ponteiro para o novo nó alocado
#   s2 - ponteiro para percorrer a lista (current)
# Estrutura do nó:
#   offset 0: data (valor inteiro, 4 bytes)
#   offset 4: next (ponteiro para próximo nó, 4 bytes)
#   Total: 8 bytes por nó
# ================================================================================
insert_node:
    # PROLOGUE: Salvar registradores na pilha
    addi sp, sp, -16         # Reserva 16 bytes na pilha (4 words)
    sw   ra, 12(sp)          # Salva ra (endereço de retorno)
    sw   s0, 8(sp)           # Salva s0 (valor)
    sw   s1, 4(sp)           # Salva s1 (novo nó)
    sw   s2, 0(sp)           # Salva s2 (current pointer)
    
    mv   s0, a0              # Salva o valor em s0
    
    # ===== ALOCAÇÃO DINÂMICA DE MEMÓRIA =====
    # Aloca 8 bytes no heap para o novo nó
    li   a0, 8               # Tamanho a alocar: 8 bytes (data + next)
    li   a7, 9               # Syscall 9: sbrk (aloca memória no heap)
    ecall                    # Retorna em a0 o endereço do bloco alocado
    mv   s1, a0              # Salva o ponteiro do novo nó em s1
    
    # ===== INICIALIZAÇÃO DO NOVO NÓ =====
    sw   s0, 0(s1)           # nó->data = valor (armazena no offset 0)
    sw   zero, 4(s1)         # nó->next = NULL (armazena no offset 4)
    
    # ===== INSERÇÃO NA LISTA =====
    # Verifica se a lista está vazia (head == NULL)
    la   t0, head            # Carrega endereço da variável head
    lw   t1, 0(t0)           # Carrega o valor de head (ponteiro)
    
    beq  t1, zero, insert_first  # Se head == NULL, é o primeiro nó
    
    # Lista não está vazia: percorrer até o último nó
    mv   s2, t1              # s2 = current = head
    
find_last:
    lw   t2, 4(s2)           # t2 = current->next
    beq  t2, zero, found_last # Se current->next == NULL, encontrou o último
    mv   s2, t2              # current = current->next
    j    find_last           # Continua procurando
    
found_last:
    # s2 aponta para o último nó
    sw   s1, 4(s2)           # último->next = novo_nó
    j    insert_done
    
insert_first:
    # Lista vazia: novo nó se torna o head
    sw   s1, 0(t0)           # head = novo_nó
    
insert_done:
    # EPILOGUE: Restaurar registradores e retornar
    lw   s2, 0(sp)           # Restaura s2
    lw   s1, 4(sp)           # Restaura s1
    lw   s0, 8(sp)           # Restaura s0
    lw   ra, 12(sp)          # Restaura ra
    addi sp, sp, 16          # Libera espaço da pilha
    
    jalr zero, ra, 0         # Retorna para o chamador (equivalente a ret)

# ================================================================================
# FUNÇÃO: print_list
# ================================================================================
# Descrição: Imprime todos os valores da lista encadeada
# Argumentos: nenhum
# Retorno: nenhum
# Registradores usados:
#   s0 - ponteiro para o nó atual (current)
# ================================================================================
print_list:
    # PROLOGUE: Salvar registradores na pilha
    addi sp, sp, -8          # Reserva 8 bytes na pilha
    sw   ra, 4(sp)           # Salva ra
    sw   s0, 0(sp)           # Salva s0
    
    # Exibe cabeçalho
    la   a0, msg_lista
    li   a7, 4
    ecall
    
    # Carrega o ponteiro head
    la   t0, head
    lw   s0, 0(t0)           # s0 = current = head
    
    # Verifica se a lista está vazia
    beq  s0, zero, print_empty
    
print_loop:
    # Imprime o valor do nó atual
    lw   a0, 0(s0)           # a0 = current->data
    li   a7, 1               # Syscall 1: print_int
    ecall
    
    # Carrega o próximo nó
    lw   t1, 4(s0)           # t1 = current->next
    
    # Verifica se há próximo nó
    beq  t1, zero, print_last # Se next == NULL, é o último
    
    # Imprime a seta
    la   a0, msg_seta
    li   a7, 4
    ecall
    
    # Avança para o próximo nó
    mv   s0, t1              # current = current->next
    j    print_loop
    
print_last:
    # Imprime " -> NULL"
    la   a0, msg_seta
    li   a7, 4
    ecall
    
    la   a0, msg_null
    li   a7, 4
    ecall
    j    print_done
    
print_empty:
    # Lista vazia
    la   a0, msg_vazia
    li   a7, 4
    ecall
    
print_done:
    # EPILOGUE: Restaurar registradores e retornar
    lw   s0, 0(sp)           # Restaura s0
    lw   ra, 4(sp)           # Restaura ra
    addi sp, sp, 8           # Libera espaço da pilha
    
    jalr zero, ra, 0         # Retorna (equivalente a ret)

# ================================================================================
# FIM DO PROGRAMA
# ================================================================================