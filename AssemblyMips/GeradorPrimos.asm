.data
	myArray: .space 80 # = 250 inteiros * 4 bytes

.text
addi $t0, $zero, 100 #limite m�ximo do primeiro loop
move $t1, $zero #contador de divisores
addi $t2, $zero, 0 #numero (i do primeiro loop)
addi $t3, $zero, 1 #divisores (j do segundo loop)
addi $s0, $zero, 2


loop1:
move $t1, $zero #numero de divisores encontrados = 0
addi $t3, $zero, 1
loop2:
	div $t2, $t3 #divido o numero testado por um divisor (retirado o reg de resultado)
	mfhi $t5 #capturo o resto da divisao
	beq $t5, $zero, equal #se resto da divis�o for igual a zero, somo um ao contador de divisores
	continue: addi $t3, $t3, 1 #somo um ao contador do loop
	slt $t9, $t2, $t3
	beq $t9, $zero, loop2

#verificar se t1 == 2, se for, guardar $t2 somar 1 e continuar, se n�o for, somar um e continuar
beq $s0, $t1, guarda
verifica: addi $t2, $t2, 1 #adiciono um ao numero testado
bne $t2, $t0, loop1
beq $t2, $t0, exit


equal:
addi $t1, $t1, 1
j continue

guarda:
# Index $t7
sw $t2, myArray($t7)
addi $t7, $t7, 4
j verifica


exit: nop
