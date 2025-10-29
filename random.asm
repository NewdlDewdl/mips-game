# Random number generation using linear congruential generator

.data
.globl random_seed
random_seed: .word 1

.text
.globl init_random_seed
init_random_seed:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 30
    syscall
    move $t0, $a0
    beq $t0, $zero, irs_use_default
    sw $t0, random_seed
    j irs_done

irs_use_default:
    li $t0, 12345
    sw $t0, random_seed

irs_done:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

.globl random_int
random_int:
    # $a0 = max (exclusive)
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    lw $t0, random_seed
    li $t1, 1103515245
    mult $t0, $t1
    mflo $t0
    li $t1, 12345
    addu $t0, $t0, $t1
    li $t1, 0x7FFFFFFF
    and $t0, $t0, $t1
    sw $t0, random_seed

    beq $a0, $zero, ri_return_zero
    div $t0, $a0
    mfhi $v0
    j ri_done

ri_return_zero:
    move $v0, $zero

ri_done:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

.globl random_bit
random_bit:
    li $a0, 2
    jal random_int
    jr $ra

.globl random_byte
random_byte:
    li $a0, 256
    jal random_int
    jr $ra
