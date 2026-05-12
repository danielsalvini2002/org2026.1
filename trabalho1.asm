.data
    head:               .word 0
    espaco:             .string " "
    msg_menu:           .string "\nMenu:\n0. Sair \n1. Adicionar inteiro \n2. Remover por indice \n3. Imprimir lista \n Insira sua escolha: "
    msg_invalid:        .string "\nInvalid Option\n"
    msg_val:            .string "\nEnter value to insert at the end:\n"
    msg_idx:            .string "\nEnter index to remove:\n"
    msg_empty:          .string "\nEmpty list!\n"
    
    jumptable:
        .word exit
        .word insert_int
        .word remove_index
        .word print

.text
##################################################################
# Menu
##################################################################
menu:
    li a7, 4              
    la a0, msg_menu
    ecall  
    li a7, 5
    ecall

menu_input_validation:
    bltz a0, invalid_menu_option 
    li t0, 3
    bgt a0, t0, invalid_menu_option  

branch_menu:
    slli    t0, a0, 2 
    la      t1, jumptable
    add     t0, t0, t1
    lw      t0, 0(t0)
    jalr    zero, t0, 0

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
    ecall           
    
    jal ra, insert_node
    j menu
insert_node:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    mv s0, a0       
    li a0, 8        
    li a7, 9
    ecall
    
    mv s1, a0       
    sw s0, 0(s1)    
    sw zero, 4(s1)  
    
    la t0, head
    lw t1, 0(t0)
    beq t1, zero, insert_first
    
    mv s2, t1       
    j find_last

insert_first:
    sw s1, 0(t0)    
    j return

find_last:
    lw t2, 4(s2)    
    beq t2, zero, insert_here
    mv s2, t2
    j find_last

insert_here:
    sw s1, 4(s2)    

return:
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra
##################################################################
# Remover por indice
##################################################################
remove_index:
    li a7, 4
    la a0, msg_idx
    ecall
    li a7, 5
    ecall
    mv t0, a0       

    la t1, head
    lw t2, 0(t1)    
    beqz t2, empty_list
    mv t3, x0       

remove_loop:
    beqz t2, empty_list
    beqz t0, remove_here
    addi t0, t0, -1
    mv t3, t2       
    lw t2, 4(t2)    
    j remove_loop

remove_here:
    lw t4, 4(t2)    
    beqz t3, remove_head
    sw t4, 4(t3)    
    j menu

remove_head:
    sw t4, 0(t1)    
    j menu

##################################################################
# Imprime lista
##################################################################
print:
    la t1, head
    lw t2, 0(t1)
    beqz t2, empty_list

print_loop:
    beqz t2, print_end
    lw a0, 0(t2)
    li a7, 1
    ecall

    li a7, 4
    la a0, espaco
    ecall

    lw t2, 4(t2)
    j print_loop

print_end:
    li a0, 10
    li a7, 11
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
    li a7, 93
    ecall