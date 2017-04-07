#			Fibonacci Sequence
#
#		Allen Hichard and João Paulo
#
#				Code in C
#
# int result = 0; 
#
# main() {
#	 int number = read_value_0;
#	 int counter = 0, i = 0;
#	 int values[15];
#	 
#	 do {
#		 counter++;
#		 result = 0;
#		 fibonacci(counter);
#		 values[i] = result;
#		 i++;
#	 } while (number > counter);
# }
#
# fibonacci(int number) {
#	 if (number <= 1)
#		 result = result + number;
#	 else {
#		 fibonacci(number - 2);
#		 fibonacci(number - 1);
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
	values: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 #Fibonacci Sequence will be stored here
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

#Here it is where the fibonacci sequence code starts
start:
	movia r8, values #pointer to the result vector
	movi r9, 0 #counter of current Fibonacci to be calculated
	pop r10 #recover from stack the quantity of numbers we should generate
while_fill_values: #while for filling numbers
	addi r9, r9, 1 #current_number++;
	push r9 #push the r9 into the stack because this function receives its parameters using the stack
	movi r2, 0 #resets the value of the global variable result
	call fibonacci #calls the function

	stw r2, 0(r8) #stores the result in the vector
	addi r8, r8, 4 #moves the vector to the next position
	bgt r10, r9, while_fill_values #if we didn't generate all the values, repeat
end_while_fill_values:
	br end #go to the end on file

fibonacci:
	pop r16 #receives the parameter

	cmplei r17, r16, 1 #checks if the value is lower or equals to 1
	beq r17, r0, else #if not go to else
	add r2, r2, r16 #if it is, add it's value to the result
	ret #returns to caller
else:
	push ra #push ra so we know where to go back
	subi r17, r16, 1 #sets up n-1
	push r17 #push n-1
	subi r17, r16, 2 #sets up n-2
	push r17 #push n-2
	call fibonacci #call fibonacci with n-2 as parameter
	call fibonacci #call fibonacci with n-1 as parameter
	pop ra #recover the ra 
	ret #return to caller (ra)

end:
