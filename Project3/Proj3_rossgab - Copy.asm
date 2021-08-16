TITLE Program Template     (template.asm)

; Author: Gabriel Ross
; Last Modified: 
; OSU email address: rossgab@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:                 Due Date:
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

.data

; Constants
LOWER_BOUND_1 = -200
UPPER_BOUND_1 = -100
LOWER_BOUND_2 = -50
UPPER_BOUND_2 = -1

; Prompt strings
intro	BYTE	"Project 3: Data Validation, Looping, and Constants by Gabriel Ross",0
getName	BYTE	"What is your name? ",0
greet	BYTE	"Hello there, ",0
ranges	BYTE	"Please enter numbers in ",0
isDone	BYTE	"Enter a non-negative number when you are finished to see results.",0
num		BYTE	"Enter number: ",0
invalid	BYTE	"Number invalid!",0
noNums	BYTE	"No valid numbers entered",0
bye		BYTE	"Goodbye and thanks for playing, ",0

; Name
name	BYTE	80	DUP(?)

; Max, min, and number of entries
max		SDWORD	UPPER_BOUND_2 + 1
min		SDWORD	LOWER_BOUND_1 - 1
inp		SDWORD	?
count	WORD	0
sum		SDWORD	0
avg		SDWORD	0

.code
main PROC

; Introduction
MOV		EDX, OFFSET intro
CALL	WriteString
CALL	CrLf
; prompt user for name
MOV		EDX, OFFSET getName
CALL	Writestring
CALL	CrLf
; take user's name

; Instructions
MOV		EDX, OFFSET ranges
CALL	WriteString
MOV		EDX, "[",0
CALL	WriteString
MOV		EAX, LOWER_BOUND_1
CALL	WriteInt
MOV		EDX, ",",0
CALL	WriteString
MOV		EAX, UPPER_BOUND_1
CALL	WriteInt


MOV		EDX, OFFSET isDone
CALL	WriteString

_takeInput:
	MOV		EDX, OFFSET num
	CALL	WriteString
	CALL	CrLf
	CALL	ReadInt
	MOV		inp, EAX

_validate:
	; input greater than zero
	MOV		EAX, 0
	CMP		EAX, inp
	JG		results
	; input is in bounds
	MOV		EAX, UPPER_BOUND_2
	CMP		EAX, inp
	JG		invalid

	MOV		EAX, LOWER_BOUND_2
	CMP		EAX, inp
	JGE		isValid

	MOV		EAX, UPPER_BOUND_1
	CMP		EAX, inp
	JG		invalid

	MOV		EAX, LOWER_BOUND_1
	CMP		EAX, inp
	JGE		isValid
	; else: input out of bounds
	JMP		invalid

; Input is valid. Recalc avg, count, sum, check for max and min
_isValid:
	ADD		sum, inp
	INC		count
	; recalc avg

	MOV		EAX, max
	CMP		EAX, inp
	JG		notMax
	MOV		max, inp
_notMax:
	MOV		EAX, min
	CMP		EAX, inp
	JL		takeInput
	MOV		min, inp

_invalid:
	MOV		EDX, OFFSET invalid
	CALL	WriteString
	JMP		takeInput

_results:
	;;

; Goodbye
_goodbye:
	;;

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
