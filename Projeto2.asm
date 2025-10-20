.data
    msgN:       .asciiz "Qual o tamanho da sua matriz? (N): "
    msgErrN:    .asciiz "\nN invalido (<=0) ou falta de memoria.\n"
    msgVal:     .asciiz "\nDigite o valor da posicao "
    msgMat:     .asciiz "\nA matriz digitada foi:\n"
    msgInversa: .asciiz "\nA matriz inversa eh:\n"
    msgSing:    .asciiz "\nEssa matriz nao tem inversa (singular).\n"
    espaco:     .asciiz " "
    newline:    .asciiz "\n"
    eps:        .float 0.000001
    fzero:      .float 0.0

.text
.globl main
main:
    # Pergunta N
    li $v0, 4
    la $a0, msgN
    syscall

    # Lê N (inteiro)
    li $v0, 5
    syscall
    move $s0, $v0

    blez $s0, errN

    # Calcula bytes
    mul $t1, $t0, $t0
    sll $t2, $t1, 3
    move $a0, $t2
    li $v0, 9
    syscall
    beqz $v0, errN
    move $s1, $v0 

    # totalFloats
    move $t3, $t1
    sll $t3, $t3, 1
    li $t4, 0

init_zero_loop:
    beq $t4, $t3, after_init_zero
    sll $t5, $t4, 2
    add $t6, $s1, $t5
    l.s $f2, fzero
    s.s $f2, 0($t6)
    addi $t4, $t4, 1
    j init_zero_loop
    
after_init_zero:
    # Ler matriz A (N x N)
    li $t7, 0     
          
read_rows:
    bge $t7, $s0, after_read
    li $t8, 0
read_cols:
    bge $t8, $s0, end_cols

    li $v0, 4
    la $a0, msgVal
    syscall

    li $v0, 1
    move $a0, $t7
    syscall
    li $v0, 4
    la $a0, espaco
    syscall
    li $v0, 1
    move $a0, $t8
    syscall

    li $v0, 6
    syscall

    mul $t9, $t7, $s0
    sll $t9, $t9, 1
    add $t9, $t9, $t8
    sll $t9, $t9, 2
    add $t5, $s1, $t9
    s.s $f0, 0($t5)

    addi $t8, $t8, 1
    j read_cols
end_cols:

    # Colocar 1.0 na identidade
    add $t8, $s0, $t7
    mul $t9, $t7, $s0
    sll $t9, $t9, 1
    add $t9, $t9, $t8
    sll $t9, $t9, 2
    add $t5, $s1, $t9
    l.s $f6, eps
    div.s $f4, $f6, $f6
    s.s $f4, 0($t5)

    addi $t7, $t7, 1
    j read_rows
after_read:

    # Imprime matriz original
    li $v0, 4
    la $a0, msgMat
    syscall

    li $t7, 0
print_rows:
    bge $t7, $s0, after_print
    li $t8, 0
print_cols:
    bge $t8, $s0, next_row
    mul $t9, $t7, $s0
    sll $t9, $t9, 1
    add $t9, $t9, $t8
    sll $t9, $t9, 2
    add $t5, $s1, $t9
    l.s $f12, 0($t5)
    li $v0, 2
    syscall
    li $v0, 4
    la $a0, espaco
    syscall
    addi $t8, $t8, 1
    j print_cols
next_row:
    li $v0, 4
    la $a0, newline
    syscall
    addi $t7, $t7, 1
    j print_rows
after_print:

    # Início Gauss-Jordan 
    li $t7, 0            
gauss_outer:
    bge $t7, $s0, done_gauss

    # pivot = A[i][i]
    mul $t8, $t7, $s0
    sll $t8, $t8, 1
    add $t8, $t8, $t7
    sll $t8, $t8, 2
    add $t5, $s1, $t8
    l.s $f16, 0($t5)

    l.s $f2, fzero
    c.eq.s $f16, $f2
    bc1t singular

    # Normaliza linha i
    sll $t9, $s0, 1
    li $t0, 0
    
    
norm_loop:
    beq $t0, $t9, end_norm
    mul $t1, $t7, $s0
    sll $t1, $t1, 1
    add $t1, $t1, $t0
    sll $t1, $t1, 2
    add $t5, $s1, $t1
    l.s $f18, 0($t5)
    div.s $f19, $f18, $f16
    s.s $f19, 0($t5)
    addi $t0, $t0, 1
    j norm_loop
    
end_norm:
    li $t0, 0
    
elim_rows:
    bge $t0, $s0, end_elim
    beq $t0, $t7, skip_row
    mul $t1, $t0, $s0
    sll $t1, $t1, 1
    add $t1, $t1, $t7
    sll $t1, $t1, 2
    add $t5, $s1, $t1
    l.s $f20, 0($t5)

    sll $t9, $s0, 1
    li $t2, 0
    
elim_cols:
    beq $t2, $t9, end_elim_cols
    mul $t3, $t0, $s0
    sll $t3, $t3, 1
    add $t3, $t3, $t2
    sll $t3, $t3, 2
    add $t6, $s1, $t3
    l.s $f21, 0($t6)

    mul $t4, $t7, $s0
    sll $t4, $t4, 1
    add $t4, $t4, $t2
    sll $t4, $t4, 2
    add $t5, $s1, $t4
    l.s $f22, 0($t5)

    mul.s $f23, $f20, $f22
    sub.s $f24, $f21, $f23
    s.s $f24, 0($t6)

    addi $t2, $t2, 1
    j elim_cols
    
end_elim_cols:
    addi $t0, $t0, 1
    j elim_rows
    
skip_row:
    addi $t0, $t0, 1
    j elim_rows
    
end_elim:
    addi $t7, $t7, 1
    j gauss_outer
    
singular:
    li $v0, 4
    la $a0, msgSing
    syscall
    j fim
    
done_gauss:
    li $v0, 4
    la $a0, msgInversa
    syscall

    li $t7, 0
    
print_inv_rows:
    bge $t7, $s0, fim
    li $t8, 0
    
print_inv_cols:
    bge $t8, $s0, next_inv_row
    add $t9, $s0, $t8
    mul $t0, $t7, $s0
    sll $t0, $t0, 1
    add $t0, $t0, $t9
    sll $t0, $t0, 2
    add $t5, $s1, $t0
    l.s $f12, 0($t5)
    li $v0, 2
    syscall
    li $v0, 4
    la $a0, espaco
    syscall
    addi $t8, $t8, 1
    j print_inv_cols
    
next_inv_row:
    li $v0, 4
    la $a0, newline
    syscall
    addi $t7, $t7, 1
    j print_inv_rows

errN:
    li $v0, 4
    la $a0, msgErrN
    syscall
    j fim

fim:
    li $v0, 10
    syscall
