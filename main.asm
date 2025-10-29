# Main game loop for Binary Game in MIPS assembly

.data
    .globl max_level
    .globl current_level
    .globl total_score
    .globl game_state
    .globl title
    .globl prompt_decimal
    .globl prompt_binary
    .globl error_invalid
    .globl msg_correct
    .globl msg_incorrect
    .globl msg_level_up
    .globl msg_winner
    .globl msg_play_again
    .globl msg_final_score
    .globl msg_game_over
    .globl msg_correct_answer

max_level:      .word 10
current_level:  .word 1
total_score:    .word 0
game_state:     .word 0

title:          .asciiz "=== BINARY GAME ===\n\n"
prompt_decimal: .asciiz " - Enter decimal value (0-255): "
prompt_binary:  .asciiz " - Enter 8-bit binary (e.g., 10101010): "
error_invalid:  .asciiz "ERROR: Invalid input! Please try again.\n"
msg_correct:    .asciiz "\342\234\223 Correct!\n"
msg_incorrect:  .asciiz "\342\234\227 Incorrect!\n"
msg_level_up:   .asciiz "Level Complete!\n\n"
msg_winner:     .asciiz "YOU WIN! All levels completed!\n"
msg_play_again: .asciiz "Play again? (1=Yes, 0=No): "
msg_final_score:.asciiz "Final Score: "
msg_game_over:  .asciiz "Game Over. Better luck next time!\n"
msg_correct_answer: .asciiz "The correct answer was: "

.text
    .globl main

main:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)

    jal init_random_seed

main_loop:
    li  $t0, 1
    la  $t1, current_level
    sw  $t0, 0($t1)

    move $t0, $zero
    la  $t1, total_score
    sw  $t0, 0($t1)

    la  $t1, game_state
    sw  $t0, 0($t1)

    la  $a0, title
    jal print_string

    jal game_loop

    jal display_final

    jal play_again
    beq $v0, $zero, exit_game
    j   main_loop

exit_game:
    lw  $ra, 12($sp)
    lw  $s0, 8($sp)
    addiu $sp, $sp, 16

    li  $v0, 10
    syscall

# -------------------------------------------------------------------
# game_loop - manages levels until player wins or loses
# -------------------------------------------------------------------
    .globl game_loop
game_loop:
    addiu $sp, $sp, -40
    sw $ra, 36($sp)
    sw $s0, 32($sp)
    sw $s1, 28($sp)
    sw $s2, 24($sp)
    sw $s3, 20($sp)
    sw $s4, 16($sp)

level_loop:
    la  $t0, current_level
    lw  $s0, 0($t0)          # s0 = current level
    la  $t1, max_level
    lw  $t1, 0($t1)
    bgt $s0, $t1, player_won

    move $a0, $s0
    jal generate_puzzles

    jal clear_screen
    jal draw_board

    move $s1, $zero          # puzzle index

puzzle_loop:
    la  $t2, num_puzzles
    lw  $t2, 0($t2)
    bge $s1, $t2, level_complete

    move $a0, $s1
    jal get_puzzle_type
    move $s2, $v0            # puzzle type

    move $a0, $s1
    beq $s2, $zero, get_decimal_answer
    jal get_binary_input
    j   validate_puzzle

get_decimal_answer:
    jal get_decimal_input

validate_puzzle:
    move $s3, $v0            # store user answer
    move $a0, $s1
    move $a1, $s3
    jal check_puzzle_answer

    move $s4, $v1            # expected answer
    beq $v0, $zero, puzzle_incorrect

    la  $a0, msg_correct
    jal print_string

    jal clear_screen
    jal draw_board

    addiu $s1, $s1, 1
    j puzzle_loop

puzzle_incorrect:
    la  $a0, msg_incorrect
    jal print_string

    la  $a0, msg_correct_answer
    jal print_string

    move $a0, $s4
    jal print_int
    jal print_newline

    li  $t3, 2
    la  $t4, game_state
    sw  $t3, 0($t4)

    jal clear_screen
    jal draw_board

    j game_loop_exit

level_complete:
    move $a0, $s0
    move $a1, $zero          # no time bonus implemented
    jal calculate_score

    move $a0, $v0
    jal add_score

    la  $a0, msg_level_up
    jal print_string

    addiu $s0, $s0, 1
    la  $t0, current_level
    sw  $s0, 0($t0)

    la  $t1, max_level
    lw  $t1, 0($t1)
    ble $s0, $t1, continue_levels

player_won:
    li  $t2, 1
    la  $t3, game_state
    sw  $t2, 0($t3)
    j game_loop_exit

continue_levels:
    jal clear_screen
    jal draw_board
    j level_loop

game_loop_exit:
    lw $ra, 36($sp)
    lw $s0, 32($sp)
    lw $s1, 28($sp)
    lw $s2, 24($sp)
    lw $s3, 20($sp)
    lw $s4, 16($sp)
    addiu $sp, $sp, 40
    jr $ra

# -------------------------------------------------------------------
# display_final - prints the outcome and final score
# -------------------------------------------------------------------
    .globl display_final
display_final:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)

    la  $a0, msg_final_score
    jal print_string

    la  $t0, total_score
    lw  $a0, 0($t0)
    jal print_int
    jal print_newline

    la  $t1, game_state
    lw  $t1, 0($t1)
    beq $t1, 1, final_winner
    beq $t1, 2, final_loser

    j display_final_exit

final_winner:
    la  $a0, msg_winner
    jal print_string
    j display_final_exit

final_loser:
    la  $a0, msg_game_over
    jal print_string

    j display_final_exit

display_final_exit:
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    addiu $sp, $sp, 16
    jr $ra

# -------------------------------------------------------------------
# play_again - prompts the user to replay the game
# Returns: $v0 = 1 (yes) or 0 (no)
# -------------------------------------------------------------------
    .globl play_again
play_again:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)

play_again_prompt:
    la  $a0, msg_play_again
    jal print_string

    jal read_integer
    move $s0, $v0

    li  $t0, 1
    beq $s0, $zero, play_again_valid
    beq $s0, $t0, play_again_valid

    la  $a0, error_invalid
    jal print_string
    j   play_again_prompt

play_again_valid:
    move $v0, $s0

    lw $ra, 12($sp)
    lw $s0, 8($sp)
    addiu $sp, $sp, 16
    jr $ra
