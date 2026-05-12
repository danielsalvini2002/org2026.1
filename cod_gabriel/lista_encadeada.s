# LISTA ENCADEADA ASSEMBLY

# TRABALHO 1 ORGANIZACAO DE COMPUTADORES
# GABRIEL WEBER, TAINARA, BRUNO E DANIEL

.data
    head: .word 0

insert_node: #a0 recebe o valor à ser inserido
    addi sp, sp, -16 # sp = sp + 16 // move o sp 16 bytes pra frente

    sw ra, 12(sp) # sp[3] = ra // salva o return address na stack

    sw s0, 8(sp) # sp[2] = s0
    sw s1, 4(sp) # sp[2] = s1
    sw s2, 0(sp) # sp[2] = s2
    # salva s0, s1 e s2 na stack

    # o código acima acontece para que seja possível utilizar o s0, s1, s2 e ra durante a execução e restaura-los no fim da execução, conforme padrão de código

    mv s0, a0 #salva o valor de a0 em s0
    # isso acontece pq a0 e a7 são usados como entrada para o 'ecall'. Como a0 também é entrada para a funcao insert_node, salvamos em s0.

    # ALOCACAO DE MEM NO HEAP
    # essa parte do código prepara os registradores para que o ecall faça a reserva dos endereços no heap, conforme o uso do ecall

    li a0 8 # O valor 8 em a0 sinaliza ao ecall que deve alocar 8 bytes

    li a7, 9 # O valor 0 em a7 sinaliza ao ecall que deve alocar memória no heap (chamar o sbrk)

    ecall # executa a instrução em a7 usando a0 como parâmetro
    # nesse caso, aloca 8 bytes no heap

    mv s1, a0 # salva em s1 o ponteiro dos bytes reservados pelo ecall 

    # CRIACAO NOVO NODE
    # essa parte do código armazena o valor da entrada (s0) (node->valor) no local alocado no heap (s1) e inicializa o ponteiro para o próximo nó (node->next)

    sw s0, 0(s1) # escreve o que está em s0 no ponteiro alocado na heap (s1)
    # node->value

    sw zero, 4(s1) # incializa o pointeiro para o próximo nó na próxima posição de s1 (s1[1])
    # node->next

    # INSERCAO NA LISTA

    la t0, head # carrega o ponteiro do nó inicial que está salvo na variável head em t0

    lw t1, 0(t0) #carrega o nó em si

    beq t1, zero, insert_first # se t1 for zero, não há nenhum nó salvo, então salva o primeiro chamando insert_first

    # se não
    mv s1, t1 # s2 = current = head

    # como aqui não tem return nem jal, ele simplesmente segue executando a find_last:
    
find_last:
    lw t2, 4(s2)