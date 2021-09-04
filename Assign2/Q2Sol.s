.data

# output strings
input_msg_1:    .asciiz "Enter the first positive integer: "
input_msg_2:    .asciiz "Enter the second positive integer: "
output_msg:     .asciiz "GCD of the two integers is: "
error_msg:      .asciiz "Invalid Input"
newline:        .asciiz "\n"

READ_INT_CODE:       .word 5
PRINT_INT_CODE:      .word 1
PRINT_STRING_CODE:   .word 4
EXIT_CODE:           .word 10

.text
.globl main

main:
    # Reading first no. n1
    la $a0, input_msg_1
    lw $v0, PRINT_STRING_CODE
    syscall
    lw $v0, READ_INT_CODE
    syscall
    move $s0, $v0

    # Reading second no. n2
    la $a0, input_msg_2
    lw $v0, PRINT_STRING_CODE
    syscall
    lw $v0, READ_INT_CODE
    syscall
    move $s1, $v0

    # invalid inputs
    blt $s0, 1, invalid_
    blt $s1, 1, invalid_

    bne $s0, $0, while_loop
    move $s0, $s1
    j end_loop
    # while(n1 != n2)
while_loop:
    beq $s1, $0, end_loop 
    bgt $s0, $s1, N1 # if(n1 > n2)

    sub $s1, $s1, $s0 # n3 = n2-n1
    j while_loop # loop continues
    
N1: 
    sub $s0, $s0, $s1   # n1 = n1-n2
    # loop continues
    j while_loop
    
    
end_loop: # loop ends
    # Print results
    la $a0, output_msg
    lw $v0, PRINT_STRING_CODE
    syscall
    move $a0, $s0
    lw $v0, PRINT_INT_CODE
    syscall
    j exit_

invalid_:
    # Print error statement
    la $a0, error_msg
    lw $v0, PRINT_STRING_CODE
    syscall
    j exit_
exit_:
    # Exit
    la $a0, newline
    lw $v0, PRINT_STRING_CODE
    syscall
    lw $v0, EXIT_CODE
    syscall