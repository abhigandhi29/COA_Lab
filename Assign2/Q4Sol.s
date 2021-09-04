/*
    Group 2
    19CS10031 - Abhishek Gandhi
    19CS10051 - Sajal Chammuniya
*/

.data

input_msg:          .asciiz "Enter a positive Integer: "
error_msg:          .asciiz "Invalid input, input must be a positive integer"
output_msg_t:       .asciiz "Entered number is a perfect number. "
output_msg_f:       .asciiz "Entered number is not a perfect number. "
newline:            .asciiz "\n"

READ_INT_CODE:       .word 5
PRINT_INT_CODE:      .word 1
PRINT_STRING_CODE:   .word 4
EXIT_CODE:           .word 10

.text
.globl main

main: 
    # reading number of n
    la $a0, input_msg
    lw $v0, PRINT_STRING_CODE
    syscall
    lw $v0, READ_INT_CODE
    syscall
    move $s0, $v0
    
    # imput must be >0 otherwise invlid
    blt $s0, 1, invalid_

    li $t0, 2 # for loop counter variable (i=2)
    li $s1, 1 # sum is stored in $s1

for_loop:
    mul $t1, $t0, $t0   # $t1 = i*i, we need to run the loop till sqrt(n)
    bgt $t1, $s0, end_loop   # if(i*i>n) break;   go to end_loop

    div $s0, $t0   # dividing n by i, n/i
    mfhi $t3    # high contains remainder, moving remainder to t3
    mflo $t2    # low contains quotient, moving quotient to t2 
    
    bne $t3 $0 N1    # If remainder is not zero, jump to N1, no need to add anything 
    add $s1, $s1, $t0
    beq $t2, $t0, N1   # if n/t = t, no need to add twice, hence jump
    add $s1, $s1, $t2
    
    N1: # jump point incase no need to add
        addi $t0, $t0, 1     # i++;
    j for_loop              # go to the top of the loop;

end_loop:
    bne $s0, $s1 end_false   # if sum is not equal to number(n), go to end_false


end_true:    # input number is a perfect number
    la $a0, output_msg_t
    lw $v0, PRINT_STRING_CODE
    syscall
    j exit_

end_false:     # input number is not a perfect number
    la $a0, output_msg_f
    lw $v0, PRINT_STRING_CODE
    syscall
    j exit_

invalid_:       # invalid input, input number is less than or equal to the 0
    la $a0, error_msg
    lw $v0, PRINT_STRING_CODE
    syscall
    j exit_

exit_:        # print newline in the exit and exit using exit syscall
    la $a0, newline
    lw $v0, PRINT_STRING_CODE
    syscall
    lw $v0, EXIT_CODE
    syscall
