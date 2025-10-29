# Score calculation and display routines

.text
    .globl calculate_score
# calculate_score(level, time_bonus)
calculate_score:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)

    move $s0, $a0          # level
    li   $t0, 50           # points per puzzle

    mul  $t1, $s0, $t0     # puzzles * 50 (num puzzles == level)
    mul  $t2, $s0, $t0     # level bonus
    addu $t3, $t1, $t2
    addu $t3, $t3, $a1     # add optional time bonus

    move $v0, $t3

    lw $ra, 12($sp)
    lw $s0, 8($sp)
    addiu $sp, $sp, 16
    jr $ra

    .globl add_score
add_score:
    la   $t0, total_score
    lw   $t1, 0($t0)
    addu $t1, $t1, $a0
    sw   $t1, 0($t0)
    jr   $ra

    .globl get_score
get_score:
    la   $t0, total_score
    lw   $v0, 0($t0)
    jr   $ra

    .globl display_score
display_score:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)

    la  $a0, score_label
    jal print_string

    jal get_score
    move $a0, $v0
    jal print_int
    jal print_newline

    lw $ra, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

.data
score_label: .asciiz "Score: "
