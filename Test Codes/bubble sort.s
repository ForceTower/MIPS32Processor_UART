#			Bubble Sort Algorithm
#
#		Allen Hichard and João Paulo
#
#				Code in C
#
# 
# main() {
#	 int vector[10] = read_vector
#	 int i = 0; j = 0;
#
#	 while (i < 10) {
#		 while (j < 10) {
#			 if(vector[j] > vector[i]) {
#				 int temp = vector[j];
#				 vector[j] = vector[i];
#				 vector[i] = temp;
#			 }
#			 j++;
#		 }
#		 i++
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
	vector: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 #vector values
.equ serial, 0x860 #address of UART0

.global main

.text
main:

read_values:
	movia r8, serial #r8 as the UART0 pointer
	movi r9, 0 #r9 as the input acumulator
	movi r13, 10 #number of inputs to read
	movia r14, vector #pointer to the vector

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
	stw r9, 0(r14) #stores the value read into the vector
	addi r14, r14, 4 #goes to the next position
	mov r9, r0 #resets the acumulator
	subi r13, r13, 1 #subtracs 1 from number of inputs left
	bne r13, r0, input_loop #if there are more numbers to input repeats, otherwise start program

#Here it is where the exponetial code starts
start:
	movia r8, vector #r8 will point to the vector last position of the vector
	addi r8, r8, 40

	movia r9, vector #r9 will start pointing to the first element to the vector
while_i:
	movia r10, vector #r10 will also be a pointer to the vector
while_j:
	ldw r11, 0(r10) #gets the number on the i(th) position of the vector
	ldw r12, 0(r9) #gets the number on the j(th) position of the vector
	
if_comp: 
	cmplt r13, r11, r12 #compares thhe values to know who is the greater
	bne r13, r0, end_if_comp #if the i(th) is not greater than the j(th), no need to swap
	stw r11, 0(r9) #but we swap if the i(th) is greater than the j(th)
	stw r12, 0(r10)
end_if_comp:
	addi r10, r10, 4 #moves the j pointer to the next position
	bne r10, r8, while_j #if j does not point to the last element, repeat the while_j
end_while_j:
	addi r9, r9, 4 #moves the i pointer to the next element
	bne r9, r8, while_i #if i is not in the last position, repeat the while_i
end_while_i:
