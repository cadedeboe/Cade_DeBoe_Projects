# unit3a.asm
# test of MEM -> ID forwarding
        addi x1, x0, 3      # forward to input A of equality checker
        beq  x1, x0, target # not taken
        addi x1, x1, 1      # should execute
target:
        addi x2, x0, 5
        
# nops to avoid fetching illegal instructions
nop
nop
nop
nop
