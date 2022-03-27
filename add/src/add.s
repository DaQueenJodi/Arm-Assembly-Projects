.section .text
.global  _start


//r1 = buffer to write to
//r2 = number of bytes to read

read_user_input:
		push {lr}
		push {r4-r11}

		push {r1}
		push {r0}

		mov r7, #0x3
		mov r0, #0x0
		pop {r1}
		pop {r2}
		svc 0x0

		pop {r4-r11}
		pop {pc}
//r0 = pointer to string of ascii numbers (hopefully)
my_atoi:
		push {lr}
		push {r4-r11}
		mov r2, #0x0 //str length counter
		mov r5, #0x0 //end state counter value
		mov r6, #1 //multiplier
		mov r7, #10 //multiplier multiplier

_string_length_loop:
		ldrb r8, [r0]
		cmp r8, #0xa
		beq _count
		add r0, r0, #1
		add r2, r2, #1
		b _string_length_loop
_count:
		sub r0, r0, #1
		ldrb r8, [r0] //first number in string
		sub r8, r8, #0x30 //get the integer value from the ascii number. all ascii numbers are just 0x30 off from the real int
		mul r4, r8, r6 // current place * number
		mov r8, r4
		mul r4, r6, r7 //incriment the placeholder
		mov r6, r4
		add r5, r5, r8 //add current number to counter
		sub r2, r2, #1 //decrement length, check for end
		cmp r2, #0x0
		beq _leave
		b _count
_leave:
		mov r0, r5

		pop {r4-r11}
		pop {pc}

//* r0 is the int to display. assume less than 10000 *\\
int_to_string:
		push {lr}
		push {r4-r11}

		mov r2, #0x0 //length counter
		mov r3, #1000 //current place
		mov r7, #10 //place divisor
_loop:
		mov r4, #0x0
		udiv r4, r0, r3
		add r4, r4, #0x30 // turn it back into ascii number

		ldr r5, =sum //store ascii
		add r5, r5, r2
		strb r4, [r5]
		add r2, r2, #1

		sub r4, r4, #0x30 //turn it into int
		mul r6, r4, r3 //stores the number * its place
		sub r0, r0, r6 //subtracts the number from the int to display



		udiv r6, r3, r7
		mov r3, r6
		cmp r3, #0
		beq _leave_int
		b _loop

_leave_int:
		mov r4, #0xa //new line
		ldr r5, =sum
		add r5, r5, r2
		add r5, r5, #1
		strb r4, [r5]

		pop {r4-r11}
		pop {pc}

display:
		push {lr}
		push {r4-r11}

		mov r7, #0x4 //std out
		mov r0, #0x1
		ldr r1, =sum
		mov r2, #0x8 //one byte stream
		svc 0x0

		pop {r4-r11}
		pop {pc}

_start:

		//read user input
		ldr r0, =first
		ldr r1, =0x6 //reserve 2 bytes for null and new line
		bl	read_user_input

		//read user input 2: electric boogaloo
		ldr r0, =second
		ldr r1, =0x6 //reserve 2 bytes for null and new line
		bl	read_user_input

		ldr r0, =first
		bl my_atoi
		mov r4, r0

		ldr r0, =second
		bl my_atoi
		mov r5, r0

		// add the 2 inputs (r4 = first, r5 = first) and put it into r0
		add r0, r4, r5


		bl int_to_string
		//display
		bl display
		mov r0, #0x0
		mov r7, #0x1
		svc 0x0



.section .data

first:
		.skip 8
second:
		.skip 8

sum:
		.skip 8
