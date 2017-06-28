	addi $t0, $zero, 200
	addi $t1, $t0, 300
	addi $t4, $zero, 0
	addi $t2, $zero, 2
	addi $t5, $zero, 0
loop:	beq $t2, $t5, end
	j function
return: addi $t5, $t5, 1
	add $t4, $t4, $t5
	j loop
function:
	add  $t3, $t0, $t1
	add  $t0, $t3, $zero
	j return
end:
	nop
