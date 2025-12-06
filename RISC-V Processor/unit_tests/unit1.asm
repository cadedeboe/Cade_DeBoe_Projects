# unit1.asm
# test of MEM -> EX forwarding
addi x1, x0, 3      # R[1] = 3, forward to A input of ALU
add  x2, x1, x0     # R[2] = 3, forward to B input of ALU
add  x3, x0, x2     # R[3] = 3

# nops to avoid fetching illegal instructions
nop
nop
nop
nop
