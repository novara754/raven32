    jal x1, a
    addi x2, x0, 0x123
a:
    addi x1, x0, 10
    beq x1, x1, b
    addi x2, x0, 0x321
b:
    addi x4, x0, 5
    beq x2, x4, c
    addi x5, x0, 123
c:
    nop
