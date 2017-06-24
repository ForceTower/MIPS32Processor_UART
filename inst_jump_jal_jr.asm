	addi $t0, $zero, 50
	j kappa
	addi $t5, $zero, 30
	addi $t5, $zero, 30
	addi $t5, $zero, 30
	addi $t5, $zero, 30
keepo:
	addi $t1, $zero, 2
	mul  $t0, $t0, $t1 #t0 vira 200
	jr $ra
	addi $t5, $zero, 30
	addi $t5, $zero, 30
	addi $t5, $zero, 30
	addi $t5, $zero, 30
kappa:	addi $t0, $t0, 50  #esperado 100
	jal keepo
	add $t0, $t0, $t0 #t0 vira 400
	add $t0, $t0, $t0 #t0 vira 800
	add $t0, $t0, $t0 #t0 vira 1600
	add $t0, $t0, $t0 #t0 vira 3200
	
