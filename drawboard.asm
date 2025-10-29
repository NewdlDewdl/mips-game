# Drawing routines for the binary game

.data
border_line:            .asciiz "+------------------------------------------------------------------+\n"
header_level_prefix:    .asciiz "|                    BINARY GAME - LEVEL "
header_level_suffix:    .asciiz "                         |\n"
header_score_prefix:    .asciiz "|                        SCORE: "
header_score_suffix:    .asciiz "                               |\n"
line_header_prefix:     .asciiz "| Line "
line_header_suffix:     .asciiz ": [128] [64] [32] [16] [8] [4] [2] [1] | Decimal: "
decimal_blank_suffix:   .asciiz "[___]  | "
decimal_close_suffix:   .asciiz "]  | "
status_question_str:    .asciiz "?\n"
status_correct_str:     .asciiz "\xE2\x9C\x93\n"
status_incorrect_str:   .asciiz "\xE2\x9C\x97\n"
second_line_prefix:     .asciiz "|         "
decimal_line_prefix:    .asciiz "|          "
bit_one_str:            .asciiz "[ 1] "
bit_zero_str:           .asciiz "[ 0] "
bit_blank_str:          .asciiz "[___] "
binary_line_tail:       .asciiz "|                 |\n"
render_binary_buffer:   .space 16

.text
.globl clear_screen
clear_screen:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    li $s0, 25
cs_loop:
    blez $s0, cs_done
    jal print_newline
    addiu $s0, $s0, -1
    j cs_loop

cs_done:
    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

.globl draw_board
draw_board:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    la $a0, border_line
    jal print_string
    jal draw_header
    la $a0, border_line
    jal print_string

    li $s0, 0

db_loop:
    lw $t0, num_puzzles
    bge $s0, $t0, db_done
    move $a0, $s0
    jal draw_puzzle_line
    addiu $s0, $s0, 1
    j db_loop

db_done:
    la $a0, border_line
    jal print_string

    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addiu $sp, $sp, 16
    jr $ra

.globl draw_header
draw_header:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    la $a0, header_level_prefix
    jal print_string
    lw $a0, current_level
    jal print_int
    la $a0, header_level_suffix
    jal print_string

    la $a0, header_score_prefix
    jal print_string
    jal get_score
    move $a0, $v0
    jal print_int
    la $a0, header_score_suffix
    jal print_string

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addiu $sp, $sp, 12
    jr $ra

.globl draw_puzzle_line
draw_puzzle_line:
    addiu $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)

    move $s0, $a0

    move $a0, $s0
    jal get_puzzle_type
    move $s1, $v0

    move $a0, $s0
    jal get_puzzle_value
    move $s2, $v0

    move $a0, $s0
    jal get_puzzle_status
    move $s3, $v0

    la $a0, border_line
    jal print_string

    la $a0, line_header_prefix
    jal print_string
    addiu $t0, $s0, 1
    move $a0, $t0
    jal print_int
    la $a0, line_header_suffix
    jal print_string

    beq $s1, $zero, dpl_type_bin_to_dec
    j dpl_type_dec_to_bin

dpl_type_bin_to_dec:
    la $a0, decimal_blank_suffix
    jal print_string
    j dpl_first_line_status

dpl_type_dec_to_bin:
    li $a0, '['
    jal print_char
    move $a0, $s2
    jal print_int
    la $a0, decimal_close_suffix
    jal print_string


dpl_first_line_status:
    li $t1, 1
    beq $s3, $t1, dpl_status_correct
    li $t1, 2
    beq $s3, $t1, dpl_status_incorrect
    la $a0, status_question_str
    jal print_string
    j dpl_second_line

dpl_status_correct:
    la $a0, status_correct_str
    jal print_string
    j dpl_second_line

dpl_status_incorrect:
    la $a0, status_incorrect_str
    jal print_string


dpl_second_line:
    la $a0, second_line_prefix
    jal print_string

    beq $s1, $zero, dpl_draw_binary_line
    j dpl_draw_decimal_binary

# Binary -> decimal puzzles (show bits)
dpl_draw_binary_line:
    li $t2, 7

bin_line_loop:
    bltz $t2, bin_line_done
    move $t3, $s2
    srlv $t4, $t3, $t2
    andi $t4, $t4, 1
    bnez $t4, bin_line_one
    la $a0, bit_zero_str
    jal print_string
    j bin_line_next

bin_line_one:
    la $a0, bit_one_str
    jal print_string

bin_line_next:
    addiu $t2, $t2, -1
    j bin_line_loop

bin_line_done:
    la $a0, decimal_line_prefix
    jal print_string
    beq $s3, $zero, dpl_decimal_blank
    li $a0, '['
    jal print_char
    move $a0, $s2
    jal print_int
    la $a0, decimal_close_suffix
    jal print_string
    jal print_newline
    j dpl_cleanup

dpl_decimal_blank:
    la $a0, decimal_blank_suffix
    jal print_string
    jal print_newline
    j dpl_cleanup

# Decimal -> binary puzzles (show boxes/binary)
dpl_draw_decimal_binary:
    beq $s3, $zero, dpl_draw_blank_boxes

    move $a0, $s2
    la $a1, render_binary_buffer
    jal int_to_binary_string

    li $t5, 0

dpl_binary_loop:
    bge $t5, 8, dpl_binary_done
    la $t8, render_binary_buffer
    add $t9, $t8, $t5
    lb $t0, 0($t9)
    beq $t0, '1', dpl_binary_one
    la $a0, bit_zero_str
    jal print_string
    j dpl_binary_next

dpl_binary_one:
    la $a0, bit_one_str
    jal print_string

dpl_binary_next:
    addiu $t5, $t5, 1
    j dpl_binary_loop

dpl_binary_done:
    la $a0, binary_line_tail
    jal print_string
    j dpl_cleanup


dpl_draw_blank_boxes:
    li $t5, 0

dpl_blank_loop:
    bge $t5, 8, dpl_blank_done
    la $a0, bit_blank_str
    jal print_string
    addiu $t5, $t5, 1
    j dpl_blank_loop

dpl_blank_done:
    la $a0, binary_line_tail
    jal print_string


dpl_cleanup:
    lw $ra, 32($sp)
    lw $s0, 28($sp)
    lw $s1, 24($sp)
    lw $s2, 20($sp)
    lw $s3, 16($sp)
    lw $s4, 12($sp)
    lw $s5, 8($sp)
    lw $s6, 4($sp)
    lw $s7, 0($sp)
    addiu $sp, $sp, 36
    jr $ra
