.data
    msg_inicio:     .string "=== Iniciando programa ===\n"
    msg_alocacao:   .string "Alocando 12 bytes para no de lista...\n"
    msg_sucesso:    .string "Alocacao bem-sucedida! Endereco: 0x"
    msg_erro:       .string "Erro: Alocacao falhou!\n"
    msg_fim:        .string "=== Programa finalizado ===\n"
    msg_syscall:    .string "[INFO] Executando syscall sbrk...\n"
    msg_valor_hex:  .string "Valor hexadecimal: "

.text

# ===== FUNCAO: print_string =====
# Descricao: Imprime uma string na saida padrao
#
# Equivalente em C:
# void print_string(const char *str) {
#     while (*str != '\0') {
#         putchar(*str++);
#     }
# }
#
# Argumentos:
#   a0 = endereco da string terminada em '\0'
#
# Retorno:
#   Nenhum

print_string:
    # ===== SECAO: Loop de Impressao =====
    # Itera pela string imprimindo cada caractere

    addi sp, sp, -16                    # Aloca espaco na pilha
    sw ra, 12(sp)                       # Salva registrador de retorno
    mv s0, a0                           # Move endereco da string para s0

.L_print_string_loop:
    lbu a0, 0(s0)                       # Carrega byte da string
    beq a0, zero, .L_print_string_fim   # Se eh '\0', salta para fim

    call print_char                     # Imprime o caractere
    addi s0, s0, 1                      # Incrementa ponteiro da string
    j .L_print_string_loop              # Volta ao inicio do loop

.L_print_string_fim:
    lw ra, 12(sp)                       # Restaura registrador de retorno
    addi sp, sp, 16                     # Libera espaco da pilha
    ret

# ===== FIM DA FUNCAO: print_string =====


# ===== FUNCAO: print_char =====
# Descricao: Imprime um caractere na saida padrao
#
# Equivalente em C:
# void print_char(char c) {
#     putchar(c);
# }
#
# Argumentos:
#   a0 = codigo ASCII do caractere a imprimir
#
# Retorno:
#   Nenhum

print_char:
    # ===== SECAO: Syscall write =====
    # Utiliza syscall write para imprimir na stdout (fd=1)

    addi sp, sp, -16                    # Aloca espaco na pilha
    sw a0, 12(sp)                       # Salva o caractere na pilha

    li a7, 64                           # Carrega 64 em a7 (numero da syscall write)
    li a1, 12                           # a1 = endereco do caractere (sp + offset)
    add a1, a1, sp                      # Calcula endereco absoluto
    li a2, 1                            # a2 = numero de bytes a escrever (1 byte)
    li a0, 1                            # a0 = file descriptor (1 = stdout)
    ecall                               # Realiza syscall write

    addi sp, sp, 16                     # Libera espaco da pilha
    ret

# ===== FIM DA FUNCAO: print_char =====


# ===== FUNCAO: print_hex =====
# Descricao: Imprime um valor inteiro em formato hexadecimal
#
# Equivalente em C:
# void print_hex(int value) {
#     for (int i = 7; i >= 0; i--) {
#         int nibble = (value >> (i * 4)) & 0xF;
#         putchar(nibble < 10 ? ('0' + nibble) : ('A' + nibble - 10));
#     }
# }
#
# Argumentos:
#   a0 = valor inteiro a ser impresso em hexadecimal
#
# Retorno:
#   Nenhum

print_hex:
    # ===== SECAO: Setup =====
    # Prepara registradores para impressao hexadecimal

    addi sp, sp, -16                    # Aloca espaco na pilha
    sw ra, 12(sp)                       # Salva registrador de retorno
    sw s0, 8(sp)                        # Salva s0 para armazenar valor
    mv s0, a0                           # Move valor para s0

    li t0, 7                            # Contador de nibbles (8 nibbles para 32 bits)

.L_print_hex_loop:
    # ===== SECAO: Extracao de Nibble =====
    # Extrai um nibble por vez (4 bits)

    srl a0, s0, t0                      # Shift right lógico de t0*4 posicoes
    slli a0, a0, 28                     # Shift para isolar o nibble
    srli a0, a0, 28                     # Shift right para obter valor 0-15

    # ===== SECAO: Conversao para Caractere =====
    # Converte valor 0-15 em caractere hex (0-9, A-F)

    addi a1, a0, -10                    # a1 = a0 - 10
    bgez a1, .L_print_hex_letter        # Se a0 >= 10, imprime letra

    # Caso: digito (0-9)
    addi a0, a0, 48                     # Adiciona 48 para obter caractere ASCII '0'-'9'
    j .L_print_hex_print

.L_print_hex_letter:
    # Caso: letra (A-F)
    addi a0, a0, 55                     # Adiciona 55 para obter caractere ASCII 'A'-'F'

.L_print_hex_print:
    call print_char                     # Imprime o caractere
    addi t0, t0, -1                     # Decrementa contador
    bge t0, zero, .L_print_hex_loop     # Continua enquanto contador >= 0

    # ===== SECAO: Finalizacao =====
    lw s0, 8(sp)                        # Restaura s0
    lw ra, 12(sp)                       # Restaura registrador de retorno
    addi sp, sp, 16                     # Libera espaco da pilha
    ret

# ===== FIM DA FUNCAO: print_hex =====


# ===== FUNCAO: main =====
# Descricao: Funcao principal que orquestra o programa
#
# Equivalente em C:
# int main() {
#     printf("=== Iniciando programa ===\n");
#     printf("Alocando 12 bytes para no de lista...\n");
#     void *no = malloc_simple(12);
#     if (no != NULL) {
#         printf("Alocacao bem-sucedida!\n");
#     } else {
#         printf("Erro: Alocacao falhou!\n");
#     }
#     printf("=== Programa finalizado ===\n");
#     return 0;
# }
#
# Retorno:
#   a0 = 0 (sucesso)

main:
    # ===== SECAO: Prologo =====
    # Aloca espaco na pilha (Non-Leaf, pois chama outras funcoes)

    addi sp, sp, -32                    # Reduz stack pointer em 32 bytes (alinhamento 16)
    sw ra, 28(sp)                       # Salva registrador de retorno na pilha
    sw s0, 24(sp)                       # Salva s0 para armazenar endereco alocado

    # ===== SECAO: Mensagem Inicial =====
    # Exibe mensagem de inicio

    la a0, msg_inicio                   # Carrega endereco da string
    call print_string                   # Imprime mensagem de inicio

    # ===== SECAO: Mensagem de Alocacao =====
    # Exibe mensagem antes de alocar

    la a0, msg_alocacao                 # Carrega endereco da string
    call print_string                   # Imprime mensagem

    # ===== SECAO: Alocacao de Memoria =====
    # Aloca 12 bytes para um no de lista encadeada

    li a0, 12                           # Carrega 12 em a0 (tamanho do no)
    call malloc_simple                  # Chama funcao de alocacao
    mv s0, a0                           # Armazena endereco em s0

    # ===== SECAO: Verificacao de Alocacao =====
    # Verifica se a alocacao foi bem-sucedida

    beq s0, zero, .L_main_erro          # Se s0 == 0, salta para tratamento de erro

    # ===== SECAO: Mensagem de Sucesso =====
    # Exibe endereco alocado

    la a0, msg_sucesso                  # Carrega endereco da string
    call print_string                   # Imprime mensagem
    
    mv a0, s0                           # Move endereco alocado para a0
    call print_hex                      # Imprime endereco em hexadecimal

    li a0, '\n'                         # Carrega caractere de nova linha
    call print_char                     # Imprime nova linha

    j .L_main_fim                       # Pula para o fim

.L_main_erro:
    # ===== SECAO: Tratamento de Erro =====
    # Alocacao falhou

    la a0, msg_erro                     # Carrega endereco da string de erro
    call print_string                   # Imprime mensagem de erro

.L_main_fim:
    # ===== SECAO: Mensagem Final =====
    # Exibe mensagem de encerramento

    la a0, msg_fim                      # Carrega endereco da string
    call print_string                   # Imprime mensagem de fim

    # ===== SECAO: Epilogo =====
    # Libera espaco da pilha

    li a0, 0                            # Define a0 = 0 (sucesso)
    lw s0, 24(sp)                       # Restaura s0
    lw ra, 28(sp)                       # Restaura registrador de retorno
    addi sp, sp, 32                     # Incrementa stack pointer em 32 bytes
    ret                                 # Retorna ao SO

# ===== FIM DA FUNCAO: main =====


# ===== FUNCAO: malloc_simple =====
# Descricao: Aloca memoria no heap usando a syscall sbrk
#
# Equivalente em C:
# void* malloc_simple(int size) {
#     return sbrk(size);
# }
#
# Argumentos:
#   a0 = numero de bytes a alocar
#
# Retorno:
#   a0 = endereco de memoria alocado (ou 0 em caso de erro)

malloc_simple:
    # ===== SECAO: Syscall sbrk =====
    # Realiza a chamada de sistema sbrk para expandir o heap

    li a7, 9                            # Carrega 9 em a7 (numero da syscall sbrk)
    ecall                               # Realiza a chamada de sistema
    # a0 contem o endereco alocado apos ecall

    # ===== SECAO: Retorno =====
    # Retorna o endereco alocado

    ret                                 # Retorna com endereco em a0

# ===== FIM DA FUNCAO: malloc_simple =====