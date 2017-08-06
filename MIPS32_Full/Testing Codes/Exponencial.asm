read:
    la     $s3,     256                 #Address of UART0

rloop:
    lw     $t2,     4($s3)              #Checks if the UART0 have received something
    beq    $t2,     $zero,  rloop       #If it didn't check again....
    lw     $t3,     0($s3)              #Place the read value in a register

main:
    li      $s0,    2                   #Loads 2 as base
    move    $s1,    $t3                 #Places the read value as exponent
    move    $t0,    $s0                 #Places the base in a temporary register
    li      $t1,    1                   #Creates a counter
calc:
    mul     $s0,    $t0,    $s0         #Multiply the exponent and save it into s0
    addi    $t1,    $t1,    1           #Increase the counter by 1
    bne     $s1,    $t1,    calc        #If the counter is not equal to the exponent, repeat

exit:
    sw      $s0,    8($s3)              #Writes the result int the UART0
