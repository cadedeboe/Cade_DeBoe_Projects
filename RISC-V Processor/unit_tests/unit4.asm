# unit4.asm
# test of stalling caused by lw to R-type dependency
addi x1, x0, 3    # R[1] = 3
sw   x1, 96(x0)   # Mem[96] = 3
lw   x1, 96(x0)   # causes a stall for following instruction
add  x2, x1, x0   # R[2] = R[1] + 0 = 3

# nops to avoid fetching illegal instructions
nop
nop
nop
nop
