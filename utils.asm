# Utility helper routines for console IO and string handling

.text
    .globl print_string
print_string:
    beq $a0, $zero, print_string_return
    li  $v0, 4
    syscall
print_string_return:
    jr  $ra

    .globl print_int
print_int:
    li  $v0, 1
    syscall
    jr  $ra

    .globl print_char
print_char:
    li  $v0, 11
    syscall
    jr  $ra

    .globl print_newline
print_newline:
    li  $a0, '\n'
    jal print_char
    jr  $ra

    .globl delay
# delay(milliseconds) - naive busy-wait loop
delay:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a0
    blez $s0, delay_exit

    li  $t0, 5000

delay_outer:
    move $t1, $t0

delay_inner:
    addiu $t1, $t1, -1
    bgtz $t1, delay_inner

    addiu $s0, $s0, -1
    bgtz $s0, delay_outer

delay_exit:
    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl int_to_string
# int_to_string(value, buffer) - converts integer to decimal string
int_to_string:
    addiu $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)

    move $s0, $a0          # value
    move $s1, $a1          # buffer base
    move $s2, $zero        # digit counter
    move $s3, $zero        # negative flag

    beq $s0, $zero, int_to_string_zero
    bltz $s0, int_to_string_negative
    j int_to_string_convert

int_to_string_negative:
    negu $s0, $s0
    li  $s3, 1

int_to_string_convert:
    li  $t0, 10
    move $t1, $s1

int_to_string_loop:
    divu $s0, $t0
    mfhi $t2
    mflo $s0
    addiu $t2, $t2, '0'
    sb  $t2, 0($t1)
    addiu $t1, $t1, 1
    addiu $s2, $s2, 1
    bnez $s0, int_to_string_loop

    addiu $t3, $s2, -1
    move $t4, $zero

reverse_loop:
    bge $t4, $t3, reverse_done
    addu $t5, $s1, $t4
    lb  $t6, 0($t5)
    addu $t7, $s1, $t3
    lb  $t8, 0($t7)
    sb  $t8, 0($t5)
    sb  $t6, 0($t7)
    addiu $t4, $t4, 1
    addiu $t3, $t3, -1
    j reverse_loop

reverse_done:
    move $t9, $s2          # final length without sign
    beq $s3, $zero, append_sign

    addiu $t3, $t9, -1
shift_loop:
    bltz $t3, shift_done
    addu $t4, $s1, $t3
    lb  $t5, 0($t4)
    sb  $t5, 1($t4)
    addiu $t3, $t3, -1
    j shift_loop

shift_done:
    sb  '-', 0($s1)
    addiu $t9, $t9, 1

append_sign:
    addu $t0, $s1, $t9
    sb  $zero, 0($t0)
    j int_to_string_exit

int_to_string_zero:
    sb  '0', 0($s1)
    sb  $zero, 1($s1)
    j int_to_string_exit

int_to_string_exit:
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    addiu $sp, $sp, 32
    jr $ra

    .globl string_length
string_length:
    move $t0, $a0
    li  $t1, 0

string_length_loop:
    lb  $t2, 0($t0)
    beq $t2, $zero, string_length_done
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    j string_length_loop

string_length_done:
    move $v0, $t1
    jr $ra
