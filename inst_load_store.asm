	addi 	$t0, $zero, 100 #100
	sw	$t0, 0($zero)		#salva 100
	add	$t0, $t0, $t0		#200
	add	$t0, $t0, $t0		#400
	sw	$t0, 4($zero)		#salva 400
	lw	$t0, 0($zero)		#carrega 100
	addi	$t2, $t0, 0		#t2 = 100
	lw 	$t1, 4($zero)		#t1 = 400
	sub	$t3, $t1, $t2		#t3 = 300
	sw	$t3, 0($zero)		#salva 300
	lw	$t5, 0($zero)		#carrega 300
	addi	$t5, $t5, 700	#t5 = 1000
	
	