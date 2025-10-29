# Random number generation utilities using a linear congruential generator

.data
    .globl random_seed
random_seed: .word 0

.text
    .globl init_random_seed
init_random_seed:
    li  $v0, 30
    syscall
    sw  $a0, random_seed
    jr  $ra

    .globl random_int
random_int:
    beq $a0, $zero, random_int_zero

    lw  $t0, random_seed

    li  $t1, 1103515245
    multu $t0, $t1
    mflo $t0

    li  $t1, 12345
    addu $t0, $t0, $t1

    li  $t1, 0x7FFFFFFF
    and $t0, $t0, $t1

    sw  $t0, random_seed

    divu $t0, $a0
    mfhi $v0
    jr  $ra

random_int_zero:
    move $v0, $zero
    jr  $ra

    .globl random_bit
random_bit:
    li  $a0, 2
    jal random_int
    jr  $ra

    .globl random_byte
random_byte:
    li  $a0, 256
    jal random_int
    jr  $ra
