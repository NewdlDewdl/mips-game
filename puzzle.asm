# Puzzle generation and management routines

.data
    .globl puzzles
    .globl num_puzzles
puzzles:      .space 80      # 10 puzzles * 8 bytes
num_puzzles:  .word 0

.text
    .globl generate_puzzles
generate_puzzles:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)

    move $s0, $a0            # number of puzzles
    la   $t0, num_puzzles
    sw   $s0, 0($t0)

    move $s1, $zero          # index

puzzle_generate_loop:
    beq  $s1, $s0, generate_puzzles_exit

    move $a0, $zero
    jal random_bit
    move $s2, $v0            # type (0 or 1)

    jal random_byte
    move $t1, $v0            # value

    la   $t2, puzzles
    sll  $t3, $s1, 3         # offset = index * 8
    addu $t2, $t2, $t3

    sb   $s2, 0($t2)
    sb   $zero, 1($t2)       # status = unsolved
    sw   $t1, 4($t2)

    addiu $s1, $s1, 1
    j    puzzle_generate_loop

generate_puzzles_exit:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    addiu $sp, $sp, 24
    jr $ra

    .globl get_puzzle_type
get_puzzle_type:
    la   $t0, puzzles
    sll  $t1, $a0, 3
    addu $t0, $t0, $t1
    lb   $v0, 0($t0)
    jr   $ra

    .globl get_puzzle_status
get_puzzle_status:
    la   $t0, puzzles
    sll  $t1, $a0, 3
    addu $t0, $t0, $t1
    lb   $v0, 1($t0)
    jr   $ra

    .globl set_puzzle_status
set_puzzle_status:
    la   $t0, puzzles
    sll  $t1, $a0, 3
    addu $t0, $t0, $t1
    sb   $a1, 1($t0)
    jr   $ra

    .globl get_puzzle_value
get_puzzle_value:
    la   $t0, puzzles
    sll  $t1, $a0, 3
    addu $t0, $t0, $t1
    lw   $v0, 4($t0)
    jr   $ra

    .globl check_puzzle_answer
check_puzzle_answer:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)

    move $s0, $a0            # index
    move $s1, $a1            # user answer

    la   $t0, puzzles
    sll  $t1, $s0, 3
    addu $t0, $t0, $t1

    lb   $t2, 0($t0)         # type
    lw   $t3, 4($t0)         # stored value

    move $v1, $t3            # expected answer

    beq  $t2, $zero, check_binary_to_decimal
    # decimal to binary puzzle
    beq  $s1, $t3, puzzle_answer_correct
    j    puzzle_answer_incorrect

check_binary_to_decimal:
    beq  $s1, $t3, puzzle_answer_correct

puzzle_answer_incorrect:
    li   $t4, 2
    sb   $t4, 1($t0)
    move $v0, $zero
    j    check_puzzle_answer_exit

puzzle_answer_correct:
    li   $t4, 1
    sb   $t4, 1($t0)
    li   $v0, 1

check_puzzle_answer_exit:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    addiu $sp, $sp, 24
    jr $ra
