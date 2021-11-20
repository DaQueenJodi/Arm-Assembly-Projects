.global _start

.section .text


check_guess:
	push {lr}
	push {r4-r11}
	mov r5, #0 //counter 

_loop_guess:
	ldr r3, =hidden_word
	ldr r4, =guess
	ldrb r1, [r4]
	ldrb r2, [r3, r5] //load current byte of hidden_word
	add r5, r5, #1 //increment counter

	cmp r2, #0x0
	beq leave_guess
	cmp r2, r1 
	beq _correct_guess
_correct_guess:
	//replace the current byte of hidden word with the guess, then print that you guessed right
	strb r2, [r1]
	ldr r1, =corr_guess_message
	ldr r2, =0x13
	bl print_str


leave_guess:
	pop {r4-r11}
	pop {pc}


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

// check_guess but for an entire string
check_string:
	push {lr}
	push {r4-r11}
	mov r3, #0 //counter 

loop_string:
	ldr r4, =hidden_word
	ldr r5, =real_word
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


nl: 
	push {lr}
	push {r4-r11}
	
	//pop {r1}
	mov r7, #0x4
	mov r0, #0x1
	mov r2, #0x2
	ldr r1, =newline
	svc 0x0

	pop {r4-r11}
	pop {pc}
//assumes r1 is the message to print and r2 is the lenght of the message
print_str: 
	push {lr}
	push {r4-r11}

	//pop {r1}
	mov r7, #0x4
	mov r0, #0x1
	svc 0x0

	pop {r4-r11}
	pop {pc}

main_loop:

	ldr r1, =hidden_word
	ldr r2, =len
	bl print_str

	push {lr}
	push {r4-r11}
	
	//set guess
	ldr r2, =0x12
	ldr r1, =guess_promt 
	bl print_str
	
	ldr r0, =guess
	mov r1, #0x1 // 1 char answer, 1 byte for null
	bl read_input

	bl check_guess

	

	pop {r4-r11}
	pop {pc}

gen_hidden_word:
	push {lr}
	push {r4-r11}
	mov r5, #0x0 //counter
	mov r6, #0x20 //space
	mov r7, #0x5f //underscore
	

_hidden_word_loop:
	ldr r3, =real_word
	ldr r4, =hidden_word
	ldrb r1, [r3, r5] // curr byte of real_word
	//ldrb r2, [r4, r5] //curr byte of hidden_word
	add r5, r5, #0x1

	//if NULL, leave loop (word is done):
	cmp r1, #0x0
	beq leave_hidden_loop 
	//if no space, add underscore to hidden_word:
	cmp r1, #0x20 
	bne _add_underscore
	//else add a space:
_add_space:
	strb r6, [r4, r5]
	b _hidden_word_loop
_add_underscore:
	strb r7, [r4, r5]
	b _hidden_word_loop
		
leave_hidden_loop:
// print hidden_word then real_word; just for debug
	ldr r2, =len
	ldr r1, =hidden_word
	bl print_str
	bl nl
	ldr r2, =len
	ldr r1, =real_word
	bl print_str
	bl nl
	pop {r4-r11}
	pop {pc}
	//b main_loop
_start:	
	
	bl gen_hidden_word
	bl main_loop 

	//exit successfully 
	mov r7, #0x1
	mov r0, #0x1
	svc 0x0



.section .data

real_word:
	.asciz "W e lp"
guess:
	.skip 1
len = .-real_word

hidden_word:
	.skip len
newline:
	.asciz "\n\n"
guess_promt:
	.asciz "Enter your guess:\n"

corr_guess_message:
	.asciz "Pog, You got 1 right!\n"


