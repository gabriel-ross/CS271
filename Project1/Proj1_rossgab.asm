TITLE Basic Logic & Artihmetic     (project1.asm)

; Author: Gabriel Ross
; Last Modified: 30-JUN-21
; OSU email address: rossgab@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 1                 Due Date: 11-Jul-21
; Description: This file demonstrates basic arthmetic
; and registry manipulation

INCLUDE Irvine32.inc

.data

myName		BYTE	"Author: Gabriel Ross",0
progName	BYTE	"Project 1: Basic Logic & Arithmetic",0
ec1			BYTE	"**EC: Program repeats until the user chooses to quit",0
ec2			BYTE	"**EC: Program checks if numbers are not in strictly descending order",0
ec3			BYTE	"**EC: Program handles negative results and additionally computes B-A, C-A, C-B, C-B-A",0
ec4			BYTE	"**EC: Program additionally calculates A/B, A/C, B/C, printing both the quotient and remainder",0

notDescMsg	BYTE	"ERROR: The numbers are not in strict descending order.", 0
playAgain	BYTE	"Enter 0 to quit and 1 to continue playing: ",0
byePrompt	BYTE	"Goodbye! Thanks for participating!",0

inputPrompt BYTE	"Enter three numbers, A, B, C, such that A > B > C, and I will calculate the sums, differences, and quotients",0 
promptA		BYTE	"A: ",0
promptB		BYTE	"B: ",0
promptC		BYTE	"C: ",0

inputA		DWORD	?
inputB		DWORD	?
inputC		DWORD	?
signedA		SDWORD	?
signedB		SDWORD	?
signedC		SDWORD	?

; Memory allocations for sums
AaddB		DWORD	?
AsubB		DWORD	?
AaddC		DWORD	?
AsubC		DWORD	?
BaddC		DWORD	?
BsubC		DWORD	?
AaddBaddC	DWORD	?
; Memory allocations for messages introducing sum results
AaddBmsg	BYTE	"A+B: ",0
AsubBmsg	BYTE	"A-B: ",0
AaddCmsg	BYTE	"A+C: ",0
AsubCmsg	BYTE	"A-C: ",0
BaddCmsg	BYTE	"B+C: ",0
BsubCmsg	BYTE	"B-C: ",0
ABCmsg		BYTE	"A+B+C: ",0

; Memory allocations for differences
BsubA		SDWORD	?
CsubA		SDWORD	?
CsubB		SDWORD	?
CsubBsubA	SDWORD	?

; Memory allocations for messages introducing difference results
BsubAmsg	BYTE	"B-A: ",0
CsubAmsg	BYTE	"C-A: ",0
CsubBmsg	BYTE	"C-B: ",0
CBAmsg		BYTE	"C-B-A: ",0

; Memory allocations for quotients and remainders
AdivBq		DWORD	?
AdivBr		DWORD	?
AdivCq		DWORD	?
AdivCr		DWORD	?
BdivCq		DWORD	?
BdivCr		DWORD	?
; Memory allocations for messages introducing div results
AdivBqmsg	BYTE	"A/B quotient: ",0
AdivBrmsg	BYTE	"A/B remainder: ",0
AdivCqmsg	BYTE	"A/C quotient: ",0
AdivCrmsg	BYTE	"A/C remainder: ",0
BdivCqmsg	BYTE	"B/C quotient: ",0
BdivCrmsg	BYTE	"B/C remainder: ",0


.code
main PROC

; Display author name, project name, and instructions
	mov		EDX, OFFSET myName
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET progName
	call	WriteString
	call	CrLf
	call	CrLf
	mov		EDX, OFFSET ec1
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET ec2
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET ec3
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET ec4
	call	WriteString
	call	CrLf
	call	CrLf

; Here to allow user to play again
_start:

	mov		EDX, OFFSET inputPrompt
	call	WriteString
	call	CrLf

; Take number input from user
; EC 2: additionally, verifies that A, B, C are in strict descending order

	mov		EDX, OFFSET promptA
	call	WriteString
	call	ReadDec
	mov		inputA, EAX
	mov		signedA, EAX

	mov		EDX, OFFSET promptB
	call	WriteString
	call	ReadDec
	CMP		EAX, inputA

	JAE		_notStrictDescending
	mov		inputB, EAX
	mov		signedB, EAX

	mov		EDX, OFFSET promptC
	call	WriteString
	call	ReadDec
	CMP		EAX, inputB
	JAE		_notStrictDescending
	mov		inputC, EAX
	mov		signedC, EAX


; Calculate expressions and store results

	; A+B
	mov		EAX, inputA
	add		EAX, inputB
	mov		AaddB, EAX
	; A-B
	mov		EAX, inputA
	sub		EAX, inputB
	mov		AsubB, EAX

	; A+C
	mov		EAX, inputA
	add		EAX, inputC
	mov		AaddC, EAX

	; A-C
	mov		EAX, inputA
	sub		EAX, inputC
	mov		AsubC, EAX

	; B+C
	mov		EAX, inputB
	add		EAX, inputC
	mov		BaddC, EAX

	; B-C
	mov		EAX, inputB
	sub		EAX, inputC
	mov		BsubC, EAX

	; A+B+C
	mov		EAX, inputA
	add		EAX, inputB
	add		EAX, inputC
	mov		AaddBaddC, EAX

; Print expression results

	mov		EDX, OFFSET Aaddbmsg
	call	WriteString
	mov		EAX, AaddB
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET AsubBmsg
	call	WriteString
	mov		EAX, AsubB
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET AaddCmsg
	call	WriteString
	mov		EAX, AaddC
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET AsubCmsg
	call	WriteString
	mov		EAX, AsubC
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET BaddCmsg
	call	WriteString
	mov		EAX, BaddC
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET BsubCmsg
	call	WriteString
	mov		EAX, BsubC
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET ABCmsg
	call	WriteString
	mov		EAX, AaddBaddC
	call	WriteDec
	call	CrLf
	call	CrLf
	

; EC 3: calculate negative results B-A, C-A, C-B, C-B-A
	mov		EAX, inputB
	sub		EAX, inputA
	mov		BsubA, EAX

	mov		EAX, inputC
	sub		EAX, inputA
	mov		CsubA, EAX

	mov		EAX, inputC
	sub		EAX, inputB
	mov		CsubB, EAX


	mov		EAX, signedC
	sub		EAX, signedB
	sub		EAX, signedA
	mov		CsubBsubA, EAX

; EC 3: print negative results  B-A, C-A, C-B, C-B-A

	mov		EDX, OFFSET BsubAmsg
	call	WriteString
	mov		EAX, BsubA
	call	WriteInt
	call	CrLf

	mov		EDX, OFFSET CsubAmsg
	call	WriteString
	mov		EAX, CsubA
	call	WriteInt
	call	CrLf

	mov		EDX, OFFSET CsubBmsg
	call	WriteString
	mov		EAX, CsubB
	call	WriteInt
	call	CrLf

	mov		EDX, OFFSET CBAmsg
	call	WriteString
	mov		EAX, CsubBsubA
	call	WriteInt
	call	CrLf
	call	CrLf

; EC 4: calculate the quotients and remainders A/B, A/C, B/C

	mov		EAX, inputA
	mov		EDX, 0
	DIV		inputB
	mov		AdivBq, EAX
	mov		AdivBr, EDX

	mov		EAX, inputA
	mov		EDX, 0
	DIV		inputC
	mov		AdivCq, EAX
	mov		AdivCr, EDX

	mov		EAX, inputB
	mov		EDX, 0
	DIV		inputC
	mov		BdivCq, EAX
	mov		BdivCr, EDX

; EC 4: print quotients and remainders A/B, A/C, B/C

	mov		EDX, OFFSET	AdivBqmsg
	call	WriteString
	mov		EAX, AdivBq
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET AdivBrmsg
	call	WriteString
	mov		EAX, AdivBr
	call	WriteDec
	call	CrLf
	
	mov		EDX, OFFSET	AdivCqmsg
	call	WriteString
	mov		EAX, AdivCq
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET AdivCrmsg
	call	WriteString
	mov		EAX, AdivCr
	call	WriteDec
	call	CrLf
	
	mov		EDX, OFFSET	BdivCqmsg
	call	WriteString
	mov		EAX, BdivCq
	call	WriteDec
	call	CrLf

	mov		EDX, OFFSET BdivCrmsg
	call	WriteString
	mov		EAX, BdivCr
	call	WriteDec
	call	CrLf
	call	CrLf

	JMP		_playAgain

; EC 2: print error that the inputs were not in strict-descending order
_notStrictDescending:
	mov		EDX, OFFSET	NotDescMsg
	call WriteString
	call CrLf

; EC 1: See if user wants to play again or quit
_playAgain:
	mov		EDX, OFFSET	playAgain
	call	WriteString
	call	ReadDec
	call	CrLf
	CMP		EAX, 1
	JE		_start


; Say goodbye
_goodbye:
	mov		EDX, OFFSET byePrompt
	call	WriteString
	call	CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP


END main
