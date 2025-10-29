# -------------------------------------------------------------
# main.asm - Main entry point and game loop for Binary Game
# -------------------------------------------------------------

        .text
        .globl main
        .globl game_loop
        .globl play_again

        .extern init_random_seed
        .extern generate_puzzles
        .extern get_puzzle_type
        .extern get_decimal_input
        .extern get_binary_input
        .extern check_puzzle_answer
        .extern clear_screen
        .extern draw_board
        .extern print_string
        .extern print_int
        .extern print_newline
        .extern calculate_score
        .extern add_score
        .extern get_score
        .extern display_score
        .extern read_integer

main:
        jal     init_random_seed
start_game:
        jal     reset_game_state
        jal     clear_screen
        la      $a0, title
        jal     print_string
        jal     game_loop
        jal     display_final_message
        jal     play_again
        beq     $v0, $zero, exit_program
        j       start_game

exit_program:
        li      $v0, 10
        syscall

# -------------------------------------------------------------
# game_loop - manages levels and puzzle iteration
# -------------------------------------------------------------
game_loop:
        addiu   $sp, $sp, -32
        sw      $ra, 28($sp)
        sw      $s0, 24($sp)
        sw      $s1, 20($sp)
        sw      $s2, 16($sp)
loop_levels:
        lw      $s0, current_level
        lw      $t0, max_level
        bgt     $s0, $t0, win_condition
        li      $t1, 0
        sw      $t1, game_state
        move    $a0, $s0
        jal     generate_puzzles
        jal     clear_screen
        jal     draw_board
        li      $s1, 0
puzzle_loop:
        lw      $t2, num_puzzles
        bge     $s1, $t2, level_complete
        move    $a0, $s1
        jal     get_puzzle_type
        move    $s2, $v0
        beq     $s2, $zero, read_decimal
        move    $a0, $s1
        jal     get_binary_input
        move    $t3, $v0
        j       check_current_answer
read_decimal:
        move    $a0, $s1
        jal     get_decimal_input
        move    $t3, $v0
check_current_answer:
        move    $a0, $s1
        move    $a1, $t3
        jal     check_puzzle_answer
        beq     $v0, 1, puzzle_correct
        li      $t4, 2
        sw      $t4, game_state
        jal     clear_screen
        jal     draw_board
        la      $a0, msg_incorrect
        jal     print_string
        j       end_loop
puzzle_correct:
        addiu   $s1, $s1, 1
        jal     clear_screen
        jal     draw_board
        la      $a0, msg_correct
        jal     print_string
        j       puzzle_loop

level_complete:
        move    $a0, $s0
        move    $a1, $zero
        jal     calculate_score
        move    $a0, $v0
        jal     add_score
        lw      $t5, current_level
        addiu   $t5, $t5, 1
        sw      $t5, current_level
        jal     clear_screen
        jal     draw_board
        la      $a0, msg_level_up
        jal     print_string
        j       loop_levels

win_condition:
        li      $t6, 1
        sw      $t6, game_state
end_loop:
        lw      $ra, 28($sp)
        lw      $s0, 24($sp)
        lw      $s1, 20($sp)
        lw      $s2, 16($sp)
        addiu   $sp, $sp, 32
        jr      $ra

# -------------------------------------------------------------
# display_final_message - prints win/lose messages and score
# -------------------------------------------------------------
display_final_message:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        lw      $t0, game_state
        li      $t1, 1
        beq     $t0, $t1, won_message
        la      $a0, msg_game_over
        jal     print_string
        jal     get_score
        move    $a0, $v0
        jal     print_int
        jal     print_newline
        j       finish_display
won_message:
        la      $a0, msg_winner
        jal     print_string
        jal     display_score
finish_display:
        lw      $ra, 12($sp)
        addiu   $sp, $sp, 16
        jr      $ra

# -------------------------------------------------------------
# play_again - prompts for replay
# -------------------------------------------------------------
play_again:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        la      $a0, msg_play_again
        jal     print_string
        jal     read_integer
        li      $t0, 1
        beq     $v0, $t0, 1f
        move    $v0, $zero
        j       2f
1:
        li      $v0, 1
2:
        lw      $ra, 12($sp)
        addiu   $sp, $sp, 16
        jr      $ra

# -------------------------------------------------------------
# reset_game_state - helper to reset variables
# -------------------------------------------------------------
reset_game_state:
        li      $t0, 1
        sw      $t0, current_level
        sw      $zero, total_score
        sw      $zero, game_state
        sw      $zero, num_puzzles
        jr      $ra

# -------------------------------------------------------------
# display_final_message reference label and other data
# -------------------------------------------------------------

        .data
        .align  2
        .globl max_level
max_level:      .word 10
        .globl current_level
current_level:  .word 1
        .globl total_score
total_score:    .word 0
        .globl game_state
game_state:     .word 0
        .globl puzzles
puzzles:        .space 80
        .globl num_puzzles
num_puzzles:    .word 0

# Display strings
        .globl clear_screen_seq
clear_screen_seq:       .asciiz "\033[2J\033[H"
        .globl header_border
header_border:          .asciiz "+------------------------------------------------------------------+\n"
        .globl header_title_prefix
header_title_prefix:    .asciiz "|                    BINARY GAME - LEVEL "
        .globl header_title_suffix
header_title_suffix:    .asciiz "                         |\n"
        .globl header_score_prefix
header_score_prefix:    .asciiz "|                        SCORE: "
        .globl header_score_suffix
header_score_suffix:    .asciiz "                               |\n"
        .globl line_prefix
line_prefix:            .asciiz "| Line "
        .globl line_mid
line_mid:               .asciiz ": [128] [64] [32] [16] [8] [4] [2] [1] | Decimal: "
        .globl line_indent
line_indent:            .asciiz "|         "
        .globl decimal_blank
decimal_blank:          .asciiz "[___]  | "
        .globl decimal_value_prefix
decimal_value_prefix:   .asciiz "["
        .globl decimal_box
decimal_box:            .asciiz "]  | "
        .globl binary_blank_box
binary_blank_box:       .asciiz "[___] "
        .globl binary_zero_box
binary_zero_box:        .asciiz "[ 0] "
        .globl binary_one_box
binary_one_box:         .asciiz "[ 1] "
        .globl separator_line
separator_line:         .asciiz "+------------------------------------------------------------------+\n"
        .globl status_unknown
status_unknown:         .asciiz " ?"
        .globl status_correct
status_correct:         .asciiz " OK"
        .globl status_incorrect
status_incorrect:       .asciiz " XX"
        .globl score_label
score_label:            .asciiz "Current Score: "
        .globl prompt_line_prefix
prompt_line_prefix:     .asciiz "Line "
        .globl prompt_line_separator
prompt_line_separator:  .asciiz " - "
        .globl prompt_decimal
prompt_decimal:         .asciiz "Enter decimal value (0-255): "
        .globl prompt_binary
prompt_binary:          .asciiz "Enter 8-bit binary (e.g., 10101010): "
        .globl error_invalid
error_invalid:          .asciiz "Invalid input! Try again.\n"
        .globl msg_correct
msg_correct:            .asciiz "Correct!\n"
        .globl msg_incorrect
msg_incorrect:          .asciiz "Incorrect. Game Over!\n"
        .globl msg_level_up
msg_level_up:           .asciiz "Level Complete!\n"
        .globl msg_winner
msg_winner:             .asciiz "YOU WIN! All levels completed!\n"
        .globl msg_game_over
msg_game_over:          .asciiz "GAME OVER - Final Score: "
        .globl msg_play_again
msg_play_again:         .asciiz "Play again? (1=Yes, 0=No): "
        .globl title
title:                  .asciiz "=== BINARY GAME ===\n"
