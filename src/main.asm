# Main game loop and orchestration

.set noreorder

.data
    .align 2
    .globl max_level
max_level:      .word 10
    .globl current_level
current_level:  .word 1
    .globl total_score
total_score:    .word 0
    .globl game_state
game_state:     .word 0          # 0=playing, 1=won, 2=lost

    title_banner:      .asciiz "=== BINARY GAME ===\n"
    title_message:     .asciiz "Convert between binary and decimal to climb all 10 levels!\n"
    msg_start:         .asciiz "Good luck!\n\n"
    msg_correct:       .asciiz "\n✓ Correct!\n"
    msg_incorrect:     .asciiz "\n✗ Incorrect! The answer is displayed on the board.\n"
    msg_level_up:      .asciiz "\nLevel Complete!\n"
    msg_winner:        .asciiz "\nYOU WIN! All levels completed!\n"
    msg_game_over:     .asciiz "\nGAME OVER! Better luck next time.\n"
    msg_final_score:   .asciiz "Final Score: "
    msg_play_again:    .asciiz "Play again? (1=Yes, 0=No): "
    msg_invalid_choice:.asciiz "Please enter 1 or 0.\n"

.text
    .globl main
main:
    addiu $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)

    jal init_random_seed

main_restart:
    jal initialize_game
    jal show_title_screen
    jal game_loop
    jal display_final_result

    jal play_again
    move $s0, $v0
    beqz $s0, main_exit
    j main_restart

main_exit:
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    addiu $sp, $sp, 32

    li $v0, 10
    syscall

    .globl initialize_game
initialize_game:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)

    li $t0, 1
    sw $t0, current_level
    sw $zero, total_score
    sw $zero, game_state

    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl show_title_screen
show_title_screen:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    jal clear_screen

    la $a0, title_banner
    jal print_string

    la $a0, title_message
    jal print_string

    la $a0, msg_start
    jal print_string

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl game_loop
game_loop:
    addiu $sp, $sp, -40
    sw $ra, 36($sp)
    sw $s0, 32($sp)
    sw $s1, 28($sp)
    sw $s2, 24($sp)
    sw $s3, 20($sp)
    sw $s4, 16($sp)
    sw $s5, 12($sp)
    sw $s6, 8($sp)
    sw $s7, 4($sp)

level_loop:
    lw $s0, current_level
    lw $s1, max_level
    bgt $s0, $s1, game_won

    move $a0, $s0
    jal generate_puzzles

    jal clear_screen
    jal draw_board

    li $s2, 0                # puzzle index

puzzle_loop:
    lw $t0, num_puzzles
    bge $s2, $t0, level_complete

    move $a0, $s2
    jal get_puzzle_type
    move $s3, $v0            # puzzle type

    beq $s3, $zero, prompt_decimal

prompt_binary:
    move $a0, $s2
    jal get_binary_input
    move $s4, $v0
    j evaluate_answer

prompt_decimal:
    move $a0, $s2
    jal get_decimal_input
    move $s4, $v0

evaluate_answer:
    move $a0, $s2
    move $a1, $s4
    jal check_puzzle_answer
    beq $v0, 1, mark_correct

mark_incorrect:
    move $a0, $s2
    li $a1, 2
    jal set_puzzle_status

    jal clear_screen
    jal draw_board

    la $a0, msg_incorrect
    jal print_string

    li $t1, 2
    sw $t1, game_state

    j game_loop_exit

mark_correct:
    move $a0, $s2
    li $a1, 1
    jal set_puzzle_status

    jal clear_screen
    jal draw_board

    la $a0, msg_correct
    jal print_string

    addiu $s2, $s2, 1
    j puzzle_loop

level_complete:
    la $a0, msg_level_up
    jal print_string

    move $a0, $s0
    move $a1, $zero
    jal calculate_score

    move $a0, $v0
    jal add_score

    jal display_score

    addiu $s0, $s0, 1
    sw $s0, current_level

    jal delay_level_transition

    j level_loop

game_won:
    li $t2, 1
    sw $t2, game_state

    j game_loop_exit

    .globl delay_level_transition
delay_level_transition:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)

    li $a0, 400
    jal delay

    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

game_loop_exit:
    lw $ra, 36($sp)
    lw $s0, 32($sp)
    lw $s1, 28($sp)
    lw $s2, 24($sp)
    lw $s3, 20($sp)
    lw $s4, 16($sp)
    lw $s5, 12($sp)
    lw $s6, 8($sp)
    lw $s7, 4($sp)
    addiu $sp, $sp, 40
    jr $ra

    .globl display_final_result
display_final_result:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)

    jal print_newline

    lw $s0, game_state
    li $t0, 1
    beq $s0, $t0, final_win
    li $t1, 2
    beq $s0, $t1, final_loss
    j final_score_only

final_win:
    la $a0, msg_winner
    jal print_string
    j final_score_only

final_loss:
    la $a0, msg_game_over
    jal print_string

final_score_only:
    la $a0, msg_final_score
    jal print_string

    jal get_score
    move $a0, $v0
    jal print_int

    jal print_newline
    jal print_newline

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    addiu $sp, $sp, 20
    jr $ra

    .globl play_again
play_again:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)

play_again_prompt:
    la $a0, msg_play_again
    jal print_string

    jal read_integer
    move $s0, $v0

    beq $s0, $zero, play_again_return
    li $t0, 1
    beq $s0, $t0, play_again_accept

    la $a0, msg_invalid_choice
    jal print_string
    j play_again_prompt

play_again_accept:
    li $v0, 1
    j play_again_done

play_again_return:
    move $v0, $zero

play_again_done:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    addiu $sp, $sp, 20
    jr $ra
