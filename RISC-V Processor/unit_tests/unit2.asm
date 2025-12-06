# unit2.asm
# test of WB -> EX forwarding
addi x1, x0, 3      # forward to A input of ALU
addi x0, x0, 1      # shouldn't forward
add  x2, x1, x0     # forward to B input of ALU
addi x0, x0, 2      # shouldn't forward
add  x3, x0, x2

# nops to avoid fetching illegal instructions
nop
nop
nop
nop
