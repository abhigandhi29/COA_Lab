####################################
####        Assgn 02            ####
####       Question 01          ####
#  Autumn Semester-Session 2021-22 #
####        Group 22            ####
##  19CS10031 - Abhishek Gandhi   ##
##  19CS10051 - Sajal Chhamunya   ##
####################################

# This program computes and displays the sum of integers from 1 up to n,
# where n is entered by the user.
#

    .globl  main

    .data

# program output text constants
prompt:
    .asciiz "Please enter a positive integer: "
result1:
    .asciiz "The sum of the first "
result2:
    .asciiz " integers is "
newline:
    .asciiz "\n"

    .text

# main program
#
# program variables
#   n:   $s0
#   sum: $s1
#   i:   $s2
#
main:
	lui $t0, 0x1234
	addi $t0,$t0, 0xdcba
	
    li      $v0, 4          # print " integers is "
    move      $a0, $t0
    syscall
    
    li      $v0, 10         # terminate the program
    syscall
