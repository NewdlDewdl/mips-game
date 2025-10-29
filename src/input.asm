# -------------------------------------------------------------
# input.asm - User input handling routines
# -------------------------------------------------------------

        .text
        .globl get_decimal_input
        .globl get_binary_input
        .globl read_string
        .globl read_integer

        .extern print_string
        .extern print_int
        .extern print_newline
        .extern validate_decimal
        .extern validate_binary_string
        .extern binary_string_to_int

        .extern prompt_decimal
        .extern prompt_binary
        .extern prompt_line_prefix
        .extern prompt_line_separator
        .extern error_invalid

        .data
        .align  2
input_buffer:
        .space  32

        .text

# Helper: print "Line X" prefix
print_line_prefix:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $a0, 8($sp)
        la      $a0, prompt_line_prefix
        jal     print_string
        lw      $a0, 8($sp)
        addiu   $a0, $a0, 1
        jal     print_int
        la      $a0, prompt_line_separator
        jal     print_string
        lw      $ra, 12($sp)
        lw      $a0, 8($sp)
        addiu   $sp, $sp, 16
        jr      $ra

get_decimal_input:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        move    $s0, $a0
1:
        move    $a0, $s0
        jal     print_line_prefix
        la      $a0, prompt_decimal
        jal     print_string
        jal     read_integer
        move    $t0, $v0
        move    $a0, $t0
        jal     validate_decimal
        bnez    $v0, 2f
        la      $a0, error_invalid
        jal     print_string
        j       1b
2:
        move    $v0, $t0
        jal     print_newline
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        addiu   $sp, $sp, 16
        jr      $ra

get_binary_input:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)
        sw      $s0, 16($sp)
        sw      $s1, 12($sp)
        move    $s0, $a0
1:
        move    $a0, $s0
        jal     print_line_prefix
        la      $a0, prompt_binary
        jal     print_string
        la      $a0, input_buffer
        li      $a1, 32
        jal     read_string
        la      $a0, input_buffer
        jal     validate_binary_string
        bnez    $v0, 2f
        la      $a0, error_invalid
        jal     print_string
        j       1b
2:
        la      $a0, input_buffer
        jal     binary_string_to_int
        move    $s1, $v0
        move    $v0, $s1
        jal     print_newline
        lw      $ra, 20($sp)
        lw      $s0, 16($sp)
        lw      $s1, 12($sp)
        addiu   $sp, $sp, 24
        jr      $ra

read_string:
        # $a0 = buffer, $a1 = max length
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        move    $s0, $a0
        li      $v0, 8
        syscall
        move    $t0, $s0
1:
        lbu     $t1, 0($t0)
        beq     $t1, $zero, 2f
        li      $t2, '\n'
        bne     $t1, $t2, 3f
        sb      $zero, 0($t0)
        j       2f
3:
        addiu   $t0, $t0, 1
        j       1b
2:
        move    $v0, $s0
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        addiu   $sp, $sp, 16
        jr      $ra

read_integer:
        li      $v0, 5
        syscall
        jr      $ra
