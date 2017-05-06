# Calculates the factorial of a N integer number

#####Important Registers#####
#$s0: Number (N)
#$s1: Result

main: 	        li 	$s0, 6					# Loads N = 6
		move 	$a0, $s0				# Sets N as parameter
		jal 	factorial				# factorial (N)
		move 	$s1, $v0				# Copy the result to $s1
		j 	exit

factorial:
		subi 	$sp, $sp, 8 			# Allocate space for two words
		sw 	$ra, 4($sp) 			# Save $ra
		sw 	$a0, 0($sp) 			# Save $a0
		slti 	$t0, $a0, 2 			# $t0 = $a0 < 2
		beq 	$t0, $zero, secondPart  # if a > 2, goes to secondPart
		move 	$v0, $a0
		jr 	$ra

secondPart:
		addi 	$a0, $a0, -1
		addi 	$s6, $s6, 1
		jal 	factorial
		lw 	$ra, 4($sp)
		lw 	$t1, 0($sp)
		mul 	$v0, $v0, $t1
		addi 	$sp, $sp, 8
		jr 	$ra

exit:
		nop
