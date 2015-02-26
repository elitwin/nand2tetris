// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

    @R2
    M=0 // initialize RAM[2] to 0

(LOOP)
    @R1 // Terminate if R1 <= 0 (can also check if R0 is 0 and terminate early)
    D=M
    @END
    D;JLE

    @R0
    D=M

    @R2
    M=M+D // R2+=R0

    @R1
    M=M-1 // R1-=1 (Decrement counter)

    @LOOP
    0;JMP

(END)
    @END
    0;JMP // infinite loop to terminate
