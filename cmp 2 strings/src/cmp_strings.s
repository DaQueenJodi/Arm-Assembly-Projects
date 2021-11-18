.global _start

.section .text

//assumes r4 is ascii text of 30 bytes

read_input:
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


check_string:
	push {lr}
	push {r4-r11}
	mov r3, #0 //counter 

loop_string:
	
	ldr r4, =str1
	ldr r5, =str2
	ldrb r1, [r4, r3] //load current byte of str1 into r1
	ldrb r2, [r5, r3] //load current byte of str2 into r2
	add r3, r3, #1 //increment counter

	cmp r2, #0x0
	beq leave_string 
	cmp r1, r2
	beq loop_string
	b leave_string



leave_string:
	//ldr r1, =nuts
	beq print_str
	pop {r4-r11}
	pop {pc}



print_str: 
	push {lr}
	push {r4-r11}

	mov r7, #0x4
	mov r0, #0x1
	ldr r1, =str3
	ldr r2, =len
	svc 0x0

	pop {r4-r11}
	pop {pc}



_start:
	mov r1, #0x29 //allocate 29 bytes. save one for the null character
	ldr r0, =str1 
	bl read_input
	
	mov r1, #0x29	
	ldr r0, =str2
	bl read_input

	bl check_string

	mov r7, #0x1
	mov r0, #0x1
	svc 0x0



.section .data
str1:
	.skip 30
str2:
	.skip 30
str3:
	.asciz "string 1 and string 2 are equivalent! \n"
len = .-str3







