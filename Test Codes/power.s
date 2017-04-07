# Exponentiation is a mathematical operation
#
#		Allen Hichard and João Paulo
#
#				Code in C
#
# int resultado = 1;
# 
# main() {
#	 int number = read_value_0;
#	 int power = read_value_1;
#
#    while (power > 0) {
#		 resultado = resultado * number;
#		 power = power - 1;
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
.equ serial, 0x860 #address of UART0

.global main

.text
main:

read_values:
	movia r8, serial #r8 as the UART0 pointer
	movi r9, 0 #r9 as the input acumulator
	movi r13, 2 #number of 

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

#Here it is where the exponatial code starts
start:
	pop r9 #recover the power
	pop r8 #recover the number
	movi r10, 1 #r10 as the result

pow:
	ble r9, r0, end #if power <= 0 ends the program
	mul r10, r10, r8 #otherwise calcs the power of the number, result = result * number
	subi r9, r9, 1 #power = power - 1
	br pow #repeats the power

end:
	



	
