#
# CÓDIGO GERADO POR IA PARA FIM DE TESTES
#

.data
    # Aqui iriam suas strings ou dados estáticos, se precisar depois.

.text
.globl main

main:
    # --- PRÓLOGO DO MAIN ---
    # Vamos preparar a stack pointer (sp)
    addi sp, sp, -16
    sw ra, 12(sp)

    # --- TESTE DA ALOCAÇÃO DINÂMICA ---
    # Vamos pedir 16 bytes (espaço para 4 inteiros de 32 bits)
    li a0, 16
    jal ra, malloc      # Instrução de salto e ligação (jal) exigida no trabalho

    # Neste ponto, a0 contém o endereço base da memória alocada no heap!
    
    # Vamos testar gravando o número 42 no primeiro espaço alocado
    li t0, 42
    sw t0, 0(a0)        # Salva 42 no endereço apontado por a0

    # --- EPÍLOGO DO MAIN ---
    lw ra, 12(sp)
    addi sp, sp, 16

    # --- ENCERRAR PROGRAMA (Syscall 10) ---
    li a7, 10
    ecall

# ==========================================
# FUNÇÃO: malloc
# Descrição: Simula o malloc em C. Aloca memória no heap.
# Argumentos: a0 = quantidade de bytes a alocar
# Retorno: a0 = endereço base da memória alocada no heap
# ==========================================
malloc:
    # --- PRÓLOGO DA FUNÇÃO ---
    # Convenção de salvamento de registradores na stack (exigido no trabalho)
    addi sp, sp, -16    # Aloca 16 bytes na pilha (deve ser múltiplo de 16)
    sw ra, 12(sp)       # Salva o endereço de retorno (Return Address)
    sw s0, 8(sp)        # Salva o registrador salvo s0 (boa prática)

    # --- CORPO DA FUNÇÃO ---
    # Nos simuladores RARS/Venus/Ripes, o syscall 9 (sbrk) aloca memória heap
    # O registrador a0 já contém a quantidade de bytes (passado pelo main)
    li a7, 9            # Carrega o código do syscall 9 (sbrk) em a7
    ecall               # Faz a chamada de sistema. O endereço alocado volta em a0.

    # --- EPÍLOGO DA FUNÇÃO ---
    # Restaura os registradores exatamente na ordem inversa
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16     # Desaloca o espaço da pilha

    # Retorna para quem chamou (exigido no trabalho)
    jalr zero, ra, 0