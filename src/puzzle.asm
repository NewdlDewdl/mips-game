# Puzzle generation and management

.set noreorder

.data
    .align 2
    .globl puzzles
puzzles:        .space 80          # 10 puzzles * 8 bytes
    .globl num_puzzles
num_puzzles:    .word 0

    .equ PUZZLE_SIZE, 8
    .equ PUZZLE_TYPE_OFFSET, 0
    .equ PUZZLE_STATUS_OFFSET, 1
    .equ PUZZLE_VALUE_OFFSET, 4

.text
    .globl generate_puzzles
generate_puzzles:
    # $a0 = level (number of puzzles)
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)

    move $s0, $a0
    sw $s0, num_puzzles
    move $s1, $zero         # index

    la $s2, puzzles

puzzle_generate_loop:
    bge $s1, $s0, generate_done

    # Determine puzzle base address
    sll $t0, $s1, 3          # index * 8
    addu $s3, $s2, $t0

    # Random type 0 or 1
    li $a0, 2
    jal random_int
    sb $v0, PUZZLE_TYPE_OFFSET($s3)

    # Reset status to unsolved (0)
    sb $zero, PUZZLE_STATUS_OFFSET($s3)

    # Random value (0-255)
    jal random_byte
    sw $v0, PUZZLE_VALUE_OFFSET($s3)

    addiu $s1, $s1, 1
    j puzzle_generate_loop

generate_done:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    addiu $sp, $sp, 24
    jr $ra

    .globl get_puzzle_type
get_puzzle_type:
    # $a0 = index
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    la $s0, puzzles
    sll $t0, $a0, 3
    addu $s0, $s0, $t0

    lb $v0, PUZZLE_TYPE_OFFSET($s0)

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl get_puzzle_status
get_puzzle_status:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    la $s0, puzzles
    sll $t0, $a0, 3
    addu $s0, $s0, $t0

    lb $v0, PUZZLE_STATUS_OFFSET($s0)

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl set_puzzle_status
set_puzzle_status:
    # $a0 = index, $a1 = status
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    la $s0, puzzles
    sll $t0, $a0, 3
    addu $s0, $s0, $t0

    sb $a1, PUZZLE_STATUS_OFFSET($s0)

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra

    .globl get_puzzle_value
get_puzzle_value:
    # $a0 = index
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    la $s0, puzzles
    sll $t0, $a0, 3
    addu $s0, $s0, $t0

    lw $v0, PUZZLE_VALUE_OFFSET($s0)

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra
