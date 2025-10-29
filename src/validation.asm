# Input validation and answer checking

.set noreorder

.text
    .globl validate_decimal
validate_decimal:
    # $a0 = integer input
    bltz $a0, validate_decimal_false
    li $t0, 255
    bgt $a0, $t0, validate_decimal_false
    li $v0, 1
    jr $ra

validate_decimal_false:
    move $v0, $zero
    jr $ra

    .globl validate_binary_string
validate_binary_string:
    # $a0 = address of string
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)

    move $s0, $a0
    move $s1, $zero

validate_binary_loop:
    lb $t0, 0($s0)
    beqz $t0, validate_binary_end
    li $t1, '0'
    li $t2, '1'
    beq $t0, $t1, validate_binary_next
    beq $t0, $t2, validate_binary_next
    move $v0, $zero
    j validate_binary_cleanup

validate_binary_next:
    addiu $s1, $s1, 1
    addiu $s0, $s0, 1
    j validate_binary_loop

validate_binary_end:
    li $t3, 8
    beq $s1, $t3, validate_binary_true
    move $v0, $zero
    j validate_binary_cleanup

validate_binary_true:
    li $v0, 1

validate_binary_cleanup:
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl binary_string_to_int
binary_string_to_int:
    # $a0 = address of 8-char string
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)

    move $s0, $a0
    move $s1, $zero

    li $t0, 0

binary_to_int_loop:
    li $t1, 8
    bge $s1, $t1, binary_to_int_done

    lb $t2, 0($s0)
    addiu $s0, $s0, 1
    addiu $s1, $s1, 1

    sll $t0, $t0, 1
    li $t3, '1'
    beq $t2, $t3, binary_set_bit
    j binary_to_int_loop

binary_set_bit:
    ori $t0, $t0, 1
    j binary_to_int_loop

binary_to_int_done:
    move $v0, $t0

    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl int_to_binary_string
int_to_binary_string:
    # $a0 = value, $a1 = buffer
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)

    move $s0, $a0
    move $s1, $a1
    li $s2, 7

int_to_binary_loop:
    bltz $s2, int_to_binary_done
    move $t0, $s0
    move $t1, $s2
    srlv $t0, $t0, $t1
    andi $t0, $t0, 1

    li $t2, '0'
    beqz $t0, store_binary_char
    li $t2, '1'

store_binary_char:
    li $t3, 7
    subu $t4, $t3, $s2
    addu $t5, $s1, $t4
    sb $t2, 0($t5)

    addiu $s2, $s2, -1
    j int_to_binary_loop

int_to_binary_done:
    li $t6, 8
    addu $t7, $s1, $t6
    sb $zero, 0($t7)

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    addiu $sp, $sp, 20
    jr $ra

    .globl check_puzzle_answer
check_puzzle_answer:
    # $a0 = puzzle index, $a1 = user answer (integer)
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)

    move $s0, $a0
    move $s1, $a1

    move $a0, $s0
    jal get_puzzle_type
    move $s2, $v0

    move $a0, $s0
    jal get_puzzle_value
    move $s3, $v0

    beq $s2, $zero, compare_answer
    # Type 1: decimal -> binary, compare answer to stored value
    beq $s1, $s3, answer_correct
    j answer_incorrect

compare_answer:
    beq $s1, $s3, answer_correct
    j answer_incorrect

answer_correct:
    li $v0, 1
    j answer_done

answer_incorrect:
    move $v0, $zero

answer_done:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    addiu $sp, $sp, 24
    jr $ra
