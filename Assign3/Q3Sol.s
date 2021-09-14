####################################
####        Assgn 03            ####
####       Question 03          ####
#  Autumn Semester-Session 2021-22 #
####        Group 22            ####
##  19CS10031 - Abhishek Gandhi   ##
##  19CS10051 - Sajal Chhamunya   ##
####################################


####################### Data segment ######################################
 .data
input_msg: 
    .asciiz "Enter four positive integers m, n, a and r: \n"
matrixA:
    .asciiz "This is the required mxn matrix:"
matrixB:
    .asciiz "\n\nThis is the transpose of the first matrix:"
newline:        
    .asciiz "\n"
space:  
    .asciiz "\t"

READ_INT_CODE:       .word 5
PRINT_INT_CODE:      .word 1
PRINT_STRING_CODE:   .word 4
EXIT_CODE:           .word 10
####################### Data segment ######################################

####################### Text segment ######################################
.text
.globl main

main:
    jal initStack                           #Initialising the stack and the frame pointer
    
    la $a0, input_msg                       #printing the First statement, ie. Enter the numbers
    lw $v0, PRINT_STRING_CODE
    syscall


    lw $v0, READ_INT_CODE                   #reading and saving m
    syscall
    move $a0, $v0
    jal pushToStack

    lw $v0, READ_INT_CODE                   #reading and saving n
    syscall
    move $a0, $v0
    jal pushToStack

    lw $v0, READ_INT_CODE                   #reading and saving a
    syscall
    move $a0, $v0
    jal pushToStack

    lw $v0, READ_INT_CODE                   #reading and saving r
    syscall
    move $a0, $v0
    jal pushToStack

    lw $t0, -4($fp)                         #m
    lw $t1, -8($fp)                         #n
    mult $t0, $t1                           #multiplying m and n
    mflo $a0                                #taking the lower significant half 
                                            #as if the upper half is filled then the matrix numbers would overflow
    jal mallocInStack                       #Allocating space for the first matrix A    

    move $s0, $v0                           #saving address for matrix A in $s0

    lw $a0, -12($fp)                        #a
    lw $a1, -16($fp)                        #r
    move $a2, $s0                           #moving the required values in the a registers for the arguements for fillMatrix

    jal fillMatrix                          #Populates the matrix with the instructed values

    la $a0, matrixA                         #Prints the introduction to the first matrix
    lw $v0, PRINT_STRING_CODE
    syscall

    lw $a0, -4($fp)                         #m
    lw $a1, -8($fp)                         #n
    move $a2, $s0                           #moving the required values in the a registers for the arguements for printMatrix

    jal printMatrix                         #Calling printMatrix

    lw $t0, -4($fp)                         #m
    lw $t1, -8($fp)                         #n
    mult $t0, $t1                           #multiplying m and n to get the total space
    mflo $a0
    jal mallocInStack                       #Allocating space for the transposed matrix B

    move $s1, $v0                           #address for matrix B

    la $a0, matrixB                         #prints the introduction to matrix B
    lw $v0, PRINT_STRING_CODE
    syscall

    lw $a0, -4($fp)                         #m
    lw $a1, -8($fp)                         #n
    move $a2, $s0                           #address of matrix A
    move $a3, $s1                           #address of matrix B

    jal transposeMatrix                     #populates the matrix B as the transpose of the matrix A

    lw $a0, -8($fp)                         #n
    lw $a1, -4($fp)                         #m
    move $a2, $s1                           #moving the required values in the a registers for the arguements for printMatrix

    jal printMatrix                         #Calling printMatrix

    move $sp, $fp                           #Emptying the stack
    lw $fp, 0($sp)                          #Reallocating the previous address of the frame pointer, if used by other functions
    addi $sp, $sp, 4                        #Emptying the space used by the previous content of fp

    li $v0, 10                              # terminate the program
    syscall



initStack:                                  #Initialises the stacck and the frame pointer
    addi $sp, $sp, -4                       #makes space in the stack to store the content of frame pointer
    sw $fp, 0($sp)                          #saves the content of fp
    move $fp, $sp                           #makes fp the frame pointer for this particular function
    jr $ra                                  #return to main

pushToStack:                                #To allocate space to a variable in the stack
    addi $sp, $sp, -4                       #making space in the stack
    sw $a0, 0($sp)                          #saving in the space made
    jr $ra                                  #return to main

mallocInStack:                              #Allocating space for a matrix
    addi $v0, $sp, -4                       #storing the first element's address in $v0 to be returned
    sll $a0, $a0, 2                         #multiplying the total size by 4
    sub $sp, $sp, $a0                       #making space for the matrix
    jr $ra                                  #return to main

fillMatrix:                                 #populates the matrix with the required values, parameters => a0(a), a1(r), a2(address)
    sw $a0, 0($a2)                          #saving the first number a
    addi $a2, $a2, -4                       #going to the space for the second element

    j loop1                                 #entering an loop

    loop1:                              
        mult $a0, $a1                       #multiplying the previous entered element with r
        mflo $a0                            
        sw $a0, 0($a2)                      #saving it to the corresponding space
        addi $a2, $a2, -4                   #moving to the next address

        blt $a2, $sp, exit_fill             #If the address exceeds the allocated memory, exit the loop
        j loop1
    
    exit_fill:                              #returns to main
        jr $ra


printMatrix:                                #prints a mxn matrix, parameters => a0(m), a1(n), a2(address)
    li $t0, 0                               #initialising the iterator for the first loop (i)
    li $t1, 0                               #initialising the iterator for the nested loop (j)
    move $t2, $a0                           #moving m in a different register as a0 will be used for printing
    j print_loop1                           #initialising the loop

    print_loop2:                            #Nested loop
        lw $a0, 0($a2)                      #loads the value to be printed
        lw $v0, PRINT_INT_CODE
        syscall
        la $a0, space                       #prints space to distinguish two values
        lw $v0, PRINT_STRING_CODE
        syscall
        addi $a2, $a2, -4                   #Moves to the next space
        addi $t1, $t1, 1                    #j++
        bne $t1, $a1, print_loop2           #checks for j<n

    print_loop1:
        beq $t0, $t2, exit_print             #check for i!=m
        addi $t0, $t0, 1                    #i++
        li $t1, 0                           #j=0, for the next iteration of i
        la $a0, newline                     #printing "\n"
        lw $v0, PRINT_STRING_CODE
        syscall
        j print_loop2                       #calling for the nested loop
    
    exit_print:
        jr $ra
    
transposeMatrix:
    move $t0, $a2                           #address of the first matrix
    li $t1, 0                               #iterator for the first loop, i
    li $t2, 0                               #iterator for the second loop, j
    move $t3, $a1                           #n, which needs to be subtracted to travel column wise in the matrix
    sll $t3, $t3, 2                         #multiplying n with 4 and storing it in $t3
    move $t4, $a3                           #address of the second matrix
    addi $a2, $a2, 4
    j tran_loop1                            #initialising the first loop

    tran_loop2:                             #Nested loop
        lw $t5, 0($t0)                      #loads the value of the element from matrix A
        sw $t5, 0($t4)                      #Saves the above value in the correct position of matrix B
        addi $t4, $t4, -4                   #moving to the next address in the matrix B
        sub $t0, $t0, $t3                   #moving to the next element in matrix A, in a particular column
        addi $t2, $t2, 1                    #j++
        bne $t2, $a0, tran_loop2            #checks for j!=m

    tran_loop1:
        beq $t1, $a1, exit_tran             #checks for i==n, if true exits
        addi $t1, $t1, 1                    #i++
        addi $a2,$a2,-4                     #moves to the address of the nest column of matrix A
        move $t0, $a2 
        li $t2, 0                           #j=0, for the next iteration of i
        j tran_loop2                        #calling for the nested loop

    exit_tran:
        jr $ra

    