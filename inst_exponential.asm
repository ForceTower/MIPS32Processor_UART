# Calcular o exponencial a^b

# $s0 - Base
# $s1 - Exponent
# $t0 - Base backup
# $t1 - Counter

main:
	li $s0, 2     		# Loads 4 as base
	li $s1, 10    		# Loads 10 as exponent		
	move $t0, $s0  		# Copy the base value to $t0
	li $t1, 1     		# Initialize the couter $t1

loop: 	mul  $s0, $t0, $s0	# Multiplies current value ($s0) by the base ($t0)
	addi $t1, $t1, 1	# Increment the counter
	bne  $s1, $t1, loop	# Goes back to loop if the counter != exponent

exit:	nop

#s0 stores the final result
