.section .text
.global _start


main_loop:
	PUSH {r4-r11}
	BL print_hidden_word
  BL nl


_main_loop_loop:
	LDR r4, =lives
	LDRB r0, [r4]
	CMP r0, #0
	BEQ _main_loop_out_of_lives
	BL itos
	BL print
	BL nl

	//LDR r0, =word
	//LDR r1, =word_len
	//BL print
	//BL nl


	BL handle_guess
	CMP r0, #0
	BEQ _main_loop_lose_a_life

	BL check_word
	CMP r0, #0
	BNE _main_loop_win

	BL print_hidden_word
  BL nl


	B _main_loop_loop

_main_loop_exit:
	POP {r4-r11}
	MOV r7, #1
	MOV r0, #0
	SWI 0

_main_loop_lose_a_life:
 // subtract a life
	LDR r4, =lives
	LDR r5, [r4]
	SUB r5, r5, #1
	STRB r5, [r4]
	B _main_loop_loop

_main_loop_out_of_lives:
	LDR r0, =game_over
	LDR r1, =game_over_len
	BL print
	LDR r0, =word
	LDR r1, =word_len
	BL print
	BL nl
	B _main_loop_exit

_main_loop_win:
	LDR r0, =you_win
	LDR r1, =you_win_len
	BL print
	BL print_num_lives
	B _main_loop_exit

_start:
	BL gen_hidden_word

	BL main_loop

print_hidden_word:
	PUSH {lr}
	PUSH {r4-r11}

	LDR r0, =hidden_word
	LDR r1, =word_len
	BL print

	POP {r4-r11}
	POP {lr}
	BX lr

print_num_lives:
	PUSH {lr}
	PUSH {r4-r11}

	LDR r0, =num_of_lives
	LDR r1, =num_of_lives_len
	BL print

	LDR r0, =lives
	LDR r0, [r0]
	BL itos
	BL print

	LDR r0, =num_of_lives2
	LDR r1, =num_of_lives2_len
	BL print
	BL nl

	POP {r4-r11}
	POP {lr}
	BX lr

// void print(const char* text, int size)
print:
	PUSH {r4-r11}

	MOV r4, r0 // text
	MOV r5, r1 // size

	MOV r7, #4 // Write
	MOV r0, #1 //stdout
	MOV r1, r4
	MOV r2, r5
	SWI #0 // same as SVC. my sytanx hilighter just doesn't like SVC lol

	POP {r4-r11}
	BX lr
print_implicit:
	PUSH {lr}
	PUSH {r4-r11}

	MOV r4, r0
	BL get_len
	MOV r5, r0
	LDR r6, =temp_buff

	STR r4, [r6]
	MOV r1, #0x10
	MOV r0, r6
	BL print

	POP {r4-r11}
	POP {lr}
	BX lr
nl:
	PUSH {lr}
	PUSH {r4-r11}

	MOV r0, #0xa
	MOV r1, #0x4
	BL print_implicit

	POP {r4-r11}
	POP {lr}
	BX lr

// void gen_hidden_word()
gen_hidden_word:
	PUSH {r4-r11}

	LDR r4, =word
	LDR r5, =hidden_word
	MOV r6, #0 // counter

_gen_hidden_word_loop:
	LDRB r7, [r4, r6] // load current byte
	ADD r6, r6, #1 // store current memory location of hidden_word
	CMP r7, #0x0 // check if ended
	BEQ _gen_hidden_word_leave
	CMP r7, #0x20 // space
	BNE _gen_hidden_word_add_underscore

_gen_hidden_word_add_space:
	MOV r10, #0x20
	STRB r10, [r5, r6]
	B _gen_hidden_word_loop

	_gen_hidden_word_add_underscore:
	MOV r10, #0x5F
	STRB r10, [r5, r6]
	B _gen_hidden_word_loop

	_gen_hidden_word_leave:
//  LDR r5, =hidden_word
//  MOV r10, #0xa // new line
//	ADD r6, r6, #1
//	STRB r9, [r8]
  MOV r0, r5
	POP {r4-r11}
	BX lr
// int get_len(const char* string)
get_len:
	PUSH {r4-r11}

	MOV r4, r0 // word
	MOV r5, #0 // counter
	MOV r6, #0x0 // current byte

_get_len_loop:
	LDRB r6, [r4, r5]
	ADD r5, r5, #1 // increment counter
	CMP r6, #0x0 // see if null (string ended)
	BEQ _get_len_leave
	B _get_len_loop

_get_len_leave:
	MOV r0, r5 // return counter
	POP {r4-r11}
	BX lr
// const char* itos(int num)
itos:
	PUSH {lr}
	PUSH {r4-r11}

	MOV r4, r0 // num

	MOV r5, #0 // counter
	MOV r6, #1000 // current place
	MOV r8, #10 // place divisor

_itos_loop:
	MOV r10, #0
	UDIV r10, r4, r6 // divide current digit by place
	ADD r10, r10, #0x30 // turn into ASCII character

	LDR r9, =temp_buff // where we store the resulting string
	ADD r9, r9,  r5 // add offset to temp_buff
	STRB r10, [r9] // store ASCII character in buff
	ADD r5, r5, #1 // increment counter

	SUB r10, r10, #0x30 // turn back into int
	MUL r11, r10, r6 // multiply the original by the place
	SUB r4, r4, r11 // subtract result from original

	UDIV r11, r6, r8 // divide current place by divisor
	MOV r6, r11
	CMP r6, #0x0 // see if place is 0
	BEQ _itos_leave
	B _itos_loop

_itos_leave:
	MOV r4, #0xa // insert new line
	LDR r7, =temp_buff
	ADD r7, r7, r5 // add offset
	ADD r7, r7, #1 // go to next byte
	STRB r4, [r7]
	LDR r7, =temp_buff
	//MOV r0, r7
	LDR r0, =temp_buff
	BL get_len
	MOV r1, r0
	MOV r0, r7

	POP {r4-r11}
	POP {lr}
	BX lr

prompt_guess:
	PUSH {lr}
	PUSH {r4-r11}

	LDR r0, =prompt
	LDR r1, =prompt_len
	BL print

	BL get_input

	POP {r4-r11}
	POP {lr}
	BX lr


get_input:
	PUSH {r4-r11}

	MOV r7, #3 // Read
	MOV r0, #0 // stdin
	LDR r1, =input
	MOV r2, #0x1
	SWI 0
	LDR r0, =input

	POP {r4-r11}
	BX lr

check_guess:
	PUSH {r4-r11}

	LDR r4, =input
	LDRB r4, [r4]

	LDR r5, =word
	LDR r6, =hidden_word

	MOV r7, #0 // counter
	MOV r8, #0x0 // current byte of real word

	MOV r10, #0 // correctness counter
_check_guess_loop:
	LDRB r8, [r5, r7] // load current byte of real word
	//ADD r6, r6, #1 // increment memory adress
	ADD r7, r7, #1 // increment counter
	CMP r8, #0x0 // see if the word has ended
	BEQ _check_guess_leave
	CMP r8, r4 // compare real word against guess
	BEQ _check_guess_fill
	B _check_guess_loop

_check_guess_fill:
	STRB r4, [r6, r7]
	ADD r10, r10, #1 // add 1 correctness
	B _check_guess_loop

_check_guess_leave:
	MOV r0, r10
	POP {r4-r11}
	BX lr


check_word:
	PUSH {r4-r11}

	LDR r4, =hidden_word
	MOV r5, #0x0 // current byte of hidden_word
	MOV r6, #1 // counter

_check_word_loop:
	LDRB r7, [r4, r6] // load current byte of hidden word
	CMP r7, #0x0 // see if done
	BEQ _check_word_success
	ADD r6, r6, #1 // increment counter
	CMP r7, #0x5F // underscore
	BNE _check_word_loop

_check_guess_failed:
	MOV r0, #0 // return false
	B _check_word_leave

_check_word_success:
	MOV r0, #1 // return true
	B _check_word_leave

_check_word_leave:
	POP {r4-r11}
	BX lr


handle_guess:
	PUSH {lr}
	PUSH {r4-r11}
	MOV r4, #0 // result

	BL prompt_guess
	BL nl
	BL check_guess
	CMP r0, #0 // if (check_guess > 0) { print_congratulations } else { print_failure }
	BNE _handle_guess_congratulations

_handle_guess_failure:
	LDR r0, =failure
	LDR r1, =failure_len
	BL print
	MOV r4, #0
	B _handle_guess_leave


_handle_guess_congratulations:
	LDR r0, =congratulations
	LDR r1, =congratulations_len
	BL print
	MOV r4, #1
	B _handle_guess_leave

_handle_guess_leave:
	MOV r0, r4
	POP {r4-r11}
	POP {lr}
	BX lr

.section .data
// used by print_implicit
temp_buff: .skip 64
// used by get_guess
input: .skip 1 // 1 letter at a time

word:
	.asciz "we le p" // 16 byte word
	word_len = .-word
prompt:
	.asciz "Enter your guess: "
	prompt_len = .-prompt
congratulations:
	.asciz "Good job, you got it right!\n"
	congratulations_len = .-congratulations
failure:
	.asciz "Lmao dumbass, thats minus 1 life for you!\n"
	failure_len = .-failure
game_over:
	.asciz "Game Over. You ran out of lives. The word was: "
	game_over_len = .-game_over
you_win:
	.asciz "You win. Congratulations!\n"
	you_win_len = .-you_win
num_of_lives:
	.asciz "you have "
	num_of_lives_len = .-num_of_lives
num_of_lives2:
	.asciz " lives left"
	num_of_lives2_len = .-num_of_lives2
lives: .int 10
hidden_word: .skip 16
