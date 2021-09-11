####################################
####        Assgn 03            ####
####       Question 01          ####
#  Autumn Semester-Session 2021-22 #
####        Group 22            ####
##  19CS10031 - Abhishek Gandhi   ##
##  19CS10051 - Sajal Chhamunya   ##
####################################

# This program computes and displays the sum of integers from 1 up to n,
# where n is entered by the user.
#

    

.data

# program output text constants
prompt1:
    .asciiz "Enter First Number: "
prompt2:
    .asciiz "Enter Second Number: "
result:
    .asciiz "Product of the two numbers is: "
newline:
    .asciiz "\n"

    .text

Booth:
    move $s2, $0               # a
    move $s3, $0               # Q-1
    li $s4, 32                 # Count 
    move $s0 $a0
    move $s1 $a1
    
update:
                 # Q n-1
    andi $t0, $s1, 1          # Q n
    
    beq $t0, $s3, shift
    bne $t0, $0, subtract
    j add1

subtract:
    sub $s2, $s2, $s0
    j shift
    
add1: 
    add $s2, $s2, $s0

shift:
    andi $t1, $s2, 1
    sra $s2, $s2, 1
    srl $s1, $s1, 1
    move $s3, $t0
    sll $t1, $t1, 31
    or $s1, $s1, $t1	
    addi $s4, $s4, -1 
    bne $s4, $0, update

exit:
    move $v0, $s1
    jr $ra

.text
.globl  main
main:
    li      $v0, 4          # issue prompt
    la      $a0, prompt1
    syscall

    li      $v0, 5          # get n from user
    syscall
    move    $a1, $v0

    li      $v0, 4          # issue prompt
    la      $a0, prompt2
    syscall

    li      $v0, 5          # get n from user
    syscall
    move    $a0, $v0

    jal Booth
    move $a3 $v0

    li      $v0, 4          # issue prompt
    la      $a0, result
    syscall

    li      $v0, 1          # issue prompt
    move      $a0, $a3
    syscall

    li      $v0, 10         # terminate the program
    syscall
