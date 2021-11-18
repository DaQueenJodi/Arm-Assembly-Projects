.global _start


.section .text

_start:
		mov r7, #4
		ldr r1, =message
		ldr r2, =len
		svc 0

		mov r7, #1
		svc 0


.section .data
message:
		.asciz "Hello World\n"
		len = .-message


