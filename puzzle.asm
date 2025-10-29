# Puzzle generation and storage

.data
.align 2
.globl puzzles
puzzles:        .space 80          # 10 puzzles * 8 bytes
.globl num_puzzles
num_puzzles:    .word 0

.type_offsets:
    # Offsets: type=0, status=1, value=4

.text
.globl generate_puzzles
generate_puzzles:
    # $a0 = level (number of puzzles)
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    move $s0, $a0            # level count
    sw $s0, num_puzzles
    li $s1, 0                # index

    beq $s0, $zero, gp_done

    la $s2, puzzles

gp_loop:
    bge $s1, $s0, gp_done

    # Random type 0 or 1
    li $a0, 2
    jal random_int
    move $s3, $v0            # Save random type

    # Calculate address (must recalculate after function calls)
    sll $t0, $s1, 3          # offset = index * 8
    add $t1, $s2, $t0
    sb $s3, 0($t1)           # Store type

    # Reset status to unsolved (0)
    sb $zero, 1($t1)

    # Store random value 0-255
    jal random_byte
    # Recalculate address after function call
    sll $t0, $s1, 3
    add $t1, $s2, $t0
    sw $v0, 4($t1)

    addiu $s1, $s1, 1
    j gp_loop

gp_done:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addiu $sp, $sp, 20
    jr $ra

.globl get_puzzle_address
get_puzzle_address:
    # $a0 = index
    la $t0, puzzles
    sll $t1, $a0, 3
    add $v0, $t0, $t1
    jr $ra

.globl get_puzzle_type
get_puzzle_type:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    move $a1, $a0
    jal get_puzzle_address
    lb $v0, 0($v0)
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

.globl get_puzzle_status
get_puzzle_status:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    move $a1, $a0
    jal get_puzzle_address
    lb $v0, 1($v0)
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

.globl set_puzzle_status
set_puzzle_status:
    # $a0 = index, $a1 = status
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a0
    jal get_puzzle_address
    sb $a1, 1($v0)

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

.globl get_puzzle_value
get_puzzle_value:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    move $a1, $a0
    jal get_puzzle_address
    lw $v0, 4($v0)
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

.globl set_puzzle_value
set_puzzle_value:
    # $a0 = index, $a1 = value
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a0
    jal get_puzzle_address
    sw $a1, 4($v0)

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra
