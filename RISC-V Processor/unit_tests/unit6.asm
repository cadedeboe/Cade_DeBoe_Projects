# unit6.asm
# test of flushing after a mispredicted branch
        addi x1, x0, 3      # R[1] = 3
        beq  x0, x0, target # should be taken
        addi x1, x1, 1      # should be fetched then flushed
        addi x1, x1, 2      # should also be fetched then flushed
target:
        addi x1, x1, 1      # R[1] = 3 + 1 = 4

# nops to avoid fetching illegal instructions
nop
nop
nop
nop