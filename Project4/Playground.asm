TITLE Project 4: Nested Loops and Procedures    (Proj4_rossgab.asm)

; Author: Gabriel Ross
; Last Modified: 
; OSU email address: rossgab@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 4                Due Date:
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc


MIN_PRIMES = 1
MAX_PRIMES = 4000

.data

; Strings for prompts
intro	BYTE	"Project 4: Prime numbers by Gabriel Ross",0
ec2		BYTE	"**EC2: Program can receive requests for up to 4000 prime numbers and displays 20 rows of results per-page",0
prompt	BYTE	"Enter the number of primes to show, in the range [1, 4000]: ",0
space	BYTE	"   ",0 
err		BYTE	"Number out of range.",0
bye		BYTE	"Hope you enjoyed all those primes. Goodbye!",0

; members for tracking runtime numbers
howMany	DWORD	?	; Number of primes to show
curLine	DWORD	?	; Number of primes on current line
curRows	DWORD	0	; Number of rows printed thus far
curNum	DWORD	?	; Current num we are examining if prime or not
primes	DWORD	0	; Number of primes we've printed


.code
main PROC

	CALL	introduction

	CALL	getUserData

	CALL	showPrimes

	; TO DO:
		; EC
		; GO OVER DOCUMENTATION

	CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

showPrimes PROC
	MOV		ECX, howMany
	MOV		curNum, 2
	_showPrimesLoop:

		CALL	isPrime
		CMP		EAX, 1
		JNE		_incrementAndLoop
		; We found a prime
		MOV		EAX, curNum
		CALL	WriteDec
		MOV		EDX, OFFSET space
		CALL	WriteString
		INC		curLine
		CMP		curLine, 10
		JE		_newLine

	; if no prime found increment ECX, increment num
		

		_incrementAndLoop:
			INC		curNum
			LOOP	_showPrimesLoop

		_newLine:
			CALL	CrLf
			MOV		curLine, 0
			JE		_newPage
			JMP		_incrementAndLoop
		

showPrimes ENDP


END main
