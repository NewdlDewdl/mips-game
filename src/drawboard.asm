# Game board rendering module

.set noreorder

.data
    .align 2
    border_line:       .asciiz "+------------------------------------------------------------------+\n"
    header_title_pre:  .asciiz "|                    BINARY GAME - LEVEL "
    header_title_suf:  .asciiz "                         |\n"
    header_score_pre:  .asciiz "|                        SCORE: "
    header_score_suf:  .asciiz "                                |\n"
    header_blank:      .asciiz "+------------------------------------------------------------------+\n"
    line_prefix:       .asciiz "| Line "
    line_header_tail:  .asciiz ": [128] [64] [32] [16] [8] [4] [2] [1] | Decimal: "
    line_indent:       .asciiz "|         "
    answer_label:      .asciiz " | Target: "
    status_bar_end:    .asciiz " |"
    status_check:      .asciiz " ✓"
    status_cross:      .asciiz " ✗"
    status_unknown:    .asciiz " ?"
    blank_binary_box:  .asciiz "[___] "
    decimal_blank_full:.asciiz "[___] "
    bracket_open:      .asciiz "["
    bracket_close_sp:  .asciiz "] "
    space_str:         .asciiz " "
    clear_code:        .asciiz "\033[2J\033[H"
    value_buffer:      .space 16

.text
    .globl clear_screen
clear_screen:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)

    la $a0, clear_code
    jal print_string

    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl draw_board
draw_board:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)

    la $a0, border_line
    jal print_string

    jal draw_header

    la $a0, header_blank
    jal print_string

    li $s0, 0

board_loop:
    lw $t0, num_puzzles
    bge $s0, $t0, board_done

    move $a0, $s0
    jal draw_puzzle_line

    addiu $s0, $s0, 1
    j board_loop

board_done:
    la $a0, border_line
    jal print_string

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    addiu $sp, $sp, 20
    jr $ra

    .globl draw_header
draw_header:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)

    la $a0, header_title_pre
    jal print_string

    lw $s0, current_level
    move $a0, $s0
    jal print_int

    la $a0, header_title_suf
    jal print_string

    la $a0, header_score_pre
    jal print_string

    lw $s1, total_score
    move $a0, $s1
    jal print_int

    la $a0, header_score_suf
    jal print_string

    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl draw_puzzle_line
draw_puzzle_line:
    # $a0 = puzzle index
    addiu $sp, $sp, -44
    sw $ra, 40($sp)
    sw $s0, 36($sp)
    sw $s1, 32($sp)
    sw $s2, 28($sp)
    sw $s3, 24($sp)
    sw $s4, 20($sp)
    sw $s5, 16($sp)
    sw $s6, 12($sp)
    sw $s7, 8($sp)

    move $s0, $a0

    # Get type, value, status
    move $a0, $s0
    jal get_puzzle_type
    move $s1, $v0

    move $a0, $s0
    jal get_puzzle_value
    move $s2, $v0

    move $a0, $s0
    jal get_puzzle_status
    move $s3, $v0

    # Separator line
    la $a0, border_line
    jal print_string

    # First line
    la $a0, line_prefix
    jal print_string

    addiu $s4, $s0, 1
    move $a0, $s4
    jal print_int

    la $a0, line_header_tail
    jal print_string

    # Determine decimal visibility
    li $s5, 0
    beq $s1, $zero, decimal_flag_check
    li $s5, 1
    j decimal_render

decimal_flag_check:
    beq $s3, $zero, decimal_render
    li $s5, 1

decimal_render:
    move $a0, $s2
    move $a1, $s5
    jal draw_decimal_box

    la $a0, status_bar_end
    jal print_string

    jal print_newline

    # Second line
    la $a0, line_indent
    jal print_string

    beq $s1, $zero, draw_binary_type0

    # Type 1: decimal -> binary
    beq $s3, $zero, draw_blank_binary
    move $a0, $s2
    jal draw_binary_boxes
    j after_binary

draw_blank_binary:
    jal draw_blank_binary_boxes
    j after_binary

draw_binary_type0:
    move $a0, $s2
    jal draw_binary_boxes

after_binary:
    la $a0, answer_label
    jal print_string

    beq $s1, $zero, draw_target_for_binary

    # Type 1 target (decimal reference)
    move $a0, $s2
    jal draw_decimal_box_value_only
    j after_target_output

draw_target_for_binary:
    beq $s3, $zero, draw_target_placeholder
    move $a0, $s2
    jal draw_decimal_box_value_only
    j after_target_output

draw_target_placeholder:
    la $a0, decimal_blank_full
    jal print_string

after_target_output:
    la $a0, status_bar_end
    jal print_string

    move $a0, $s3
    jal draw_status_indicator

    jal print_newline

    lw $ra, 40($sp)
    lw $s0, 36($sp)
    lw $s1, 32($sp)
    lw $s2, 28($sp)
    lw $s3, 24($sp)
    lw $s4, 20($sp)
    lw $s5, 16($sp)
    lw $s6, 12($sp)
    lw $s7, 8($sp)
    addiu $sp, $sp, 44
    jr $ra

    .globl draw_status_indicator
draw_status_indicator:
    # $a0 = status
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    beq $a0, $zero, status_unknown_case
    li $t0, 1
    beq $a0, $t0, status_correct_case
    li $t1, 2
    beq $a0, $t1, status_incorrect_case

status_unknown_case:
    la $a0, status_unknown
    jal print_string
    j status_done

status_correct_case:
    la $a0, status_check
    jal print_string
    j status_done

status_incorrect_case:
    la $a0, status_cross
    jal print_string

status_done:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl draw_decimal_box
draw_decimal_box:
    # $a0 = value, $a1 = show flag
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)

    move $s0, $a0
    move $s1, $a1

    beq $s1, $zero, draw_decimal_placeholder
    move $a0, $s0
    jal print_value_bracketed
    j draw_decimal_finish

draw_decimal_placeholder:
    la $a0, decimal_blank_full
    jal print_string

    j draw_decimal_finish

draw_decimal_finish:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    addiu $sp, $sp, 20
    jr $ra

    .globl draw_decimal_box_value_only
draw_decimal_box_value_only:
    # $a0 = value
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    move $s0, $a0
    jal print_value_bracketed

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl draw_blank_binary_boxes
draw_blank_binary_boxes:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    li $s0, 0
blank_box_loop:
    li $t0, 8
    bge $s0, $t0, blank_box_done
    la $a0, blank_binary_box
    jal print_string
    addiu $s0, $s0, 1
    j blank_box_loop

blank_box_done:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl draw_binary_boxes
draw_binary_boxes:
    # $a0 = value
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)

    move $s0, $a0
    li $s1, 7

binary_loop:
    bltz $s1, binary_done
    move $t0, $s0
    move $t1, $s1
    srlv $t0, $t0, $t1
    andi $t0, $t0, 1

    move $a0, $t0
    jal print_value_bracketed

    addiu $s1, $s1, -1
    j binary_loop

binary_done:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    addiu $sp, $sp, 24
    jr $ra

    .globl print_value_bracketed
print_value_bracketed:
    # $a0 = value to print inside brackets (width 3)
    addiu $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)

    move $s0, $a0
    la $a1, value_buffer
    jal int_to_string

    la $a0, value_buffer
    jal string_length
    move $s1, $v0          # length

    li $s2, 3              # width
    subu $s3, $s2, $s1
    bltz $s3, no_padding

    la $a0, bracket_open
    jal print_string

print_padding_loop:
    blez $s3, padding_done
    la $a0, space_str
    jal print_string
    addiu $s3, $s3, -1
    j print_padding_loop

padding_done:
    la $a0, value_buffer
    jal print_string

    la $a0, bracket_close_sp
    jal print_string

    j bracket_done

no_padding:
    la $a0, bracket_open
    jal print_string

    la $a0, value_buffer
    jal print_string

    la $a0, bracket_close_sp
    jal print_string

bracket_done:
    lw $ra, 32($sp)
    lw $s0, 28($sp)
    lw $s1, 24($sp)
    lw $s2, 20($sp)
    lw $s3, 16($sp)
    addiu $sp, $sp, 36
    jr $ra
