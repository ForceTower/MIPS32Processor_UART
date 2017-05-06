# Calculates the N number of Fibonacci Sequence

# $a0 = Fibonacci Number (N)

# int fib(int n): return n < 2 ? n : fib(n-1) + fib(n-2)

main:	li  $a0, 7				# N = 10
	jal 	fib
	j	exit

fib:	addi	$sp, $sp, -8		# Space for two words
	sw	$ra, 4($sp)		# Store $ra on the stack
	move 	$v0, $a0		# Here, the return value is N($a0)
	slti	$t0, $a0, 2
	bne	$t0, $zero, fibrt	# Goes to return if N < 2
	sw	$a0, 0($sp)		# Save a copy of N
	addi	$a0, $a0, -1		# N-1
	jal	fib			# fib(N-1)
	# When this line is reached, fib(N-1) is stored in $v0
	lw	$a0, 0($sp)
	sw	$v0, 0($sp)		# Store fib(N-1) on the stack
	addi	$a0, $a0, -2		# N-2
	jal 	fib			# fib(N-2)
	# When this line is reached, fib(N-2) is stored in $v0
	lw	$v1, 0($sp)		# Load fib(N-1)
	add	$v0, $v0, $v1		# fib(N-1)+fib(N-2)
fibrt:	lw 	$ra, 4($sp)		# Restore $ra
	addi	$sp, $sp, 8		# Restore $sp
	jr	$ra			# Go back to caller
	
exit:	nop
