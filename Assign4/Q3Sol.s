####################################
####        Assgn 04            ####
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
key_msg: 
    .asciiz "Enter Key to serch for: "
found_msg: 
    .asciiz " is FOUND in the array at index "
not_found_msg: 
    .asciiz " is NOT FOUND in the array"
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
    li $t0, 10                             # Loop variable, n

    # Reading all elements of the array
    la $a0, array_msg                     # printing input message
    lw $v0, PRINT_STRING_CODE           
    syscall

    la $t1, array                               
    li $t2, 0                             # initialising i to 0

    input_loop:
        # Reading the elements in a sequence

        lw $v0, READ_INT_CODE
        syscall
        sw $v0, 0($t1)

        addi $t1, $t1, 4                   # a[i]->a[i+1]
        addi $t2, $t2, 1                   # i++
        bne $t2, $t0, input_loop           # if i!=n continue loop 

    # setting required parameters in a0, a1 and a2
    la $a0, array   # array address in a0
    li $a1, 0       # start index in a1
    li $a2, 9       # end index in a2
    jal recursive_sort  # calling recursive_sort function

    la $a0, sort_msg    # printing sort message
    lw $v0, PRINT_STRING_CODE
    syscall


    la $a0, array       # setting up parameters for print array function
    jal printArray      # printing array

    la $a0, key_msg    # printing sort message
    lw $v0, PRINT_STRING_CODE
    syscall

    lw $v0, READ_INT_CODE
    syscall
    move $a3, $v0
    la $a0, array
    li $a1, 0
    li $a2, 9
    jal recursive_search

    move $s0, $v0

    blt $v0, $0, error_state  
    j found
    
    error_state:
        lw $v0, PRINT_INT_CODE
        move $a0, $a3
        syscall

        lw $v0, PRINT_STRING_CODE
        la $a0, not_found_msg
        syscall

        lw $v0, PRINT_STRING_CODE
        la $a0, newline
        syscall

        j exit_code

    found:
        lw $v0, PRINT_INT_CODE
        move $a0, $a3
        syscall

        lw $v0, PRINT_STRING_CODE
        la $a0, found_msg
        syscall

        lw $v0, PRINT_INT_CODE
        move $a0, $s0
        syscall

        lw $v0, PRINT_STRING_CODE
        la $a0, newline
        syscall

    exit_code:
        lw $v0, EXIT_CODE   # terminate program
        syscall


recursive_search:
    move $t0, $ra
    jal initStack
    move $s0, $a0
    move $a0, $t0
    jal pushToStack
    move $a0, $a1
    jal pushToStack
    move $a0, $a2
    jal pushToStack
    move $a0, $s0

    while_loop_search:
        bgt $a1, $a2, not_found
        sub $t0, $a2, $a1
        li $t1, 3
        div $t0, $t1
        mflo $t0
        add $t1, $a1, $t0
        sub $t2, $a2, $t0 
        sll $t3, $t1, 2
        add $t3, $a0, $t3
        lw $t5, 0($t3)
        beq $t5, $a3, found_mid1
        sll $t4, $t2, 2
        add $t4, $a0, $t4
        lw $t6, 0($t4)
        beq $t6, $a3, found_mid2
        blt $a3, $t5, first_range
        bgt $a3, $t6, last_range
        j mid_range

        found_mid1:
            move $v0, $t1
            j exit_search    

        found_mid2:
            move $v0, $t2
            j exit_search   

        first_range:
            addi $a2, $t1, -1
            jal recursive_search
            j exit_search

        last_range:
            addi $a1, $t2, 1
            jal recursive_search
            j exit_search

        mid_range:
            addi $a1, $t1, 1
            addi $a2, $t2, -1
            jal recursive_search
            j exit_search

        not_found:
            li $v0, -1   

    exit_search:
        move $sp, $fp
        lw $ra, -4($fp)
        lw $fp, 0($fp)
        addi $sp, $sp, 4
        jr $ra                                   # return to call location


recursive_sort:
    move $t0, $ra      # move ra to t0 for temporary storing
    jal initStack      # initialize stack
    move $s0, $a0      # move array address to s0
    move $a0, $t0      # move ra stored in t0 to a0
    jal pushToStack    # add ra in stack and decrease stack pointer by 4
    move $a0, $a1      # move left in a0
    jal pushToStack    # add left in stack and decrease stack pointer by 4
    move $a0, $a2      # move right in a0
    jal pushToStack    # add right in stack and decrease stack pointer by 4
    lw $t0, 4($sp)     # initializing variable l to left, l = left
    lw $t1, 4($sp)     # initializing variable p to left, p = left 
    lw $t2, 0($sp)     # initializing variable r to right, r = right
    move $a0, $t0      # move l to a0
    jal pushToStack    # move l in stack and decrease stack pointer by 4                 
    move $a0, $t1      # move p to a0
    jal pushToStack    # move p in stack and decrease stack pointer by 4 
    move $a0, $t2      # move r to a0
    jal pushToStack    # move r in stack and decrease stack pointer by 4 
    move $a0, $s0      # move address of array to a0
    
    while_loop:
        lw $t0, 8($sp)                         # load variable l in t0
        lw $t1, 4($sp)                         # load variable p in t1
        lw $t2, 0($sp)                         # load variable r in t2
        bge $t0, $t2, exit                     # if l>r go to exit, terminate first while_loop
        while_loop_left:
            move $t4, $t0                      # move t0 to t4 i.e l->t4 
            move $t5, $t1                      # move t1 to t5 i.e p->t5
            sll $t4, $t4, 2                    # multiply t4 by 4, 4*l->t4
            sll $t5, $t5, 2                    # multiply t5 by 4, 4*p->t5
            add $t4, $t4, $a0                  # store address of a[l] in t4
            add $t5, $t5, $a0                  # store address of a[p] in t5
            lw $t4, 0($t4)                     # load value in a[l] in t4
            lw $t5, 0($t5)                     # load value in a[p] in t5
            bgt $t4, $t5, while_loop_right     # if a[l]>a[p] break the while loop
            lw $t3, 12($sp)                    # store value of right in t3
            bge $t0, $t3, while_loop_right     # if l >= right, break the while loop
            addi $t0, $t0, 1                   # if still in loop, add one in t0, l++
            j while_loop_left                  # continue while_loop_left

        
        while_loop_right:
            move $t4, $t2                      # move t2 to t4 i.e r->t4 
            move $t5, $t1                      # move t1 to t5 i.e p->t5
            sll $t4, $t4, 2                    # multiply t4 by 4, 4*r->t4
            sll $t5, $t5, 2                    # multiply t5 by 4, 4*p->t5
            add $t4, $t4, $a0                  # store address of a[r] in t4
            add $t5, $t5, $a0                  # store address of a[p] in t5
            lw $t4, 0($t4)                     # load value in a[r] in t4
            lw $t5, 0($t5)                     # load value in a[p] in t5
            blt $t4, $t5, if_case              # if a[r]<a[p] break the while loop
            lw $t3, 16($sp)                    # store value of left in t3
            ble $t2, $t3, if_case              # if r <= left, break the while loop
            addi $t2, $t2, -1                  # if still in loop, add -1 in t0, r--
            j while_loop_right                 # continue while_loop_left

        
        if_case:
            sw $t0, 8($sp)                     # save value of l in stack
            sw $t2, 0($sp)                     # save value of r in stack
            blt $t0, $t2, else_case            # if l<r go to else case
            move $a1, $t1          
            move $a2, $t2 
            jal SWAP                           # swap a[p] and a[r]
            lw $a1, 16($sp)                    # strore left in a1
            lw $a2, 0($sp)                     # store r in a2
            addi $a2, $a2, -1                  # r = r-1
            jal recursive_sort                 # call recursive_sort for left, r-1
            lw $a1, 0($sp)                     # store r in a1
            lw $a2, 12($sp)                    # store right in a2
            addi $a1, $a1, 1                   # r= r+1
            jal recursive_sort                 # call recursive_sort for r+1, right
            j exit                             # break, return
         
        else_case:
            move $a1, $t0                      # store l in a1
            move $a2, $t2                      # store r in a2
            jal SWAP                           # swap a[l] and a[r]
            j while_loop                       # continue


    exit:
        lw $ra, -4($fp)                       # restore return pointer, for returning to call location
        move $sp, $fp                         # pop stack by moving stack pointer to fp
        lw $fp, 0($fp)                        # move fp to its intial position
        addi $sp, $sp, 4                      # add 4 in stack for poping out fp
        jr $ra                                # return to call location



initStack:                                  # Initialises the stacck and the frame pointer
    addi $sp, $sp, -4                       # makes space in the stack to store the content of frame pointer
    sw $fp, 0($sp)                          # saves the content of fp
    move $fp, $sp                           # makes fp the frame pointer for this particular function
    jr $ra                                  # return to call location

pushToStack:                                # To allocate space to a variable in the stack
    addi $sp, $sp, -4                       # making space in the stack
    sw $a0, 0($sp)                          # saving in the space made
    jr $ra                                  # return to call location

SWAP: 
    sll $a2, $a2, 2                          # multiple index by 4, i->4*i, a2->4*i
    sll $a1, $a1, 2                          # multiple index by 4, j->4*j, a2->4*j
    add $t0, $a0, $a1                        # adding 4*i in array address to get address of a[i], t0->a[i]
    add $t1, $a0, $a2                        # adding 4*j in array address to get address of a[j], t1->a[j]
    lw $t2, 0($t0)                           # loading a[i] value in t2
    lw $t3, 0($t1)                           # loading a[j] value in t3
    sw $t2, 0($t1)                           # storing a[i] value in jth location, a[j]=a[i]
    sw $t3, 0($t0)                           # storing a[j] value in ith location, a[i]=a[j], swapping a[j] and a[i]
    jr $ra                                   # return to call location

printArray:
    li $t0, 10                              # initializing loop variable i to 10
    move $t1, $a0                           # storing address of array in t1 for looping through array
    move $t2, $a0                           # storing address of array in t2 for preserving a0 value
    loop:
        lw $t3, 0($t1)                      # read word from t1 location
        lw $v0, PRINT_INT_CODE              # print integer currently at t1
        move $a0, $t3
        syscall
        lw $v0, PRINT_STRING_CODE           # print space
        la $a0, space
        syscall
        addi $t1, $t1, 4                    # add 4 in t1 i.e a[i]->a[i+1]
        addi $t0, $t0, -1                   # suntract 1 from t0 i.e i--
        bne $t0, 0, loop                    # id i!=0 continue in the loop

    lw $v0, PRINT_STRING_CODE                # print newline
    la $a0, newline
    syscall

    move $a0, $t2                            # put address in array back in a0
    jr $ra                                   # return to call location