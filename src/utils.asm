# Utility functions for Binary Game

.data
    .align 2
    .globl newline_str
newline_str:    .asciiz "\n"

.text
    .globl print_string
print_string:
    # $a0 = address of null-terminated string
    beqz $a0, print_string_return
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    li $v0, 4
    syscall

    lw $ra, 4($sp)
    lw $a0, 0($sp)
    addiu $sp, $sp, 8
print_string_return:
    jr $ra

    .globl print_char
print_char:
    # $a0 = character (lower 8 bits used)
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    li $v0, 11
    syscall

    lw $ra, 4($sp)
    lw $a0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl print_int
print_int:
    # $a0 = integer to print
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    li $v0, 1
    move $a0, $a0
    syscall

    lw $ra, 4($sp)
    lw $a0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl print_newline
print_newline:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)

    la $a0, newline_str
    jal print_string

    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl delay
# Busy wait delay. Not precise but adequate for pacing text output.
delay:
    # $a0 = milliseconds
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    blez $a0, delay_done
    li $s0, 1000          # Inner loop iterations per millisecond

outer_delay_loop:
    move $s1, $s0
inner_delay_loop:
    addiu $s1, $s1, -1
    bgtz $s1, inner_delay_loop

    addiu $a0, $a0, -1
    bgtz $a0, outer_delay_loop

delay_done:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl string_length
string_length:
    # $a0 = address of string
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    move $s0, $a0
    move $s1, $zero

string_length_loop:
    lb $t0, 0($s0)
    beqz $t0, string_length_done
    addiu $s0, $s0, 1
    addiu $s1, $s1, 1
    j string_length_loop

string_length_done:
    move $v0, $s1
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl int_to_string
int_to_string:
    # $a0 = integer value
    # $a1 = buffer address
    addiu $sp, $sp, -40
    sw $ra, 36($sp)
    sw $s0, 32($sp)
    sw $s1, 28($sp)
    sw $s2, 24($sp)
    sw $s3, 20($sp)

    move $s0, $a0          # value
    move $s1, $a1          # buffer
    addiu $s2, $sp, 0      # temp storage base

    beqz $s0, int_to_string_zero

    move $s3, $zero        # count of digits

int_to_string_loop:
    li $t0, 10
    divu $s0, $t0
    mfhi $t1               # remainder
    addiu $t1, $t1, 48     # convert to ASCII
    sb $t1, 0($s2)
    addiu $s2, $s2, 1
    addiu $s3, $s3, 1
    mflo $s0               # quotient
    bnez $s0, int_to_string_loop

    addiu $s2, $s2, -1     # point to last stored char

    # Reverse copy into buffer
    move $t2, $s3
    move $t3, $zero
int_to_string_reverse:
    lb $t4, 0($s2)
    sb $t4, 0($s1)
    addiu $s1, $s1, 1
    addiu $s2, $s2, -1
    addiu $t3, $t3, 1
    blt $t3, $t2, int_to_string_reverse

    sb $zero, 0($s1)
    j int_to_string_done

int_to_string_zero:
    sb $zero, 1($s1)
    li $t0, 48
    sb $t0, 0($s1)

int_to_string_done:
    lw $ra, 36($sp)
    lw $s0, 32($sp)
    lw $s1, 28($sp)
    lw $s2, 24($sp)
    lw $s3, 20($sp)
    addiu $sp, $sp, 40
    jr $ra
