#			Prime Sequence Generator
#
#		Allen Hichard and João Paulo
#
#				Code in C
#
# 
# main() {
#	 int primes[15];
#	 int quantity = read_value_0;
#	 int numbers_found = 1;
#	 int current_number = 1;
#	 int divisor = 0;
#	 int i = 0;
#
# number_sequence_loop:
#	 while (numbers_found <= quantity) {
#		 current_number = current_number + 1;
#		 divisor = 2;
#		 while(divisor < current_number) {
#			if (current_number%divisor == 0)
#				goto number_sequence_loop;
#			
#			divisor = divisor + 1;
#		}
#		primes[i] = current_number;
#		i = i + 1;
#		numbers_found = numbers_found + 1;
#	 }
# }

.macro push reg #macro for inserting things into the stack
	subi sp, sp, 4
	stw	\reg, 0(sp)
.endm

.macro pop reg #macro for popping thing from the stack
	ldw \reg, 0(sp)
	addi sp, sp, 4
.endm

.data
	primes: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 #primes sequence
.equ serial, 0x860 #address of UART0

.global main

.text
main:

read_values:
	movia r8, serial #r8 as the UART0 pointer
	movi r9, 0 #r9 as the input acumulator
	movi r13, 1 #number of inputs to read

input_loop:
	#checking if there is anything on the input
	ldw r10, 8(r8)
	andi r10, r10, 0b10000000
	beq r10, r0, input_loop #there is no input

	#if the code gets to this point, there is a input
	ldw r10, 0(r8) #r10 contains the value of the input

if_enter:
	cmpeqi r11, r10, 0x0A #compares input with the ENTER key
	cmpeqi r12, r10, 0x20 #compares input with the SPACE key
	or r11, r11, r12
	beq r11, r0, end_if_enter #if it's not equal to ENTER/SPACE key, jump to the end of the if instruction
	br end_input_loop #if the input is the ENTER key, jumps to the end of the input loop
end_if_enter:

if_backspace: #backspace is 8 in Hex
	cmpeqi r11, r10, 0x8 #compares the input with the backspace key
	beq r11, r0, else_backspace #if it is not backspace
	movi r11, 10 #if it is a backspace, r11 represents the value 10
	div r9, r9, r11 #divides the acumulator by 10, that will "erase" the last digit
	br end_if_backspace #branches to the end of the if
else_backspace: #if it is not backspace
	subi r10, r10, 48 #subtracs 48...
	muli r9, r9, 10 #creates room for the new number
	add r9, r9, r10 #appends the new number
end_if_backspace:
	br input_loop #restarts for reading a new number

end_input_loop:
	push r9 #pushes the read number into the stack
	mov r9, r0 #resets the acumulator
	subi r13, r13, 1 #subtracs 1 from number of inputs left
	bne r13, r0, input_loop #if there are more numbers to input repeats, otherwise start program

#Here it is where the prime sequence code starts
start:
	pop r8 #The number of primes we need to generate
	movia r9, primes #vector pointer
	movi r10, 1 #current number
	movi r11, 1 #number of primes found

number_sequence_loop:
	bgt r11, r8, end #if already found all of the primes we need, go to end
	addi r10, r10, 1 #else, go to the next number
	movi r12, 2 #prepares the interative divisor number

prime_check_loop:
	bge r12, r11, found_prime #if the divisor is greater or equals to the current number, it means we didn't break the loop, so the current number is prime
	div r13, r10, r12 #if we are still searching, check if the current number divides the interative divisor
	mul r13, r13, r12
	beq r13, r10, number_sequence_loop #if it is divisible, we break the loop and select the next number
	addi r12, r12, 1 #if it doesn't divide, moves the interative divisor to the next number
	br prime_check_loop #check it again

found_prime: #if it's a prime number
	addi r11, r11, 1 #increase the number of prime numbers found
	stw r10, 0(r9) #stores the number into the vector
	addi r9, r9, 4 #moves the vector pointer to the next value
	br number_sequence_loop #try to find more primes

end: