# -------------------------------------------------------------
# score.asm - Score calculation utilities
# -------------------------------------------------------------

        .text
        .globl calculate_score
        .globl add_score
        .globl get_score
        .globl display_score

        .extern num_puzzles
        .extern total_score
        .extern score_label
        .extern print_string
        .extern print_int
        .extern print_newline

POINTS_PER_PUZZLE = 50

calculate_score:
        # $a0 = level, $a1 = time bonus (optional)
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        move    $s0, $a0
        lw      $t0, num_puzzles
        mul     $t1, $t0, POINTS_PER_PUZZLE
        mul     $t2, $s0, POINTS_PER_PUZZLE
        addu    $t1, $t1, $t2
        addu    $t1, $t1, $a1
        move    $v0, $t1
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        addiu   $sp, $sp, 16
        jr      $ra

add_score:
        # $a0 = points
        lw      $t0, total_score
        addu    $t0, $t0, $a0
        sw      $t0, total_score
        jr      $ra

get_score:
        lw      $v0, total_score
        jr      $ra

display_score:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        la      $a0, score_label
        jal     print_string
        jal     get_score
        move    $a0, $v0
        jal     print_int
        jal     print_newline
        lw      $ra, 12($sp)
        addiu   $sp, $sp, 16
        jr      $ra
