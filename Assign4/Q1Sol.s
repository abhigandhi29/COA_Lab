####################################
####        Assgn 04            ####
####       Question 01          ####
#  Autumn Semester-Session 2021-22 #
####        Group 22            ####
##  19CS10031 - Abhishek Gandhi   ##
##  19CS10051 - Sajal Chhamunya   ##
####################################


####################### Data segment ######################################
 .data
input_msg: 
    .asciiz "Enter four positive integers n, a, r and m: \n"
matrixA:
    .asciiz "This is the required nxn matrix:"
det:
    .asciiz "\n\nThis is the determinant value of the matrix:\t"
newline:        
    .asciiz "\n"
space:  
    .asciiz " "

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

    lw $v0, READ_INT_CODE                   #reading and saving m
    syscall
    move $a0, $v0
    jal pushToStack

    lw $t0, -8($fp)                         #taking and saving a=a%m for simplicity afterwards
    lw $t1, -16($fp)
    div $t0, $t1
    mfhi $t0
    sw  $t0, -8($fp)

    lw $t0, -12($fp)                         #taking and saving r=r%m for simplicity afterwards
    lw $t1, -16($fp)
    div $t0, $t1
    mfhi $t0
    sw  $t0, -12($fp)


    lw $t0, -4($fp)                         #n
    mult $t0, $t0                           #taking nxn
    mflo $a0                                #taking the lower significant half 
                                            #as if the upper half is filled then the matrix numbers would overflow
    jal mallocInStack                       #Allocating space for the first matrix A    

    move $s0, $v0                           #saving address for the matrix in $s0

    lw $a0, -8($fp)                         #a
    lw $a1, -12($fp)                        #r
    lw $a2, -16($fp)                        #m
    move $a3, $s0                           #moving the required values in the a registers for the arguments for fillMatrix

    jal fillMatrix                          #Populates the matrix with the instructed values

    la $a0, matrixA                         #Prints the introduction to the first matrix
    lw $v0, PRINT_STRING_CODE
    syscall

    lw $a0, -4($fp)                         #n
    move $a1, $s0                           #moving the required values in the a registers for the arguments for printMatrix

    jal printMatrix                         #Calling printMatrix

    la $a0, det                             #Prints the introduction to the determinant value
    lw $v0, PRINT_STRING_CODE
    syscall

    lw $a0, -4($fp)                         #n
    move $a1, $s0                           #address of matrix 

    jal  recursive_det                      #calling the recursive_det ffunction to calculate the determinant

    move $a0, $v0                           #printing the return value from the recursive_det function
    lw $v0, PRINT_INT_CODE
    syscall

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

popFromStack:
    lw $v0, 0($sp)                          #returns the first element in the stack
    jr $ra 

fillMatrix:                                 #populates the matrix with the required values, parameters => a0(a), a1(r), a2(m), a3(address)
    sw $a0, 0($a3)                          #saving the first number a
    addi $a3, $a3, -4                       #going to the space for the second element

    j loop1                                 #entering an loop

    loop1:                              
        mult $a0, $a1                       #multiplying the previous entered element with r
        mflo $a0                            
        div $a0, $a2                        #taking the mod of the value
        mfhi $a0
        sw $a0, 0($a3)                      #saving it to the corresponding space
        addi $a3, $a3, -4                   #moving to the next address

        blt $a3, $sp, exit_fill             #If the address exceeds the allocated memory, exit the loop
        j loop1
    
    exit_fill:                              #returns to main
        jr $ra


printMatrix:                                #prints a nxn matrix, parameters => a0(n), a1(address)
    li $t0, 0                               #initialising the iterator for the first loop (i)
    li $t1, 0                               #initialising the iterator for the nested loop (j)
    move $t2, $a0                           #moving n in a different register as a0 will be used for printing
    move $t3, $a1
    j print_loop1                           #initialising the loop

    print_loop2:                            #Nested loop
        lw $a0, 0($t3)                      #loads the value to be printed
        lw $v0, PRINT_INT_CODE
        syscall
        la $a0, space                       #prints space to distinguish two values
        lw $v0, PRINT_STRING_CODE
        syscall
        addi $t3, $t3, -4                   #Moves to the next space
        addi $t1, $t1, 1                    #j++
        bne $t1, $t2, print_loop2           #checks for j<n

    print_loop1:
        beq $t0, $t2, exit_print            #check for i!=n
        addi $t0, $t0, 1                    #i++
        li $t1, 0                           #j=0, for the next iteration of i
        la $a0, newline                     #printing "\n"
        lw $v0, PRINT_STRING_CODE
        syscall
        j print_loop2                       #calling for the nested loop
    
    exit_print:
        jr $ra

recursive_det: 
    move $t0, $ra                           #saving the return address
    move $t1, $a0
    move $t2, $a1
    jal initStack                           #initialising the stack for this function
    move $a0, $t0                           #pushing the previous return address to the stack
    jal pushToStack
    move $a0, $t1                           #pushing n to the stack
    jal pushToStack
    move $a0, $t2                           #pushing the address of the current matrix to the stack
    jal pushToStack
    li $t0, 1
    beq $t1, $t0, last_el                   #checking if n=1, then return the sole element as the determinant value
    li $a0, 0                               #initialising the answer of the determinant of the matrix
    jal pushToStack                         #allocating space for the answer in the stack
    jal pushToStack                         #allocating space for the index of the loop in the stack
    jal pushToStack                         #allocating space for the new matrix memory in the stack
    jal pushToStack                         #allocating space for the sign variable in the stack
    addi $t3, $t1, -1                       #n-1
    mult $t3, $t3                           #calculating the space required for the new matrix
    mflo $a0                
    jal mallocInStack                       #allocating space for the new matrix
    move $t3, $v0                           #address of the first element of the new cofactor matrix
    li $t4,0                                #initialising the loop variable, i=0
    li $t7, 1                               #sign variable to keep a check of the cofactor's sign

    det_loop:
        #get cofactor
        move $a0, $t1                       #number of rows in the current matrix (n)
        move $a1, $t4                       #index of the current iteration
        move $a2, $t2                       #address of the current matrix
        move $a3, $t3                       #address of the new temporary matrix
        jal get_cofactor

        sw $a1, -20($fp)                    #saving the current index in the stack
        sw $a3, -24($fp)                    #saving the address of the temp matrix in the stack
        sw $t7, -28($fp)                    #saving sign variable in the stack

        addi $a0, $a0, -1                   #taking n-1, as the parameter for the recursive_det call
        move $a1, $a3                       #passing the address of the cofactor (temp) matrix as a paramater
        jal recursive_det

        lw $t1, -8($fp)                     #loading n from the memory after recursion 
        lw $t2, -12($fp)                    #loading the address of the current matrix from the memory after recursion
        lw $t4, -20($fp)                    #loading the current index from the memory after recursion
        lw $t3, -24($fp)                    #loading the address of the temp matrix from the memory after recursion
        lw $t7, -28($fp)                    #loading sign from the memory after recursion

        mult $v0, $t7
        mflo $v0                            #multiplying the value of the determinant of the matrix with the sign variable
        sll $t0, $t4, 2                     
        sub $t0, $t2, $t0                   #address of the element matrix[0][i]
        lw $t0, 0($t0)                      #getting the element matrix [0][i]
        mult $v0, $t0                       #multiplying the cofactor's determinant value with the corresponding element according to laplace expansion
        mflo $v0
        lw $t0, -16($fp)                    #loading the answer calculated till the index i-1
        add $t0,$t0, $v0                    #adding the current cofactor's determinant value to the answer variable
        sw $t0, -16($fp)                    #saving the answer in the stack again
        sub $t7, $0, $t7                    #changing the sign variable to it's negative
        addi $t4, $t4, 1                    #i++
        bne $t4, $t1, det_loop      
    
    lw $v0, -16($fp)                        #loads the value of the ans in the register used for return values
    j exit_det                              #clear the stack

    last_el:
        lw $v0, 0($t2)                      #If there is only one element, then return that
    exit_det:
        lw $ra, -4($fp)                     #restoring the return address 
        move $sp, $fp                       #popping the stack pointer for this function and clearing it's memory
        lw $fp, 0($sp)                      #restoring the frame pointer
        addi $sp, $sp, 4                    #clearing the memory used by storing the previous frame pointer
        jr $ra
    

get_cofactor:
    move $t0,$a0                            #n
    move $t1,$a1                            #index to be skipped
    sll $t2, $t0, 2                         #calculating 4*n
    sub $t2,$a2,$t2                         #skipping the first row
    move $t3,$a3
    li $t4, 1                               #loop variable, i=1
    li $t5, 0                               #nested loop variable, j=0
    j cofac_loop1

    cofac_cont:                             #continue for the nested for loop
        addi $t5, $t5, 1
        addi $t2, $t2, -4                   #Moves to the next space
        beq $t5, $t0, cofac_loop1

    cofac_loop2:                            #Nested loop
        beq $t5,$t1, cofac_cont             #if the index==the column which is not to be included, continue
        lw $t6, 0($t2)                      #loads the required element to be saved in the cofactor matrix
        sw $t6, 0($t3)                      #saves the corresponding element from the bigger matrix into the cofactor matrix
        addi $t3, $t3, -4                   #Moves to the next space in the bigger matrix
        addi $t2, $t2, -4                   #Moves to the next space in the cofactor matrix
        addi $t5, $t5, 1                    #j++
        blt $t5, $t0, cofac_loop2           #checks for j<n

    cofac_loop1:
        beq $t4, $t0, exit_cofac             #check for i!=n
        addi $t4, $t4, 1                     #i++
        li $t5, 0                            #j=0, for the next iteration of i
        j cofac_loop2                        #calling for the nested loop
    
    exit_cofac: 
        jr $ra                              #returning