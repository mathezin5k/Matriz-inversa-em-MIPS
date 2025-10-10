.data
	msgm1: .asciiz "Qual o tamanho da sua matriz? (2 ou 3): "
	msgm2: .asciiz "\nTamanho escolhido: "
	msgval: .asciiz "\nDigite o valor da posição "
	msgmat: .asciiz "\nA matriz digitada foi:\n"
	msgInversa: .asciiz "\nA matriz inversa foi:\n"
	msgErroDet: .asciiz "\n Essa matriz não tem uma inversa\n"
	espaco: .asciiz " "
	quebra: .asciiz "\n"
	matriz: 
		.align 2
		.space 36  
	
.text
main:
	# Pede tamanho da matriz
	li $v0, 4
	la $a0, msgm1
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0
	
	# Mostra tamanho escolhido
	li $v0, 4
	la $a0, msgm2
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	# Verifica se é 2 ou 3
	beq $t0, 2, matriz2x2
	beq $t0, 3, matriz3x3
	j fim

matriz2x2:
	move $t0, $zero
	move $t1, $zero
	li $t2, 16
	li $t5, 4
	li $t6 3
	
loop2x2:
    	beq $t0, $t2, sairLoop2x2

    	li $v0, 4
    	la $a0, msgval
    	syscall

    	li $t5, 4
    	div $t0, $t5
    	mflo $t1                

    	li $v0, 1
    	move $a0, $t1
    	syscall

    	li $v0, 5
    	syscall
    	sw $v0, matriz($t0)

    	addi $t0, $t0, 4       
    	j loop2x2

sairLoop2x2:
	
	li $v0, 4
    	la $a0, msgmat
    	syscall

    	la $t1, matriz       
    	li $t2, 0            

print2x2:
    	beq $t2, 16, calcInversa2x2

    	lw $a0, 0($t1)
    	li $v0, 1
    	syscall              

    	li $v0, 4
    	la $a0, espaco
    	syscall

    	addi $t2, $t2, 4   
    	addi $t1, $t1, 4

   	rem $t3, $t2, 8 		# resto da divisão em $t3
    	bne $t3, $zero, continuar2x2	# pula linha

    	li $v0, 4
    	la $a0, quebra
    	syscall

continuar2x2:
    	j print2x2

calcInversa2x2:

    	la $t0, matriz       
    	# Carregar inteiros e converter para float
    	lw $t1, 0($t0)       
   	mtc1 $t1, $f1
    	cvt.s.w $f1, $f1      

    	lw $t2, 4($t0)    
    	mtc1 $t2, $f2
    	cvt.s.w $f2, $f2        

    	lw $t3, 8($t0)   
    	mtc1 $t3, $f3
    	cvt.s.w $f3, $f3     

    	lw $t4, 12($t0)  
    	mtc1 $t4, $f4
    	cvt.s.w $f4, $f4
    	
    	# Calcula o det
    	mul.s $f5, $f1, $f4 
    	mul.s $f6, $f2, $f3
    	sub.s $f7, $f5, $f6
    	mfc1 $t5, $f7
    	beq  $t5, $zero, erroDet
    	
    	
    	# Divide det por cada elemento da matriz
    	div.s $f1, $f1, $f7
    	div.s $f2, $f2, $f7
    	div.s $f3, $f3, $f7
    	div.s $f4, $f4, $f7
    	
    	# Troca a diagonal principal
    	mov.s $f8, $f1
    	mov.s $f1, $f4
    	mov.s $f4, $f8
    	
    	# Trocar sinal 
    	neg.s $f2, $f2
    	neg.s $f3, $f3

printInversa2x2:
	li $v0, 4
	la $a0, msgInversa
	syscall

	li $v0, 2           
	mov.s $f12, $f1
	syscall

	li $v0, 4
	la $a0, espaco
	syscall

	li $v0, 2
	mov.s $f12, $f2
	syscall

	li $v0, 4
	la $a0, quebra
	syscall

	li $v0, 2
	mov.s $f12, $f3
	syscall

	li $v0, 4
	la $a0, espaco
	syscall

	li $v0, 2
	mov.s $f12, $f4
	syscall

	li $v0, 4
	la $a0, quebra
	syscall
	
	j fim
	
matriz3x3:
	move $t0, $zero
	move $t1, $zero
	li $t2, 36
	li $t5, 4
	li $t6 3
	
loop3x3:
    	beq $t0, $t2, sairLoop3x3

    	li $v0, 4
    	la $a0, msgval
    	syscall

    	li $t5, 4
    	div $t0, $t5
    	mflo $t1                

    	li $v0, 1
    	move $a0, $t1
    	syscall

    	li $v0, 5
    	syscall
    	sw $v0, matriz($t0)

    	addi $t0, $t0, 4       
    	j loop3x3
    	
sairLoop3x3:
	li $v0, 4
    	la $a0, msgmat
    	syscall

    	la $t1, matriz       
    	li $t2, 0  
    	
print3x3:
    	beq $t2, 36, calcInversa3x3

    	lw $a0, 0($t1)
    	li $v0, 1
    	syscall              

    	li $v0, 4
    	la $a0, espaco
    	syscall

    	addi $t2, $t2, 4   
    	addi $t1, $t1, 4

   	rem $t3, $t2, 12		# resto da divisão em $t3
    	bne $t3, $zero, continuar3x3	# pula linha
    	
    	li $v0, 4
    	la $a0, quebra
    	syscall
    	
continuar3x3:
	j print3x3

calcInversa3x3:
	la $t0, matriz       
	
    	# Carregar inteiros e converter para float
    	lw $t1, 0($t0)       
   	mtc1 $t1, $f1
    	cvt.s.w $f1, $f1      

    	lw $t1, 4($t0)       
   	mtc1 $t1, $f2
    	cvt.s.w $f2, $f2
	
	lw $t1, 8($t0)       
   	mtc1 $t1, $f3
    	cvt.s.w $f3, $f3 
    	
    	lw $t1, 12($t0)       
   	mtc1 $t1, $f4
    	cvt.s.w $f4, $f4 
    	
    	lw $t1, 16($t0)       
   	mtc1 $t1, $f5
    	cvt.s.w $f5, $f5 
    	
    	lw $t1, 20($t0)       
   	mtc1 $t1, $f6
    	cvt.s.w $f6, $f6 
    	
    	lw $t1, 24($t0)       
   	mtc1 $t1, $f7
    	cvt.s.w $f7, $f7 
    	
    	lw $t1, 28($t0)       
   	mtc1 $t1, $f8
    	cvt.s.w $f8, $f8
    	
    	lw $t1, 32($t0)       
   	mtc1 $t1, $f9
    	cvt.s.w $f9, $f9
    	      
	# Diagonal principal
    	mul.s $f10, $f1, $f5
    	mul.s $f10, $f10, $f9
    	mul.s $f11, $f2, $f6
    	mul.s $f11, $f11, $f7
    	mul.s $f12, $f3, $f4
    	mul.s $f12, $f12, $f8
    	add.s $f10, $f10, $f11
    	add.s $f10, $f10, $f12
    	
    	# Diagonal secundaria 
    	mul.s $f13, $f3, $f5
    	mul.s $f13, $f13, $f7
    	mul.s $f14, $f1, $f6
    	mul.s $f14, $f14, $f8
    	mul.s $f15, $f2, $f4
    	mul.s $f15, $f15, $f9
    	add.s $f13, $f13, $f14
    	add.s $f13, $f13, $f15
    	
    	# Calcula o det
    	sub.s $f10, $f10, $f13
    	mfc1 $t2, $f10
    	beq  $t2, $zero, erroDet
    	
    	# Divide det por cada elemento da matriz
    	div.s $f1, $f1, $f10
    	div.s $f2, $f2, $f10
    	div.s $f3, $f3, $f10
    	div.s $f4, $f4, $f10
    	div.s $f5, $f5, $f10
    	div.s $f6, $f6, $f10
    	div.s $f7, $f7, $f10
    	div.s $f8, $f8, $f10
    	div.s $f9, $f9, $f10
    	
    	# Calcula a matriz adjunta
    	mul.s $f10, $f5, $f9
    	mul.s $f11, $f6, $f8
    	sub.s $f10, $f10, $f11
    	
    	mul.s $f11, $f8, $f3
    	mul.s $f12, $f9, $f2
    	sub.s $f11, $f11, $f12
    	
    	mul.s $f12, $f2, $f6
    	mul.s $f13, $f3, $f5
    	sub.s $f13, $f13, $f12
    	
    	mul.s $f14, $f6, $f7
    	mul.s $f15, $f4, $f9
    	sub.s $f14, $f14, $f15
    	
    	mul.s $f15, $f9, $f1
    	mul.s $f16, $f7, $f3
    	sub.s $f15, $f15, $f16
    	
    	mul.s $f16, $f3, $f4
    	mul.s $f17, $f1, $f6
    	sub.s $f16, $f16, $f17
    	
    	mul.s $f17, $f4, $f8
    	mul.s $f18, $f5, $f7
    	sub.s $f17, $f17, $f18
    	
    	mul.s $f18, $f7, $f2
    	mul.s $f19, $f8, $f1
    	sub.s $f18, $f18, $f19
    	
    	mul.s $f19, $f1, $f5
    	mul.s $f20, $f2, $f4
    	sub.s $f19, $f19, $f20
    	
printInversa3x3:	
	li $v0, 4
	la $a0, msgInversa
	syscall

	li $v0, 2           
	mov.s $f12, $f10
	syscall

	li $v0, 4
	la $a0, espaco
	syscall

	li $v0, 2
	mov.s $f12, $f11
	syscall

	li $v0, 4
	la $a0, espaco
	syscall

	li $v0, 2
	mov.s $f12, $f13
	syscall

	li $v0, 4
	la $a0, quebra
	syscall

	li $v0, 2
	mov.s $f12, $f14
	syscall
	
	li $v0, 4
	la $a0, espaco
	syscall
	
	li $v0, 2           
	mov.s $f12, $f15
	syscall

	li $v0, 4
	la $a0, espaco
	syscall

	li $v0, 2
	mov.s $f12, $f16
	syscall

	li $v0, 4
	la $a0, quebra
	syscall

	li $v0, 2
	mov.s $f12, $f17
	syscall

	li $v0, 4
	la $a0, espaco
	syscall

	li $v0, 2
	mov.s $f12, $f18
	syscall
	
	li $v0, 4
	la $a0, espaco
	syscall
	
	li $v0, 2
	mov.s $f12, $f19
	syscall
	
	j fim
erroDet:
	li $v0, 4
	la $a0, msgErroDet
	syscall
	
	j fim
fim:
	li $v0, 10
	syscall
