main:
  ADDI $a0, $zero, 7
  JAL fib
  J end

fib:
  ADDI $sp, $sp, -12
  sw $s0, 0($sp) #n
  sw $s1, 4($sp)
  sw $ra, 8($sp)
  slti $t0, $a0, 2
  beq $t0, $zero, else
  add $v0, $zero, $a0
  j exit

else:
  addi $s0, $a0, 0
  addi $a0, $a0, -1
  jal fib
  addi $s1, $v0, 0
  addi $a0, $s0, -2
  jal fib
  add $v0, $s1, $v0

exit:
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $ra, 8($sp)
  addi $sp, $sp, 12
  jr $ra
end: