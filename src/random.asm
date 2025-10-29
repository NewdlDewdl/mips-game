# Random number generation utilities for Binary Game

.data
    .align 2
    .globl random_seed
random_seed: .word 0

.text
    .globl init_random_seed
init_random_seed:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)

    li $v0, 30
    syscall
    move $t0, $a0
    sw $t0, random_seed

    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl random_int
random_int:
    # $a0 = max (exclusive)
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)

    move $s0, $a0
    blez $s0, random_int_zero

    lw $s1, random_seed
    li $s2, 1103515245
    multu $s1, $s2
    mflo $s1

    li $t0, 12345
    addu $s1, $s1, $t0

    li $t1, 0x7FFFFFFF
    and $s1, $s1, $t1

    sw $s1, random_seed

    divu $s1, $s0
    mfhi $v0
    j random_int_done

random_int_zero:
    move $v0, $zero

random_int_done:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    addiu $sp, $sp, 20
    jr $ra

    .globl random_bit
random_bit:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)

    li $a0, 2
    jal random_int

    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

    .globl random_byte
random_byte:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)

    li $a0, 256
    jal random_int

    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra
