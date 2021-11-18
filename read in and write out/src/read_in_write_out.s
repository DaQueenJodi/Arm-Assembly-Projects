.global _start

.section .text
	
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

		mov r0, r5 
		pop {r4-r11}
		pop {pc}
//r0 = pointer to ascii 
write_user_input:
		push {lr}
		push {r4-r11}

		mov r7, #0x4
		mov r0, #0x1
		ldr r1, =output
		mov r2, #0x30
		svc 0x0

		pop {r4-r11}
		pop {pc}

_start:
	//read stdin
	ldr r0, =output
	ldr r1, =0x29 
	bl read_user_input
	//write stdout
	 
	bl write_user_input

	//end program
	mov r0, #0
	mov r7, #0x1 
	svc 0x0


.section .data

input:
		.skip 30 //allocate 30 bytes
output:
		.asciz ""

