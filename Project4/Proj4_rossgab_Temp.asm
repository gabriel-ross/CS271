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

; --------------------------------------
; Name: introduction
; Description: Greets the user and introduces the program
; Preconditions: None
; Postconditions: Modifies EDX
; Receives: None
; Returns: None
; --------------------------------------
introduction PROC
	MOV		EDX, OFFSET intro
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	RET
introduction ENDP

; --------------------------------------
; Name: getUserData
; Description: Records user input as to how many primes to display
; Preconditions: None
; Postconditions: Modifies EAX, EBX, EDX
; Receives: None
; Returns: howMany = how many primes to print
; --------------------------------------
getUserData PROC
	_getInp:
		MOV		EDX, OFFSET prompt
		CALL	WriteString
		CALL	ReadDec
		CALL	validateUserInput
		CMP		EBX, 0
		JNE		_getInp
		MOV		howMany, EAX
		RET
getUserData ENDP

; --------------------------------------
; Name: validateUserInput
; Description: Ensures user input is within bounds defined in constants
; Preconditions: User input is an unsigned int and is stored in EAX
; Postconditions: Modifies EAX, EDX, EBX
; Receives: EAX = user's input
; Returns: EBX = 0 if input is valid, 1 if not
; --------------------------------------
validateUserInput PROC
	; If input is within bounds return 0 in EBX
	CMP		EAX, MAX_PRIMES
	JG		_invalidInput
	CMP		EAX, MIN_PRIMES
	JL		_invalidInput
	MOV		EBX, 0
	RET
	; If input is invalid print err message and return 1 in EBX
_invalidInput:
	MOV		EDX, OFFSET err
	CALL	WriteString
	CALL	CrLf
	MOV		EBX, 1
	RET
validateUserInput ENDP

; --------------------------------------
; Name: showPrimes
; Description: Dsiplays the number of primes according to user input
; Preconditions: User has input number of primes and it is stored in howMany
; Postconditions: Modifies EAX, EBX, ECX, EDX
; Receives: howMany = Number of primes to display
; Returns: None
; --------------------------------------
showPrimes PROC
	MOV		ECX, 2
	_numsLoop:

		CALL	isPrime
		CMP		EAX, 1
		JNE		_checkLoopCond
		MOV		EAX, ECX
		CALL	WriteDec
		MOV		EDX, OFFSET space
		CALL	WriteString

		; Check if there are 10 primes on the line, and if so move to next line
		CMP		curLine, 10
		JE		_newLine

		_checkLoopCond:
			; Keeps looping until we have printed enough primes
			INC		ECX
			MOV		EBX, primes
			CMP		EBX, howMany
			JB		_numsLoop
		RET
	_newLine:
		CALL	CrLf
		MOV		curLine, 0
		INC		curRows
		CMP		curRows, 20
		JE		_newPage
		JMP		_checkLoopCond

	_newPage:
		CALL	WaitMsg
		CALL	Clrscr
		MOV		curRows, 0
		JMP		_checkLoopCond

showPrimes ENDP

; --------------------------------------
; Name: isPrime
; Description: Checks if current number is prime by dividing it between all numbers in the range [2, curNum) and checking the remainder value
; Preconditions: Number to be checked is in ECX
; Postconditions: Modifies EAX
; Receives: ECX = Number to be checked
; Returns: EAX = 1 if number is prime, 0 if not
; --------------------------------------
isPrime PROC
	MOV		curNum, ECX
	MOV		ECX, 2

	; Since this procedure checks the number between 1 and curNum it won't work for 2, so we catch that edge case
	CMP		curNum, 2
	JE		_isPrime

	_findFactorsLoop:
		MOV		EAX, curNum
		MOV		EDX, 0
		DIV		ECX
		CMP		EDX, 0 ; If remainder is zero curNum is not prime
		JE		_isNotPrime
		INC		ECX
		CMP		ECX, curNum
		JB		_findFactorsLoop
	; If we've found no divisors of curNum in the range [2, curNum) then curNum is prime
	_isPrime:
		MOV		EAX, 1
		INC		primes
		MOV		ECX, curNum
		INC		curLine
		RET
	_isNotPrime:
		MOV		EAX, 0
		MOV		ECX, curNum
		RET

isPrime	ENDP


; --------------------------------------
; Name: farewell
; Description: Says goodbye to the user
; Preconditions: None
; Postconditions: Modifies EDX
; Receives: None
; Returns: None
; --------------------------------------
farewell PROC
	CALL	CrLf
	CALL	CrLf
	MOV		EDX, OFFSET bye
	CALL	WriteString
	CALL	CrLf
	RET
farewell ENDP

END main
