# -------------------------------------------------------------
# validation.asm - Input validation and conversions
# -------------------------------------------------------------

        .text
        .globl validate_decimal
        .globl validate_binary_string
        .globl binary_string_to_int
        .globl int_to_binary_string
        .globl check_puzzle_answer

        .extern string_length
        .extern puzzles
        .extern check_answer
        .extern get_puzzle_type
        .extern get_puzzle_value

PUZZLE_STRIDE   = 8
STATUS_OFFSET   = 1
STATUS_CORRECT  = 1
STATUS_WRONG    = 2

validate_decimal:
        # $a0 = value
        sltiu   $t0, $a0, 256
        beq     $t0, $zero, 1f
        bgez    $a0, 2f
1:
        move    $v0, $zero
        jr      $ra
2:
        li      $v0, 1
        jr      $ra

validate_binary_string:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        move    $s0, $a0
        jal     string_length
        li      $t0, 8
        bne     $v0, $t0, 3f
        li      $t1, 0
1:
        beq     $t1, $t0, 2f
        addu    $t2, $s0, $t1
        lbu     $t3, 0($t2)
        li      $t4, '0'
        beq     $t3, $t4, 4f
        li      $t4, '1'
        beq     $t3, $t4, 4f
        j       3f
4:
        addiu   $t1, $t1, 1
        j       1b
2:
        li      $v0, 1
        j       5f
3:
        move    $v0, $zero
5:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        addiu   $sp, $sp, 16
        jr      $ra

binary_string_to_int:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        move    $s0, $a0
        li      $t0, 0
        li      $t1, 0
1:
        li      $t2, 8
        beq     $t1, $t2, 2f
        sll     $t0, $t0, 1
        addu    $t3, $s0, $t1
        lbu     $t4, 0($t3)
        li      $t5, '1'
        bne     $t4, $t5, 3f
        ori     $t0, $t0, 1
3:
        addiu   $t1, $t1, 1
        j       1b
2:
        move    $v0, $t0
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        addiu   $sp, $sp, 16
        jr      $ra

int_to_binary_string:
        # $a0 = value, $a1 = buffer (size >=9)
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        move    $s0, $a0
        move    $s1, $a1
        li      $t0, 7
1:
        bltz    $t0, 2f
        move    $t1, $s0
        srlv    $t1, $t1, $t0
        andi    $t1, $t1, 1
        li      $t2, '0'
        beq     $t1, $zero, 3f
        li      $t2, '1'
3:
        li      $t3, 7
        subu    $t4, $t3, $t0
        addu    $t5, $s1, $t4
        sb      $t2, 0($t5)
        addiu   $t0, $t0, -1
        j       1b
2:
        li      $t6, 8
        addu    $t6, $s1, $t6
        sb      $zero, 0($t6)
        move    $v0, $s1
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        addiu   $sp, $sp, 16
        jr      $ra

check_puzzle_answer:
        # $a0 = index, $a1 = answer
        jal     check_answer
        jr      $ra
