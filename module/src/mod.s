.section .text
.global _start
// int mod(int x, int y)


_start:

		// get 2 numbers from user
		LDR r0, =input0
		BL get_input
		LDR r0, =input1
		BL get_input

		// save both inputs to register 0 and 1
		LDR r0, =input0
		//LDR r0, [r0]
		BL atoi
		MOV r4, r0 // save result
		//LDR r0, input1
		LDR r0, =input1
		BL atoi
		MOV r5, r0 // save result

		MOV r0, r4 // input2 as int
		MOV r1, r5 //input1 as int

		// print the result of input0 % input1 
		BL mod 
		BL itos
		BL print


		// exit normally
		MOV r0, #0
		MOV r7, #1
		SVC 0


mod:
	// prologue
	PUSH {r4-r11}

	MOV r4, r0 // arg0
	MOV r5, r1 // arg1

	UDIV r6, r4, r5 // int var0 = arg1 / arg0
	MUL  r7, r6, r5 // int var1 = var0 * arg1
	SUB	 r0, r4, r7 // int result = arg0 - var1
	
	//epilogue
	POP {r4-r11}
	BX lr // return result

atoi:
	PUSH {lr} // preserve LR because we are going to go to other subroutines
	PUSH {r4-r11}
	
	MOV r4, r0

	MOV r5, #0 // counter
	MOV r6, #1 // multiplier
	MOV r7, #0 // length
	MOV r10, #0 // result
	MOV r3, #10 // multiplier multiplier (can't use immediate with MUL for whatever reason)

_atoi_iter:
	LDRB r8, [r4]
	CMP r8, #0xa // check if newline
	BEQ _atoi_loop

	ADD r4, r4, #1
	ADD r7, r7, #1
	B _atoi_iter

_atoi_loop:
	SUB r4, r4, #1 // decrement 
	LDRB r8, [r4]
	SUB r8, r8, #0x30 // convert to int 

	MUL r9, r8, r6 // multiply curr num by multiplier
	MOV r8, r9
	// MUL makes me store the result in a different register for some reason
	MUL r8, r6, r3 // multiply the multiplier by 10 to match the current "place" in the number  
	MOV r6, r8
	ADD r10, r10, r8

	SUB r7, r7, #1 // decrement length
	CMP r7, #0x0 // check curr character is NULL
	BEQ _atoi_leave
	B _atoi_loop // loop!

_atoi_leave:
	MOV r0, r9

	POP {r4-r11}
	POP {LR}
	BX lr
// converts char to int and saves it to the buffer variable stored in memory (see .section .data)
itos:
	PUSH {lr}
	PUSH {r4-r11}

	MOV r4, r0 

	MOV r5, #0 // length
	MOV r6, #1000 // current place. 1000 is good 'nuff
	MOV r7, #10 // place divisor

_itos_loop:
	MOV r8, #0x0
	UDIV r8, r4, r6 // divide current digit by divisor
	ADD r8, r8,  #0x30 // convert digit to char

	LDR r9, =buff
	ADD r9, r9, r5 // BUFF = BUFF[r5]
	STRB r8, [r9] // store current digit (now char) in BUFF
	ADD r5, r5, #1 // increment counter by 1

	SUB r8, r8, #0x30 // turn it back into an int (temporarily)
	MUL r10, r8, r6 // store the number * the place variable
	SUB r4, r4, r10 // subtracts the number from the original number

	UDIV r10, r6, r7
	MOV r6, r10
	CMP r6, #0x0 // see if the place is at 0
	BEQ _itos_leave
	B _itos_loop

_itos_leave:

	MOV r9, #0xa // new line
	LDR r8, =buff
	ADD r8, r8, r5 // BUFF = BUFF[r5]
	ADD r8, r8, #1
	STRB r9, [r8]

	POP {r4-r11}
	POP {lr}
	BX lr

print:
		PUSH {r4-r11}

		MOV r7, #0x4 //Write 
		MOV r0, #0x1 //stdout
		LDR r1, =buff 
		MOV r2, #0x8 //8 byte stream
		SVC 0x0

		POP {r4-r11}
		BX lr

get_input:
	push {LR}
	push {r4-r11}

	MOV r7, #3 // Read
	MOV r1, r0 // input buffer
	MOV r0, #0x0 // stdin
	MOV r2, #0x8
	SVC 0

	POP {r4-r11}
	BX lr

.section .data
	buff: .skip 8 // 8 byte buffer, good 'nuff
	input0: .skip 8
	input1: .skip 8

