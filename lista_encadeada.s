.data
    # Declare suas variáveis e dados aqui
    
.text
.globl main

main:
    # Insira a lógica do seu programa aqui
    
    
    # Encerrar o programa (syscall de exit)
    li a7, 93       # System call para exit (93)
    li a0, 0        # Código de retorno 0 (sucesso)
    ecall