# unit5.asm
# test of stalling caused by lw to beq
        addi x1, x0, 3      # R[1] = 3
        sw   x1, 96(x0)     # Mem[96] = 3
        lw   x1, 96(x0)     # R[1] = 3, should cause a stall in next instruction
        beq  x1, x0, target # shouldn't be taken
        addi x1, x1, 1      # R[1] = 3 + 1 = 4
target:
        addi x0, x0, 0      # nop

# nops to avoid fetching illegal instructions
nop
nop
nop
nop
