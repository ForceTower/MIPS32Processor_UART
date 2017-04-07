#			Factorial of a number
#
#		Allen Hichard and João Paulo
#
#				Code in C
#
# 
# main() {
#	 int number = read_value_0;
#	 int resp = factorial(number)
# }
#
# int factorial(int number) {
#	 if (number <= 0)
#		 return 1;
#
#	 return number * factorial(number - 1);
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

#Here it is where the exponetial code starts
start:
	pop r4 #r4 as number, that is going to be sent as parameter to the function factorial
	call factorial
	#r1 will contain the value
	br end

factorial:
if_less_equal_zero:
	bgt r4, r0,  else_less_equal_zero #This means: if (number > 0) go to the else label. if (number <= 0), execute the if code
	movi r1, 1 #places 1 into the return register
	ret #returns to the caller
else_less_equal_zero: #if number is greater than 0
	push ra #saves ra into the stack
	push r4 #saves number into the stack
	
	subi r4, r4, 1 #subtracts 1 from the number and sends it as a parameter for factorial
	call factorial #calls the procedure
	pop r4 #restore the state of the number
	pop ra #restores ra
	mul r1, r4, r1 #multiplies the parameter(number) with the return of the previous factorial call, and saves the result into the return register
	ret #returns to the callor

end:
