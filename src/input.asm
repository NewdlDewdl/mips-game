# User input handling

.set noreorder

.data
    .align 2
    prompt_line_prefix:     .asciiz "Line "
    prompt_decimal_suffix:  .asciiz " - Enter decimal value (0-255): "
    prompt_binary_suffix:   .asciiz " - Enter 8-bit binary (e.g., 10101010): "
    error_decimal:          .asciiz "ERROR: Invalid decimal input! Try again.\n"
    error_binary:           .asciiz "ERROR: Invalid binary input! Try again.\n"
    input_buffer:           .space 64

.text
    .globl read_string
read_string:
    # $a0 = buffer, $a1 = max length
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)

    move $s0, $a0
    move $s1, $a1

    li $v0, 8
    move $a0, $s0
    move $a1, $s1
    syscall

    # Remove trailing newline if present
    move $a0, $s0
    jal string_length
    move $t0, $v0
    beqz $t0, read_string_cleanup

    addiu $t0, $t0, -1
    addu $t1, $s0, $t0
    lb $t2, 0($t1)
    li $t3, 10
    bne $t2, $t3, read_string_cleanup
    sb $zero, 0($t1)

read_string_cleanup:
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl consume_newline
consume_newline:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)

    li $t0, 10

consume_loop:
    li $v0, 12
    syscall
    move $t1, $v0
    beq $t1, $t0, consume_done
    j consume_loop

consume_done:
    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl read_integer
read_integer:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    li $v0, 5
    syscall
    move $s0, $v0

    jal consume_newline

    move $v0, $s0

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl print_line_prompt
print_line_prompt:
    # $a0 = line index (0-based), $a1 = prompt suffix address
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)

    move $s0, $a0
    move $s1, $a1

    la $a0, prompt_line_prefix
    jal print_string

    addiu $s0, $s0, 1
    move $a0, $s0
    jal print_int

    move $a0, $s1
    jal print_string

    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl get_decimal_input
get_decimal_input:
    # $a0 = puzzle index
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)

    move $s0, $a0

get_decimal_retry:
    move $a0, $s0
    la $a1, prompt_decimal_suffix
    jal print_line_prompt

    jal read_integer
    move $s1, $v0

    move $a0, $s1
    jal validate_decimal
    beqz $v0, get_decimal_invalid

    move $v0, $s1
    j get_decimal_done

get_decimal_invalid:
    la $a0, error_decimal
    jal print_string
    j get_decimal_retry

get_decimal_done:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    addiu $sp, $sp, 24
    jr $ra

    .globl get_binary_input
get_binary_input:
    # $a0 = puzzle index
    addiu $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)

    move $s0, $a0

get_binary_retry:
    move $a0, $s0
    la $a1, prompt_binary_suffix
    jal print_line_prompt

    la $a0, input_buffer
    li $a1, 64
    jal read_string

    la $a0, input_buffer
    jal validate_binary_string
    beqz $v0, get_binary_invalid

    la $a0, input_buffer
    jal binary_string_to_int
    move $v0, $v0
    j get_binary_done

get_binary_invalid:
    la $a0, error_binary
    jal print_string
    j get_binary_retry

get_binary_done:
    lw $ra, 24($sp)
    lw $s0, 20($sp)
    lw $s1, 16($sp)
    lw $s2, 12($sp)
    lw $s3, 8($sp)
    lw $s4, 4($sp)
    addiu $sp, $sp, 28
    jr $ra
