# -------------------------------------------------------------
# random.asm - Linear congruential RNG utilities
# -------------------------------------------------------------

        .data
        .align  2
random_seed:
        .word   1

        .text
        .globl init_random_seed
init_random_seed:
        # Uses syscall 30 (time) to seed RNG
        li      $v0, 30
        syscall
        move    $t0, $a0          # syscall returns low bits in $a0
        beq     $t0, $zero, 1f
        sw      $t0, random_seed
        jr      $ra
1:
        # fallback seed if time unavailable
        li      $t0, 123456789
        sw      $t0, random_seed
        jr      $ra

        .globl random_int
random_int:
        # $a0 = max (exclusive)
        # Returns 0..max-1 in $v0
        blez    $a0, random_zero
        lw      $t0, random_seed
        li      $t1, 1103515245
        multu   $t0, $t1
        mflo    $t0
        li      $t1, 12345
        addu    $t0, $t0, $t1
        li      $t1, 0x7fffffff
        and     $t0, $t0, $t1
        sw      $t0, random_seed
        divu    $t0, $a0
        mfhi    $v0
        jr      $ra
random_zero:
        move    $v0, $zero
        jr      $ra

        .globl random_bit
random_bit:
        li      $a0, 2
        jal     random_int
        jr      $ra

        .globl random_byte
random_byte:
        li      $a0, 256
        jal     random_int
        jr      $ra
