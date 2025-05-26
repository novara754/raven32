.section .text
.global _start

_start:
    addi x0, zero, 0
    addi x1, zero, 0
    addi x2, zero, 0
    addi x3, zero, 0
    addi x4, zero, 0
    addi x5, zero, 0
    addi x6, zero, 0
    addi x7, zero, 0
    addi x8, zero, 0
    addi x9, zero, 0
    addi x10, zero, 0
    addi x11, zero, 0
    addi x12, zero, 0
    addi x13, zero, 0
    addi x14, zero, 0
    addi x15, zero, 0
    addi x16, zero, 0
    addi x17, zero, 0
    addi x18, zero, 0
    addi x19, zero, 0
    addi x20, zero, 0
    addi x21, zero, 0
    addi x22, zero, 0
    addi x23, zero, 0
    addi x24, zero, 0
    addi x25, zero, 0
    addi x26, zero, 0
    addi x27, zero, 0
    addi x28, zero, 0
    addi x29, zero, 0
    addi x30, zero, 0
    addi x31, zero, 0

#define TEST(n)          \
    .global n;           \
    addi x1, zero, 1000; \
    jal zero,n;          \
    .global n ## _ret;   \
    n ## _ret:

#define CTEST(n)         \
    .global n ## _ret;   \
    n ## _ret:

    TEST(add)
    TEST(addi)
    TEST(and)
    TEST(andi)
    TEST(auipc)
    TEST(beq)
    TEST(bge)
    TEST(bgeu)
    TEST(blt)
    TEST(bltu)
    TEST(bne)
    TEST(j)
    TEST(jal)
    TEST(jalr)
    TEST(lb)
    TEST(lbu)
    TEST(lh)
    TEST(lhu)
    TEST(lui)
    TEST(lw)
    TEST(or)
    TEST(ori)
    TEST(sll)
    TEST(slli)
    TEST(slt)
    TEST(slti)
    TEST(sra)
    TEST(srai)
    TEST(srl)
    TEST(srli)
    TEST(sub)
    TEST(sw)
    TEST(xor)
    TEST(xori)

    ebreak
