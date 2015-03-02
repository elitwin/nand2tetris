// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

// To optimize, we are either writing black or white - the logic
// to loop through each pixel is the same - only the color changes
(INIT)
        // Only initialize screen_end once
        @SCREEN
        D=A
        @8192 // 256 rows x 512 pixels (32x16 bit-words)
        D=D+A
        @screen_end
        M=D

(RESET)
        @SCREEN
        D=A
        @screen_ptr
        M=D

(READ_KBD)
        @KBD
        D=M
        @BLACK
        D;JGT

(WHITE)
        @color
        M=0
        @FILL
        0;JMP

(BLACK)
        @color
        M=-1

(FILL)
        // Reinitialize screen_ptr if we finished drawing all pixels
	@screen_ptr
	D=M
	@screen_end
	D=D-M
	@RESET
	D;JEQ

        @color
        D=M

        @screen_ptr
        A=M // set A register to memory location
        M=D // D-register is holding the color

        @screen_ptr
        M=M+1 // increment to next pixel

        @READ_KBD
        0;JMP
