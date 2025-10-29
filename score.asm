# Score calculation and display

.data
score_label: .asciiz "Current Score: "

.text
.globl calculate_score
calculate_score:
    # $a0 = level, $a1 = time bonus
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    move $s0, $a0
    move $s1, $a1

    lw $t0, num_puzzles
    li $t1, 50
    mult $t0, $t1
    mflo $s2            # puzzles * 50

    mult $s0, $t1
    mflo $s3            # level * 50

    addu $v0, $s2, $s3
    addu $v0, $v0, $s1

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addiu $sp, $sp, 20
    jr $ra

.globl add_score
add_score:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a0
    lw $t0, total_score
    addu $t0, $t0, $s0
    sw $t0, total_score

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

.globl get_score
get_score:
    lw $v0, total_score
    jr $ra

.globl display_score
display_score:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    la $a0, score_label
    jal print_string
    jal get_score
    move $a0, $v0
    jal print_int
    jal print_newline

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra
