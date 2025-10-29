# Main module for Binary Game

.data
.align 2
.globl max_level
max_level:      .word 10
.globl current_level
current_level:  .word 1
.globl total_score
total_score:    .word 0
.globl game_state
game_state:     .word 0

title_string:           .asciiz "=== BINARY GAME ===\n"
msg_correct:            .asciiz "\xE2\x9C\x93 Correct!\n"
msg_incorrect:          .asciiz "\xE2\x9C\x97 Incorrect!\n"
msg_correct_answer:     .asciiz "The correct answer was: "
msg_level_up:           .asciiz "Level Complete!\n"
msg_winner:             .asciiz "YOU WIN! All levels completed!\n"
msg_game_over:          .asciiz "GAME OVER - Final Score: "
msg_final_score:        .asciiz "Final Score: "
msg_play_again:         .asciiz "Play again? (1=Yes, 0=No): "
msg_goodbye:            .asciiz "Thanks for playing!\n"

.text
.globl main
main:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    jal init_random_seed

main_restart:
    li $t0, 1
    sw $t0, current_level
    sw $zero, total_score
    sw $zero, game_state

    jal clear_screen
    la $a0, title_string
    jal print_string

    jal game_loop

    lw $t0, game_state
    li $t1, 1
    beq $t0, $t1, main_victory
    li $t1, 2
    beq $t0, $t1, main_failure
    j main_post_result

main_victory:
    la $a0, msg_winner
    jal print_string
    la $a0, msg_final_score
    jal print_string
    jal get_score
    move $a0, $v0
    jal print_int
    jal print_newline
    j main_post_result

main_failure:
    la $a0, msg_game_over
    jal print_string
    jal get_score
    move $a0, $v0
    jal print_int
    jal print_newline

main_post_result:
    jal print_newline
    jal play_again
    move $s0, $v0
    li $t2, 1
    beq $s0, $t2, main_restart

    la $a0, msg_goodbye
    jal print_string

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addiu $sp, $sp, 20

    # Exit program properly
    li $v0, 10
    syscall

.globl game_loop
game_loop:
    addiu $sp, $sp, -48
    sw $ra, 44($sp)
    sw $s0, 40($sp)
    sw $s1, 36($sp)
    sw $s2, 32($sp)
    sw $s3, 28($sp)
    sw $s4, 24($sp)
    sw $s5, 20($sp)
    sw $s6, 16($sp)
    sw $s7, 12($sp)
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)

gl_loop_start:
    lw $t0, game_state
    bne $t0, $zero, gl_exit

    lw $s4, current_level
    lw $t1, max_level
    bgt $s4, $t1, gl_set_win

    move $a0, $s4
    jal generate_puzzles

    jal clear_screen
    jal draw_board

    li $s1, 0              # puzzle index

gl_puzzle_loop:
    lw $t2, num_puzzles
    bge $s1, $t2, gl_level_complete

    move $a0, $s1
    jal get_puzzle_type
    move $s2, $v0

    beq $s2, $zero, gl_prompt_decimal
    j gl_prompt_binary

gl_prompt_decimal:
    move $a0, $s1
    jal get_decimal_input
    move $s3, $v0
    j gl_validate_answer

gl_prompt_binary:
    move $a0, $s1
    jal get_binary_input
    move $s3, $v0


gl_validate_answer:
    move $a0, $s1
    move $a1, $s3
    jal check_puzzle_answer
    beq $v0, 1, gl_answer_correct

    move $a0, $s1
    jal get_correct_answer_string
    move $s5, $v0

    jal clear_screen
    jal draw_board
    la $a0, msg_incorrect
    jal print_string
    la $a0, msg_correct_answer
    jal print_string
    move $a0, $s5
    jal print_string
    jal print_newline

    li $t0, 2
    sw $t0, game_state
    j gl_exit


gl_answer_correct:
    jal clear_screen
    jal draw_board
    la $a0, msg_correct
    jal print_string
    addiu $s1, $s1, 1
    j gl_puzzle_loop


gl_level_complete:
    move $a0, $s4
    move $a1, $zero
    jal calculate_score
    move $a0, $v0
    jal add_score
    la $a0, msg_level_up
    jal print_string
    lw $t0, current_level
    addiu $t0, $t0, 1
    sw $t0, current_level
    j gl_loop_start


gl_set_win:
    li $t0, 1
    sw $t0, game_state


gl_exit:
    lw $ra, 44($sp)
    lw $s0, 40($sp)
    lw $s1, 36($sp)
    lw $s2, 32($sp)
    lw $s3, 28($sp)
    lw $s4, 24($sp)
    lw $s5, 20($sp)
    lw $s6, 16($sp)
    lw $s7, 12($sp)
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addiu $sp, $sp, 48
    jr $ra

.globl play_again
play_again:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    la $a0, msg_play_again
    jal print_string
    jal read_integer
    move $s0, $v0
    jal print_newline
    move $v0, $s0

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addiu $sp, $sp, 12
    jr $ra
