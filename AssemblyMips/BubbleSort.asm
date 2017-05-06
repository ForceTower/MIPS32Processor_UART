# Sort an ar	ray using the Bubble Sort Algorithm

#####Important Registers#####
# $t0: Hold the address of the last array item
# $t1: Flag to determine when the list is sorted (0: sorted, 1:unsorted)
# $t2: Array's I element (array[i])
# $t3: Arrays' I+1 element (array[i+1])
# $a0: Hold the array index (i)

# void bubbleSort(int arr[], int size) {
#      int swapped = 1;
#      int j = 0;
#      int tmp;
#      while (swapped == 1) {
#            swapped = 0;
#            j++;
#            int i;
#            for ( i = 0; i < size - j; i++) {
#                  if (arr[i] > arr[i + 1]) {
#                        tmp = arr[i];
#                        arr[i] = arr[i + 1];
#                        arr[i + 1] = tmp;
#                        swapped = 1;
#                  }
#            }
#      }
# }


.data
array: .word 5, 7, 6, 1, 2, 0, 3, 4, 9, 8

.text
main:	la		$t0, array     			# $t0 = Base array address
    	addi	$t0, $t0, 40    		# $t0 = Last array address (10 ints * 4 byter per int)
outerLoop:             					# Check if we're done (array was fully iterated)
   		add 	$t1, $zero, $zero  		# Set flag to sorted (the inner loop will check and change to unsorted if necessary)
   		la  	$a0, array      		# Set $a0 to the base address of the Array
innerLoop:                  			# Check if array is sorted and swap elements if needs to
    	lw  	$t2, 0($a0)         	# Sets $t2 to the current element in array
    	lw  	$t3, 4($a0)         	# Sets $t3 to the next element in array
    	slt 	$t4, $t2, $t3       	# $t4 = $t2 < $t3
    	beq 	$t4, $zero, continue   	# If $t4 = 1, then swap them (lines 41 and 42)
    	addi 	$t1, $zero, 1          	# Elemetes were swapped, not sure if array is sorted, set flag unsorted
    	sw  	$t2, 4($a0)         	# Store $t2 on $t3 position ($t2>$t3)
    	sw  	$t3, 0($a0)         	# Store $t3 on $t2 position ($t2>$t3)
continue:
    	addi 	$a0, $a0, 4            	# Jump to next array position (i++)
    	bne  	$a0, $t0, innerLoop    	# If $a0 != the end of Array, jump back to innerLoop
    	bne  	$t1, $zero, outerLoop  	# $t1 = 1 (array is unsorted), another pass is needed, jump back to outterLoop
exit:
		nop
