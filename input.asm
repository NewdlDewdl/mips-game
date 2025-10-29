# User input handling routines

.data
    .align 2
    .globl input_buffer
input_buffer: .space 64
line_prompt_prefix: .asciiz "Line "

.text
    .globl get_decimal_input
get_decimal_input:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)

    move $s0, $a0            # puzzle index

decimal_prompt_loop:
    la  $a0, line_prompt_prefix
    jal print_string

    addiu $a0, $s0, 1
    jal print_int

    la  $a0, prompt_decimal
    jal print_string

    jal read_integer
    move $s1, $v0

    move $a0, $s1
    jal validate_decimal
    beq $v0, $zero, decimal_invalid

    move $v0, $s1
    j get_decimal_exit

decimal_invalid:
    la  $a0, error_invalid
    jal print_string
    j   decimal_prompt_loop

get_decimal_exit:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    addiu $sp, $sp, 24
    jr $ra

    .globl get_binary_input
get_binary_input:
    addiu $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)

    move $s0, $a0            # puzzle index

binary_prompt_loop:
    la  $a0, line_prompt_prefix
    jal print_string

    addiu $a0, $s0, 1
    jal print_int

    la  $a0, prompt_binary
    jal print_string

    la  $a0, input_buffer
    li  $a1, 64
    jal read_string

    la  $t0, input_buffer
strip_newline_loop:
    lb  $t1, 0($t0)
    beq $t1, $zero, newline_stripped
    li  $t2, '\n'
    beq $t1, $t2, replace_null
    addiu $t0, $t0, 1
    j strip_newline_loop

replace_null:
    sb  $zero, 0($t0)

newline_stripped:
    la  $a0, input_buffer
    jal validate_binary_string
    beq $v0, $zero, binary_invalid

    la  $a0, input_buffer
    jal binary_string_to_int
    move $v0, $v0
    j get_binary_exit

binary_invalid:
    la  $a0, error_invalid
    jal print_string
    j   binary_prompt_loop

get_binary_exit:
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    addiu $sp, $sp, 32
    jr $ra

    .globl read_string
read_string:
    li  $v0, 8
    syscall
    jr  $ra

    .globl read_integer
read_integer:
    li  $v0, 5
    syscall
    jr  $ra
