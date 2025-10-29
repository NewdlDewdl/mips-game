# Validation and answer checking

.data
binary_buffer:      .space 16
correct_answer_buf: .space 16

.text
.globl int_to_binary_string
int_to_binary_string:
    # $a0 = integer (0-255), $a1 = buffer address
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    move $s0, $a0
    move $s1, $a1
    li $t0, 7

itbs_loop:
    bltz $t0, itbs_end
    srlv $t1, $s0, $t0
    andi $t1, $t1, 1
    addiu $t2, $t1, '0'
    sb $t2, 0($s1)
    addiu $s1, $s1, 1
    addiu $t0, $t0, -1
    j itbs_loop

itbs_end:
    sb $zero, 0($s1)

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addiu $sp, $sp, 12
    jr $ra

.globl binary_string_to_int
binary_string_to_int:
    # $a0 = address of binary string (8 chars)
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    move $s0, $a0
    li $v0, 0
    li $t0, 0

bs2i_loop:
    bge $t0, 8, bs2i_done
    sll $v0, $v0, 1
    add $t1, $s0, $t0
    lb $t2, 0($t1)
    beq $t2, '1', bs2i_set
    addiu $t0, $t0, 1
    j bs2i_loop

bs2i_set:
    ori $v0, $v0, 1
    addiu $t0, $t0, 1
    j bs2i_loop

bs2i_done:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addiu $sp, $sp, 12
    jr $ra

.globl validate_decimal
validate_decimal:
    bltz $a0, vd_invalid
    li $t0, 255
    bgt $a0, $t0, vd_invalid
    li $v0, 1
    jr $ra

vd_invalid:
    move $v0, $zero
    jr $ra

.globl validate_binary_string
validate_binary_string:
    # $a0 = string address
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    move $s0, $a0
    li $s1, 0

vbs_loop:
    lb $t0, 0($s0)
    beq $t0, $zero, vbs_end
    beq $t0, 10, vbs_newline
    beq $t0, '0', vbs_good
    beq $t0, '1', vbs_good
    move $v0, $zero
    j vbs_done

vbs_newline:
    sb $zero, 0($s0)
    j vbs_end

vbs_good:
    addiu $s1, $s1, 1
    addiu $s0, $s0, 1
    j vbs_loop

vbs_end:
    li $t1, 8
    bne $s1, $t1, vbs_fail
    li $v0, 1
    j vbs_done

vbs_fail:
    move $v0, $zero

vbs_done:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addiu $sp, $sp, 12
    jr $ra

.globl check_puzzle_answer
check_puzzle_answer:
    # $a0 = puzzle index, $a1 = user answer (int)
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    move $s0, $a0          # index
    move $s1, $a1          # answer

    move $a0, $s0
    jal get_puzzle_type
    move $s2, $v0

    move $a0, $s0
    jal get_puzzle_value
    move $s3, $v0

    beq $s2, $zero, cpa_bin_to_dec
    j cpa_dec_to_bin

cpa_bin_to_dec:
    beq $s1, $s3, cpa_mark_correct
    j cpa_mark_incorrect

cpa_dec_to_bin:
    beq $s1, $s3, cpa_mark_correct

cpa_mark_incorrect:
    move $a0, $s0
    li $a1, 2
    jal set_puzzle_status
    move $v0, $zero
    j cpa_cleanup

cpa_mark_correct:
    move $a0, $s0
    li $a1, 1
    jal set_puzzle_status
    li $v0, 1

cpa_cleanup:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addiu $sp, $sp, 20
    jr $ra

.globl get_correct_answer_string
get_correct_answer_string:
    # $a0 = index, returns address of string with correct answer
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    move $s0, $a0
    move $a0, $s0
    jal get_puzzle_type
    move $s1, $v0

    move $a0, $s0
    jal get_puzzle_value
    move $s2, $v0

    beq $s1, $zero, gcas_decimal

    # Need binary string
    la $a1, binary_buffer
    move $a0, $s2
    jal int_to_binary_string
    la $v0, binary_buffer
    j gcas_done

gcas_decimal:
    # Convert decimal to string in buffer
    la $s3, correct_answer_buf
    move $a0, $s2
    move $a1, $s3
    jal int_to_string
    la $v0, correct_answer_buf

gcas_done:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addiu $sp, $sp, 20
    jr $ra

.globl int_to_string
int_to_string:
    # $a0 = value, $a1 = buffer (min 12 bytes)
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    move $s0, $a0
    move $s1, $a1
    li $t0, 10
    beq $s0, $zero, its_zero

    addiu $s2, $s1, 11
    sb $zero, 0($s2)
    addiu $s2, $s2, -1

its_loop:
    beq $s0, $zero, its_copy
    div $s0, $t0
    mfhi $t1
    mflo $s0
    addiu $t1, $t1, '0'
    sb $t1, 0($s2)
    addiu $s2, $s2, -1
    j its_loop

its_copy:
    addiu $s2, $s2, 1
    move $t2, $s2

its_copy_loop:
    lb $t3, 0($t2)
    sb $t3, 0($s1)
    beq $t3, $zero, its_done
    addiu $t2, $t2, 1
    addiu $s1, $s1, 1
    j its_copy_loop

its_zero:
    sb '0', 0($s1)
    sb $zero, 1($s1)
    j its_done

its_done:
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addiu $sp, $sp, 16
    jr $ra
