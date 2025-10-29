# -------------------------------------------------------------
# utils.asm - Common utility routines for the Binary Game
# -------------------------------------------------------------

        .text
        .globl print_string
print_string:
        # $a0 = address of null-terminated string
        li      $v0, 4
        syscall
        jr      $ra

        .globl print_int
print_int:
        # $a0 = integer value to print
        move    $a0, $a0
        li      $v0, 1
        syscall
        jr      $ra

        .globl print_char
print_char:
        # $a0 = character to print (lower 8 bits)
        li      $v0, 11
        syscall
        jr      $ra

        .globl print_newline
print_newline:
        li      $a0, '\n'
        li      $v0, 11
        syscall
        jr      $ra

        .globl string_length
string_length:
        # $a0 = address of string
        move    $t0, $a0
        li      $t1, 0
1:
        lbu     $t2, 0($t0)
        beq     $t2, $zero, 2f
        addiu   $t0, $t0, 1
        addiu   $t1, $t1, 1
        j       1b
2:
        move    $v0, $t1
        jr      $ra

        .data
        .align  2
newline_str:
        .asciiz "\n"
