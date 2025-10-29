# Validation and conversion utilities for puzzle answers

.text
    .globl validate_decimal
validate_decimal:
    bltz $a0, validate_decimal_fail
    li   $t0, 255
    bgt  $a0, $t0, validate_decimal_fail
    li   $v0, 1
    jr   $ra

validate_decimal_fail:
    move $v0, $zero
    jr   $ra

    .globl validate_binary_string
validate_binary_string:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)

    move $s0, $a0
    jal string_length
    move $s1, $v0
    li   $t0, 8
    bne  $s1, $t0, validate_binary_fail

    move $t1, $zero

validate_binary_loop:
    addu $t2, $s0, $t1
    lb   $t3, 0($t2)
    li   $t4, '0'
    li   $t5, '1'
    beq  $t3, $t4, validate_binary_next
    beq  $t3, $t5, validate_binary_next
    j    validate_binary_fail

validate_binary_next:
    addiu $t1, $t1, 1
    blt  $t1, $s1, validate_binary_loop

    li   $v0, 1
    j    validate_binary_exit

validate_binary_fail:
    move $v0, $zero

validate_binary_exit:
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl binary_string_to_int
binary_string_to_int:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)

    move $s0, $zero
    li   $t0, 0

binary_string_loop:
    addu $t1, $a0, $t0
    lb   $t2, 0($t1)
    beq  $t2, $zero, binary_string_done
    sll  $s0, $s0, 1
    li   $t3, '1'
    beq  $t2, $t3, binary_string_set
    j    binary_string_continue

binary_string_set:
    ori  $s0, $s0, 1

binary_string_continue:
    addiu $t0, $t0, 1
    j    binary_string_loop

binary_string_done:
    move $v0, $s0

    lw $ra, 12($sp)
    lw $s0, 8($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl int_to_binary_string
# int_to_binary_string(value, buffer)
int_to_binary_string:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)

    move $s0, $a0
    li   $t0, 7

binary_string_build:
    bltz $t0, binary_string_finish
    srlv $t1, $s0, $t0
    andi $t1, $t1, 1
    li   $t2, 7
    subu $t3, $t2, $t0      # offset = 7 - bit_index
    addu $t4, $a1, $t3
    li   $t5, '0'
    beq  $t1, $zero, binary_store_char
    li   $t5, '1'

binary_store_char:
    sb   $t5, 0($t4)
    addiu $t0, $t0, -1
    j    binary_string_build

binary_string_finish:
    addu $t6, $a1, 8
    sb   $zero, 0($t6)

    lw $ra, 12($sp)
    lw $s0, 8($sp)
    addiu $sp, $sp, 16
    jr $ra
