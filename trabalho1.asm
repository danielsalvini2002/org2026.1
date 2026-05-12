.data
    head:               .word 0             # Ponteiro para o início da lista
    espaco:             .string " "
    msg_menu:           .string "\nMenu:\n0. Sair \n1. Adicionar inteiro \n2. Remover por indice \n3. Imprimir lista \n Insira sua escolha: "
    msg_invalid:        .string "\nInvalid Option\n"
    msg_val:            .string "\nEnter value to insert at the end:\n"
    msg_idx:            .string "\nEnter index to remove:\n"
    msg_empty:          .string "\nEmpty list!\n"
    
    jumptable:                              # Tabela de endereços de funções para o menu
        .word exit
        .word insert_int
        .word remove_index
        .word print

.text
##################################################################
# Menu
##################################################################
menu:
    li a7, 4              # Syscall 4: imprimir string, nesse caso vai ser msg_menu que definimos acima
    la a0, msg_menu 
    ecall  
    li a7, 5              # Syscall 5: ler inteiro do usuário
    ecall

menu_input_validation:
    bltz a0, invalid_menu_option # BLTZ(Branch if Less Than Zero) = Se a escolha (a0) for menor que 0, vai para opção inválida
    li t0, 3
    bgt a0, t0, invalid_menu_option  # BGT(Branch if Greater Than) = Valida se a entrada está entre 0 e 3

branch_menu:
    slli    t0, a0, 2     # Multiplica a opção por 4 (tamanho de uma word) para achar o deslocamento
    la      t1, jumptable
    add     t0, t0, t1    # Soma o deslocamento à base da tabela para achar a função certa
    lw      t0, 0(t0)
    jalr    zero, t0, 0   # Salto dinâmico para a função escolhida

invalid_menu_option:
    li a7, 4
    la a0, msg_invalid
    ecall
    j menu
##################################################################
# Adicionar inteiro
##################################################################
insert_int:
    li a7, 4
    la a0, msg_val
    ecall
    li a7, 5
    ecall                 # a0 recebe o valor a ser inserido
    
    jal ra, insert_node   # Chama rotina de inserção, salvando endereço de retorno em 'ra'
    j menu

insert_node:
    addi sp, sp, -16      # Prólogo: aloca espaço na pilha para não perder registradores (S e RA)
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    mv s0, a0           # Guarda o valor a ser inserido
    li a0, 8            # Tamanho do novo nó: 8 bytes (4 para valor, 4 para o ponteiro 'next')
    li a7, 9            # Syscall 9 (sbrk): aloca memória dinamicamente
    ecall               # a0 retorna o endereço de memória alocado para o novo nó
    
    mv s1, a0           # s1 = endereço do novo nó
    sw s0, 0(s1)        # Salva o valor no nó (primeiros 4 bytes)
    sw zero, 4(s1)      # Inicia o ponteiro 'next' do nó como NULL (últimos 4 bytes)
    
    la t0, head
    lw t1, 0(t0)
    beq t1, zero, insert_first # Se a lista estiver vazia, o nó será o 'head'
    
    mv s2, t1           # s2 é usado para percorrer a lista
    j find_last

insert_first:
    sw s1, 0(t0)        # Faz o head apontar para o novo nó recém-criado
    j return

find_last:
    lw t2, 4(s2)        # Carrega o ponteiro 'next' do nó atual
    beq t2, zero, insert_here # Se for NULL, chegamos ao final da lista
    mv s2, t2           # Senão, avança para o próximo nó
    j find_last

insert_here:
    sw s1, 4(s2)        # Conecta o último nó atual ao novo nó inserido

return:
    lw s2, 0(sp)          # Restaura os registradores da pilha
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16       # Desaloca a pilha
    jr ra                 # Retorna de onde a função foi chamada
    
##################################################################
# Remover por indice
##################################################################
remove_index:
    li a7, 4
    la a0, msg_idx
    ecall
    li a7, 5
    ecall
    mv t0, a0           # t0 = índice alvo da remoção

    la t1, head
    lw t2, 0(t1)        # t2 = 'current' (nó atual da iteração)
    beqz t2, empty_list
    mv t3, x0           # t3 = 'prev' (nó anterior), inicia como NULL

remove_loop:
    beqz t2, empty_list # Se chegou no fim da lista sem achar, aborta
    beqz t0, remove_here # Se o índice zerou, chegamos no nó correto
    addi t0, t0, -1     # Decrementa o índice alvo
    mv t3, t2           # Atualiza 'prev' com o nó atual
    lw t2, 4(t2)        # Avança 'current' para o próximo
    j remove_loop

remove_here:
    lw t4, 4(t2)        # t4 = 'next' do nó que será removido
    beqz t3, remove_head # Se 'prev' é NULL, estamos removendo a cabeça (head) da lista
    sw t4, 4(t3)        # Desconecta o nó: prev->next aponta para current->next
    j menu

remove_head:
    sw t4, 0(t1)        # Atualiza o ponteiro 'head' para pular o primeiro nó
    j menu

##################################################################
# Imprime lista
##################################################################
print:
    la t1, head
    lw t2, 0(t1)
    beqz t2, empty_list

print_loop:
    beqz t2, print_end  # Encerra quando o ponteiro for NULL (fim da lista)
    lw a0, 0(t2)
    li a7, 1            # Syscall 1: imprimir inteiro
    ecall

    li a7, 4
    la a0, espaco
    ecall

    lw t2, 4(t2)        # Avança para o próximo nó para imprimir
    j print_loop

print_end:
    li a0, 10           # Código ASCII para quebra de linha ('\n')
    li a7, 11           # Syscall 11: imprimir caractere
    ecall
    j menu

empty_list:
    li a7, 4
    la a0, msg_empty
    ecall
    j menu

##################################################################
# Sair
##################################################################
exit:
    li a7, 93           # Syscall 93: encerra a execução do programa
    ecall