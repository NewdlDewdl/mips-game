# Rendering routines for the Binary Game board

.data
    board_border:        .asciiz "+------------------------------------------------------------------+\n"
    header_level_prefix: .asciiz "| BINARY GAME - LEVEL "
    header_score_prefix: .asciiz "| SCORE: "
    header_line_suffix:  .asciiz " |\n"
    line_prefix:         .asciiz "| Line "
    line_header_mid:     .asciiz ": [128] [64] [32] [16] [8] [4] [2] [1] | Decimal: "
    line_first_end:      .asciiz " |\n"
    line_second_prefix:  .asciiz "|         "
    line_answer_label:   .asciiz " |  Answer: "
    line_binary_label:   .asciiz " |  Binary: "
    status_separator:    .asciiz " | "
    status_correct:      .asciiz "\342\234\223\n"
    status_incorrect:    .asciiz "\342\234\227\n"
    status_pending:      .asciiz "?\n"
    decimal_blank_box:   .asciiz "[___] "
    answer_placeholder:  .asciiz "[???] "
    binary_placeholder:  .asciiz "[????????] "
    binary_one_box:      .asciiz "[ 1] "
    binary_zero_box:     .asciiz "[ 0] "
    binary_blank_box:    .asciiz "[___] "

    .align 2
binary_display_buffer: .space 16

.text
    .globl draw_board
draw_board:
    addiu $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)

    jal draw_header

    move $s0, $zero

board_line_loop:
    la  $t0, num_puzzles
    lw  $t0, 0($t0)
    bge $s0, $t0, draw_board_finish

    move $a0, $s0
    jal draw_puzzle_line

    addiu $s0, $s0, 1
    j board_line_loop

draw_board_finish:
    la  $a0, board_border
    jal print_string

    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    addiu $sp, $sp, 32
    jr $ra

    .globl draw_header
draw_header:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)

    la  $a0, board_border
    jal print_string

    la  $a0, header_level_prefix
    jal print_string

    la  $t0, current_level
    lw  $a0, 0($t0)
    jal print_int

    la  $a0, header_line_suffix
    jal print_string

    la  $a0, header_score_prefix
    jal print_string

    la  $t1, total_score
    lw  $a0, 0($t1)
    jal print_int

    la  $a0, header_line_suffix
    jal print_string

    la  $a0, board_border
    jal print_string

    lw $ra, 20($sp)
    addiu $sp, $sp, 24
    jr $ra

    .globl draw_puzzle_line
draw_puzzle_line:
    addiu $sp, $sp, -56
    sw $ra, 52($sp)
    sw $s0, 48($sp)
    sw $s1, 44($sp)
    sw $s2, 40($sp)
    sw $s3, 36($sp)

    move $s0, $a0

    la  $a0, board_border
    jal print_string

    la  $a0, line_prefix
    jal print_string

    addiu $a0, $s0, 1
    jal print_int

    la  $a0, line_header_mid
    jal print_string

    move $a0, $s0
    jal get_puzzle_type
    move $s1, $v0

    move $a0, $s0
    jal get_puzzle_value
    move $s2, $v0

    move $a0, $s0
    jal get_puzzle_status
    move $s3, $v0

    move $a0, $s2
    li   $a1, 0
    bne  $s1, $zero, draw_decimal_actual
    jal draw_decimal_box
    j draw_first_row_end

draw_decimal_actual:
    li  $a1, 1
    jal draw_decimal_box

draw_first_row_end:
    la  $a0, line_first_end
    jal print_string

    la  $a0, line_second_prefix
    jal print_string

    move $a0, $s2
    li   $a1, 1
    beq  $s1, $zero, draw_binary_bits
    li   $a1, 0
    li   $t0, 1
    beq  $s3, $t0, draw_binary_show_solution
    
draw_binary_bits:
    jal draw_binary_boxes

    beq $s1, $zero, draw_decimal_answer_section
    j   after_binary_boxes

draw_binary_show_solution:
    li  $a1, 1
    jal draw_binary_boxes
    beq $s1, $zero, draw_decimal_answer_section
    j   after_binary_boxes

after_binary_boxes:

    la  $a0, line_binary_label
    jal print_string

    li  $t0, 1
    bne $s3, $t0, draw_binary_answer_placeholder

    move $a0, $s2
    la   $a1, binary_display_buffer
    jal int_to_binary_string

    li  $a0, '['
    jal print_char
    la  $a0, binary_display_buffer
    jal print_string
    li  $a0, ']'
    jal print_char
    li  $a0, ' '
    jal print_char
    j   draw_status_output

draw_binary_answer_placeholder:
    la  $a0, binary_placeholder
    jal print_string
    j   draw_status_output

# Binary -> Decimal branch

draw_decimal_answer_section:
    la  $a0, line_answer_label
    jal print_string

    li  $t0, 1
    bne $s3, $t0, draw_decimal_answer_placeholder

    move $a0, $s2
    li   $a1, 1
    jal draw_decimal_box
    j   draw_status_output

draw_decimal_answer_placeholder:
    la  $a0, answer_placeholder
    jal print_string

# Status output
draw_status_output:
    la  $a0, status_separator
    jal print_string

    li  $t0, 1
    beq $s3, $t0, status_correct_label
    li  $t1, 2
    beq $s3, $t1, status_incorrect_label
    la  $a0, status_pending
    jal print_string
    j   draw_puzzle_line_exit

status_correct_label:
    la  $a0, status_correct
    jal print_string
    j   draw_puzzle_line_exit

status_incorrect_label:
    la  $a0, status_incorrect
    jal print_string

# Exit draw_puzzle_line
draw_puzzle_line_exit:
    lw $ra, 52($sp)
    lw $s0, 48($sp)
    lw $s1, 44($sp)
    lw $s2, 40($sp)
    lw $s3, 36($sp)
    addiu $sp, $sp, 56
    jr $ra

    .globl draw_decimal_box
draw_decimal_box:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)

    move $s0, $a0
    beq $a1, $zero, draw_decimal_blank_box

    li  $a0, '['
    jal print_char

    move $a0, $s0
    jal print_int

    li  $a0, ']'
    jal print_char

    li  $a0, ' '
    jal print_char
    j draw_decimal_box_exit

draw_decimal_blank_box:
    la  $a0, decimal_blank_box
    jal print_string


draw_decimal_box_exit:
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl draw_binary_boxes
draw_binary_boxes:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)

    move $s0, $a0
    move $s1, $a1

    li  $t0, 7

draw_binary_loop:
    bltz $t0, draw_binary_exit
    beq $s1, $zero, draw_binary_blank
    srlv $t1, $s0, $t0
    andi $t1, $t1, 1
    bnez $t1, draw_binary_one
    la  $a0, binary_zero_box
    jal print_string
    j   draw_binary_next

draw_binary_one:
    la  $a0, binary_one_box
    jal print_string
    j   draw_binary_next

draw_binary_blank:
    la  $a0, binary_blank_box
    jal print_string


draw_binary_next:
    addiu $t0, $t0, -1
    j draw_binary_loop

draw_binary_exit:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    addiu $sp, $sp, 24
    jr $ra

    .globl clear_screen
clear_screen:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)

    li  $s0, 30

clear_screen_loop:
    blez $s0, clear_screen_exit
    jal print_newline
    addiu $s0, $s0, -1
    j clear_screen_loop

clear_screen_exit:
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    addiu $sp, $sp, 16
    jr $ra
