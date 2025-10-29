# Score management module

.set noreorder

.data
    .align 2
    score_label:      .asciiz "Current Score: "

.text
    .globl calculate_score
calculate_score:
    # $a0 = level, $a1 = time bonus (unused but included for completeness)
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)

    move $s0, $a0
    move $s1, $a1

    lw $t0, num_puzzles
    li $t1, 50
    mul $t2, $t0, $t1

    mul $t3, $s0, $t1

    addu $t4, $t2, $t3
    addu $t4, $t4, $s1

    move $v0, $t4

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    addiu $sp, $sp, 20
    jr $ra

    .globl add_score
add_score:
    # $a0 = points to add
    lw $t0, total_score
    addu $t0, $t0, $a0
    sw $t0, total_score
    jr $ra

    .globl get_score
get_score:
    lw $v0, total_score
    jr $ra

    .globl display_score
display_score:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)

    la $a0, score_label
    jal print_string

    lw $s0, total_score
    move $a0, $s0
    jal print_int

    jal print_newline

    lw $ra, 8($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 12
    jr $ra
