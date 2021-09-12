####################################
####        Assgn 03            ####
####       Question 02          ####
#  Autumn Semester-Session 2021-22 #
####        Group 22            ####
##  19CS10031 - Abhishek Gandhi   ##
##  19CS10051 - Sajal Chhamunya   ##
####################################


####################### Data segment ######################################
 .data
array_msg: 
    .asciiz "Input elements of the array: \n"
num_msg:  
    .asciiz "\nEnter Requred Kth Largest Number:  "
sort_msg: 
    .asciiz "Sorted Array: "
output_msg: 
    .asciiz "Kth Largest Number is: "
error_msg: 
    .asciiz "Error!! Invalid k value, 0< k <=n \n"
newline:        
    .asciiz "\n"
space:  
    .asciiz " "
array: 
    .word 0 : 10

READ_INT_CODE:       .word 5
PRINT_INT_CODE:      .word 1
PRINT_STRING_CODE:   .word 4
EXIT_CODE:           .word 10
####################### Data segment ######################################

####################### Text segment ######################################
.text
.globl main

main:

    li $t0, 10

    # Reading all elements of the array
    la $a0, array_msg
    lw $v0, PRINT_STRING_CODE
    syscall

    la $t1, array
    li $t2, 0

    input_loop:
        # Reading the elements in a sequence

        lw $v0, READ_INT_CODE
        syscall
        sw $v0, 0($t1)

        addi $t1, $t1, 4
        addi $t2, $t2, 1
        bne $t2, $t0, input_loop


    la $t1, array   
    move $a0, $t0 
    move $a1, $t1     # setting the parameters 

    jal Sort_array    # procedural call to Sort_array 

    la $t1, array    # initialising variables for printing sorted array
    li $t0, 10
    li $t2, 0
    
    la $a0, sort_msg 
    lw $v0, PRINT_STRING_CODE
    syscall          # printing sort msg

    print_loop:      # printing elements after sorting in dpace swprated format
        lw $v0, PRINT_INT_CODE
        lw $a0, 0($t1)
        syscall

        la $a0, space
        lw $v0, PRINT_STRING_CODE
        syscall

        addi $t1, $t1, 4     # incrementing location to move to next location
        addi $t2, $t2, 1
        bne $t2, $t0, print_loop  

    la $a0, newline
    lw $v0, PRINT_STRING_CODE
    syscall
    li $a0, 10
    la $a1, array
    jal find_k_largest        # procedural call to find_k_largest
    
    li $v0, 10                # terminate the program
    syscall



Sort_array:     # a0 contains size of array and a1 contains array location

    move $s0  $a0
    move $s1, $a1

    li $t1, 4  # represent j
    # Loop to start sorting the elements
    loop:
        add $t0, $s1, $t1              # location of a[j] in t0    
        lw $t2, 0($t0)                 # a[j] in t2, initialising temp in t2
        addi $t3, $t1, -4              # initialising i in t3
        while_loop:
            blt $t3, $0, update        # if i<0 exit, jump to update
            add $t0, $s1, $t3          # location of a[i] in t0         
            lw $t5, 0($t0)             # a[i] in t5
            ble $t5, $t2, update       # a[i] <= temp, jump to update 
            addi $t6, $t3, 4           # i+1 in t6               
            add $t0, $s1, $t6          # location of a[i+1] in t0 
            sw $t5, 0($t0)             # storing a[i] in a[i+1]
            add $t0, $s1, $t3          # location of a[i] in t0 
            sw $t2, 0($t0)             # storing temp in a[i]
            addi $t3, $t3, -4          # reducing i by 1, i = i-1
            j while_loop               # while loop continues

        update:
            addi $t1, $t1, 4           # adding 1 in j, j = j+1
            sll $t4, $s0, 2            
            beq $t4, $t1, exit         # if j==n break; jump to exit
            j loop
    exit:
        jr $ra                         # return to call location


find_k_largest:                        # a0 contains size of array and a1 contains array location

    move $s0, $a0                 
    move $s1, $a1


    lw $v0, PRINT_STRING_CODE
    la $a0, num_msg
    syscall

    lw $v0, READ_INT_CODE       # read k
    syscall

    move $t0, $v0               # storing k in t0
    bgt $t0, $s0, error         # if k>n break;
    ble $t0, $0, error          # if k<=0 break;

    sub $t0, $s0, $t0           # k = n-k, because our array is in increasing order
    sll $t0, $t0, 2           
    add $t1, $s1, $t0          # goto location of kth element
    
    la $a0, output_msg         # printing output message
    lw $v0, PRINT_STRING_CODE
    syscall
    
    lw $a0, 0($t1)             # printing kth largest element
    lw $v0, PRINT_INT_CODE
    syscall
    
    la $a0, newline            # printing newline
    lw $v0, PRINT_STRING_CODE
    syscall
    
    j exit_k

    error:
        la $a0, error_msg
        lw $v0, PRINT_STRING_CODE
        syscall

    exit_k:
        jr $ra 