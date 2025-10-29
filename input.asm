# User input handling

.data
line_prompt_prefix:        .asciiz "Line "
decimal_prompt_suffix:     .asciiz " - Enter decimal value (0-255): "
binary_prompt_suffix:      .asciiz " - Enter 8-bit binary (e.g., 10101010): "
error_invalid_decimal:     .asciiz "Invalid input! Try again.\n"
error_invalid_binary:      .asciiz "ERROR: Invalid input! Please enter 8 binary digits (0 or 1).\n"
input_buffer:              .space 32

.text
.globl get_decimal_input
get_decimal_input:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)

    move $s0, $a0

gdi_prompt:
    la $a0, line_prompt_prefix
    jal print_string
    addiu $t0, $s0, 1
    move $a0, $t0
    jal print_int
    la $a0, decimal_prompt_suffix
    jal print_string

    jal read_integer
    move $s1, $v0

    move $a0, $s1
    jal validate_decimal
    beq $v0, 1, gdi_valid

    la $a0, error_invalid_decimal
    jal print_string
    j gdi_prompt

gdi_valid:
    jal print_newline
    move $v0, $s1

    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    lw $s4, 0($sp)
    addiu $sp, $sp, 24
    jr $ra

.globl get_binary_input
get_binary_input:
    addiu $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)

    move $s0, $a0

gbi_prompt:
    la $a0, line_prompt_prefix
    jal print_string
    addiu $t0, $s0, 1
    move $a0, $t0
    jal print_int
    la $a0, binary_prompt_suffix
    jal print_string

    la $a0, input_buffer
    li $a1, 16
    jal read_string

    la $a0, input_buffer
    jal validate_binary_string
    beq $v0, 1, gbi_valid

    la $a0, error_invalid_binary
    jal print_string
    j gbi_prompt

gbi_valid:
    la $a0, input_buffer
    jal binary_string_to_int
    move $s1, $v0
    jal print_newline
    move $v0, $s1

    lw $ra, 24($sp)
    lw $s0, 20($sp)
    lw $s1, 16($sp)
    lw $s2, 12($sp)
    lw $s3, 8($sp)
    lw $s4, 4($sp)
    lw $s5, 0($sp)
    addiu $sp, $sp, 28
    jr $ra
