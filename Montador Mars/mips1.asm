addi $s1 , $zero , 50
and  $s3 , $zero, $s1 #this is a comment :p
addi $s4 , $zero, 50
or   $t1 , $zero , $s3 
nor  $t2 , $t1 , $s3 
addi $t3 , $zero , 300 
beq  $s4 , $s1 , label
addi $t4 , $zero , 400 
addi $t5 , $t4 , 500 
sub  $t6 , $zero , $t1 
addi $t8 , $zero , 800 
sw   $t7 , 50($s1)
lw   $t1 , 50($s1)
add  $s7 , $t1, $t5
sub  $k0 , $s7, $t1

label: