# -------------------------------------------------------------
# puzzle.asm - Puzzle generation and management
# -------------------------------------------------------------

        .set    noreorder

        .text
        .globl generate_puzzles
        .globl get_puzzle_type
        .globl get_puzzle_value
        .globl check_answer

        .extern puzzles
        .extern num_puzzles
        .extern random_int
        .extern random_byte

PUZZLE_STRIDE   = 8
TYPE_OFFSET     = 0
STATUS_OFFSET   = 1
VALUE_OFFSET    = 4
STATUS_UNSOLVED = 0
STATUS_CORRECT  = 1
STATUS_WRONG    = 2

# -------------------------------------------------------------
# generate_puzzles(level)
# -------------------------------------------------------------
generate_puzzles:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        move    $s0, $a0              # level
        sw      $s0, num_puzzles
        li      $s1, 0                # index
        la      $t0, puzzles
1:
        bge     $s1, $s0, 3f
        mul     $t1, $s1, PUZZLE_STRIDE
        addu    $t2, $t0, $t1

        # type = random_int(2)
        li      $a0, 2
        jal     random_int
        sb      $v0, TYPE_OFFSET($t2)

        # status = unsolved
        sb      $zero, STATUS_OFFSET($t2)

        # value = random_byte()
        jal     random_byte
        sb      $zero, 2($t2)
        sb      $zero, 3($t2)
        sw      $v0, VALUE_OFFSET($t2)

        addiu   $s1, $s1, 1
        j       1b
3:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        addiu   $sp, $sp, 16
        jr      $ra

# -------------------------------------------------------------
# get_puzzle_type(index)
# -------------------------------------------------------------
get_puzzle_type:
        la      $t0, puzzles
        mul     $t1, $a0, PUZZLE_STRIDE
        addu    $t0, $t0, $t1
        lbu     $v0, TYPE_OFFSET($t0)
        jr      $ra

# -------------------------------------------------------------
# get_puzzle_value(index)
# -------------------------------------------------------------
get_puzzle_value:
        la      $t0, puzzles
        mul     $t1, $a0, PUZZLE_STRIDE
        addu    $t0, $t0, $t1
        lw      $v0, VALUE_OFFSET($t0)
        jr      $ra

# -------------------------------------------------------------
# check_answer(index, answer)
# -------------------------------------------------------------
check_answer:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        move    $s0, $a0      # index
        move    $s1, $a1      # answer

        la      $t0, puzzles
        mul     $t1, $s0, PUZZLE_STRIDE
        addu    $t0, $t0, $t1
        lw      $t2, VALUE_OFFSET($t0)

        bne     $s1, $t2, 1f
        li      $t3, STATUS_CORRECT
        sb      $t3, STATUS_OFFSET($t0)
        li      $v0, 1
        j       2f
1:
        li      $t3, STATUS_WRONG
        sb      $t3, STATUS_OFFSET($t0)
        move    $v0, $zero
2:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        addiu   $sp, $sp, 16
        jr      $ra
