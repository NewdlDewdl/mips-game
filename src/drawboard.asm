# -------------------------------------------------------------
# drawboard.asm - Board rendering routines
# -------------------------------------------------------------

        .text
        .globl draw_board
        .globl draw_header
        .globl draw_puzzle_line
        .globl draw_binary_boxes
        .globl draw_decimal_box
        .globl clear_screen

        .extern puzzles
        .extern num_puzzles
        .extern current_level
        .extern total_score
        .extern header_border
        .extern header_title_prefix
        .extern header_title_suffix
        .extern header_score_prefix
        .extern header_score_suffix
        .extern line_prefix
        .extern line_mid
        .extern line_indent
        .extern decimal_blank
        .extern decimal_box
        .extern decimal_value_prefix
        .extern status_unknown
        .extern status_correct
        .extern status_incorrect
        .extern binary_blank_box
        .extern binary_zero_box
        .extern binary_one_box
        .extern separator_line
        .extern clear_screen_seq

        .extern print_string
        .extern print_int
        .extern print_newline

PUZZLE_STRIDE   = 8
TYPE_OFFSET     = 0
STATUS_OFFSET   = 1
VALUE_OFFSET    = 4

clear_screen:
        la      $a0, clear_screen_seq
        jal     print_string
        jr      $ra

draw_board:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        jal     draw_header
        lw      $t0, num_puzzles
        li      $t1, 0
1:
        bge     $t1, $t0, 2f
        la      $a0, separator_line
        jal     print_string
        move    $a0, $t1
        jal     draw_puzzle_line
        addiu   $t1, $t1, 1
        j       1b
2:
        la      $a0, separator_line
        jal     print_string
        lw      $ra, 12($sp)
        addiu   $sp, $sp, 16
        jr      $ra

draw_header:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        la      $a0, header_border
        jal     print_string
        la      $a0, header_title_prefix
        jal     print_string
        lw      $a0, current_level
        jal     print_int
        la      $a0, header_title_suffix
        jal     print_string
        la      $a0, header_score_prefix
        jal     print_string
        lw      $a0, total_score
        jal     print_int
        la      $a0, header_score_suffix
        jal     print_string
        la      $a0, header_border
        jal     print_string
        lw      $ra, 12($sp)
        addiu   $sp, $sp, 16
        jr      $ra

draw_puzzle_line:
        addiu   $sp, $sp, -32
        sw      $ra, 28($sp)
        sw      $s0, 24($sp)
        sw      $s1, 20($sp)
        sw      $s2, 16($sp)
        move    $s0, $a0
        la      $t0, puzzles
        mul     $t1, $s0, PUZZLE_STRIDE
        addu    $s1, $t0, $t1
        lbu     $s2, TYPE_OFFSET($s1)
        lbu     $t2, STATUS_OFFSET($s1)
        lw      $t3, VALUE_OFFSET($s1)

        # First line header
        la      $a0, line_prefix
        jal     print_string
        addiu   $a0, $s0, 1
        jal     print_int
        la      $a0, line_mid
        jal     print_string
        beq     $s2, $zero, 1f
        # decimal visible
        la      $a0, decimal_value_prefix
        jal     print_string
        move    $a0, $t3
        jal     print_int
        la      $a0, decimal_box
        jal     print_string
        j       2f
1:
        la      $a0, decimal_blank
        jal     print_string
2:
        jal     print_newline

        # Second line with binary info
        la      $a0, line_indent
        jal     print_string
        beq     $s2, $zero, 3f
        # Decimal -> binary: draw blanks
        li      $t4, 8
        li      $t5, 0
4:
        beq     $t5, $t4, 5f
        la      $a0, binary_blank_box
        jal     print_string
        addiu   $t5, $t5, 1
        j       4b
5:
        la      $a0, decimal_blank
        jal     print_string
        j       6f
3:
        move    $a0, $t3
        li      $a1, 1
        jal     draw_binary_boxes
        la      $a0, decimal_value_prefix
        jal     print_string
        move    $a0, $t3
        jal     print_int
        la      $a0, decimal_box
        jal     print_string
6:
        # Status indicator
        beq     $t2, $zero, 7f
        li      $t6, 1
        beq     $t2, $t6, 8f
        la      $a0, status_incorrect
        jal     print_string
        j       9f
8:
        la      $a0, status_correct
        jal     print_string
        j       9f
7:
        la      $a0, status_unknown
        jal     print_string
9:
        jal     print_newline

        lw      $ra, 28($sp)
        lw      $s0, 24($sp)
        lw      $s1, 20($sp)
        lw      $s2, 16($sp)
        addiu   $sp, $sp, 32
        jr      $ra

draw_binary_boxes:
        # $a0 = value, $a1 = show_value flag
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)
        sw      $s0, 16($sp)
        sw      $s1, 12($sp)
        move    $s0, $a0
        move    $s1, $a1
        li      $t0, 7
1:
        bltz    $t0, 3f
        beq     $s1, $zero, 2f
        move    $t1, $s0
        srlv    $t1, $t1, $t0
        andi    $t1, $t1, 1
        beq     $t1, $zero, 4f
        la      $a0, binary_one_box
        jal     print_string
        j       5f
4:
        la      $a0, binary_zero_box
        jal     print_string
        j       5f
2:
        la      $a0, binary_blank_box
        jal     print_string
5:
        addiu   $t0, $t0, -1
        j       1b
3:
        lw      $ra, 20($sp)
        lw      $s0, 16($sp)
        lw      $s1, 12($sp)
        addiu   $sp, $sp, 24
        jr      $ra

draw_decimal_box:
        # $a0 = value, $a1 = show flag
        beq     $a1, $zero, 1f
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $a0, 8($sp)
        la      $a0, decimal_value_prefix
        jal     print_string
        lw      $a0, 8($sp)
        jal     print_int
        la      $a0, decimal_box
        jal     print_string
        lw      $ra, 12($sp)
        addiu   $sp, $sp, 16
        jr      $ra
1:
        la      $a0, decimal_blank
        jal     print_string
        jr      $ra
