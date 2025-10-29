# Utility functions for MIPS binary game

.data
newline_char:   .asciiz "\n"
zero_string:    .asciiz "0"

.text
.globl print_string
print_string:
    # $a0 = address of null-terminated string
    li $v0, 4
    syscall
    jr $ra

.globl print_int
print_int:
    # $a0 = integer value to print
    move $t0, $a0
    li $v0, 1
    move $a0, $t0
    syscall
    jr $ra

.globl print_char
print_char:
    # $a0 = character (lower byte used)
    li $v0, 11
    syscall
    jr $ra

.globl print_newline
print_newline:
    la $a0, newline_char
    jal print_string
    jr $ra

.globl read_string
read_string:
    # $a0 = buffer address, $a1 = max length
    li $v0, 8
    syscall
    jr $ra

.globl read_integer
read_integer:
    li $v0, 5
    syscall
    jr $ra

.globl string_length
string_length:
    # $a0 = address of string
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a0
    li $v0, 0

sl_loop:
    lb $t0, 0($s0)
    beq $t0, $zero, sl_done
    addiu $s0, $s0, 1
    addiu $v0, $v0, 1
    j sl_loop

sl_done:
    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

