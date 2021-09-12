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

    
####################### Data segment ######################################
.data

# program output text constants
prompt1:
    .asciiz "Enter First Number: "
prompt2:
    .asciiz "Enter Second Number: "
error_msg:          
    .asciiz "Entered number should be 16 bit unsigned integer i.e in range [-32768,32767]"
result:
    .asciiz "Product of the two numbers is: "
newline:
    .asciiz "\n"

READ_INT_CODE:       .word 5
PRINT_INT_CODE:      .word 1
PRINT_STRING_CODE:   .word 4
EXIT_CODE:           .word 10

####################### Data segment ######################################

####################### Text segment ######################################

.text
.globl  main
main:
    li      $t0, 32767
    li      $t1, -32768
    li      $v0, 4          # issue prompt
    la      $a0, prompt1
    syscall

    li      $v0, 5          # get First number
    syscall
    move    $a1, $v0
 
    bgt     $a1, $t0, error     # check for validity of input
    blt     $a1, $t1, error   

    li      $v0, 4          # issue prompt
    la      $a0, prompt2
    syscall

    li      $v0, 5          # get Second Number
    syscall
    move    $a0, $v0

    bgt     $a0, $t0, error      # check for validity of input
    blt     $a0, $t1, error 

    jal     Booth       # procedural call to Booth
    move    $a3 $v0     # move ans to a3

    li      $v0, 4          # issue prompt
    la      $a0, result
    syscall

    li        $v0, 1          # issue prompt
    move      $a0, $a3
    syscall

    j exit

error:                      # if input value is invalid
    la $a0, error_msg
    li $v0, 4
    syscall 

exit: 
    li      $v0, 10         # terminate the program
    syscall

Booth:                         # first number is in a0 and second number is in a1
    move $s2, $0               # A
    move $s3, $0               # Q-1
    li $s4, 32                 # Count 
    move $s0 $a0               # multiplicantd
    move $s1 $a1               # multiplier    
    
    update:
                    
        andi $t0, $s1, 1          # Q0
        
        beq $t0, $s3, shift       # if Q0==Q-1  only do shift operation
        bne $t0, $0, subtract     # if 10
        j add1                    # if 01

        subtract:                
            sub $s2, $s2, $s0    # A = A-M
            j shift
            
        add1: 
            add $s2, $s2, $s0    # A = A+M

        shift:
            andi $t1, $s2, 1    # store LSB of A in t1
            sra $s2, $s2, 1     # shift A to left aritmatically i.e preserving sign
            srl $s1, $s1, 1     # shift Q to right
            move $s3, $t0       # copy Q0 in Q-1
            sll $t1, $t1, 31    
            or $s1, $s1, $t1	# make lsb of A as last bit of Q
            addi $s4, $s4, -1   # count = count - 1
            bne $s4, $0, update # go to loop start if count !=0

    exit_booth:
        move $v0, $s1           # move output to v0
        jr $ra                  # return to call location
