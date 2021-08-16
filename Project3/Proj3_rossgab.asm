TITLE Project 3: Data Validation, Looping, and Constants     (Proj3_rossgab.asm)

; Author: Gabriel Ross
; Last Modified: 
; OSU email address: rossgab@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 3                Due Date: 18-Jul-21
; Description: Program asks user for their name, then repeatedly asks the user
; for a number in [-200, -100] or [-50, -1] inclusive. When a non-negative number
; is entered the program reports the number of inputs and the min, max, sum, and 
; rounded average of the inputs.

INCLUDE Irvine32.inc

; Constants
LOWER_BOUND_1 = -200
UPPER_BOUND_1 = -100
LOWER_BOUND_2 = -50
UPPER_BOUND_2 = -1

.data

; Prompt/info strings
intro	BYTE	"Project 3: Data Validation, Looping, and Constants by Gabriel Ross",0
ec1		BYTE	"EC1: Program numbers the lines during user input, only incrementing on valid inputs",0
getName	BYTE	"What is your name? ",0
greet	BYTE	"Hello there, ",0
ranges	BYTE	"Please enter numbers in [-200, -100] or [-50, -1].",0
isDone	BYTE	"Enter a non-negative number when you are finished to see results.",0
inpNum	BYTE	": Enter number: ",0
invalid	BYTE	"Number invalid!",0
noNums	BYTE	"No valid numbers entered",0
bye		BYTE	"Goodbye and thanks for playing, ",0

; User inputs
uName	BYTE	80 DUP(0)
uNameSz	DWORD	?
userInp	SDWORD	?
max		SDWORD	LOWER_BOUND_1 - 1
min		SDWORD	UPPER_BOUND_2 + 1
count	SDWORD	0
sum		SDWORD	0
avg		SDWORD	0
avgRem	SDWORD	?

; Result strings
numOut1	BYTE	"You entered ",0
numOut2	BYTE	" valid numbers.",0
maxOut	BYTE	"The maximum valid number is ",0
minOut	BYTE	"The minimum valid nuymber is ",0
sumOut	BYTE	"The sum of your valid numbers is ",0
avgOut	BYTE	"The rounded average is ",0


.code
main PROC

; Introduce program
MOV		EDX, OFFSET intro
CALL	WriteString
CALL	CrLf
MOV		EDX, OFFSET ec1
CALL	WriteString
CALL	CrLf
; Take user's name
MOV		EDX, OFFSET getName
CALL	WriteString
MOV		EDX, OFFSET uName
MOV		ECX, SIZEOF	uName
CALL	ReadString
MOV		uNameSz, EAX
CALL	CrLf
; Greet user
MOV		EDX, OFFSET greet
CALL	WriteString
MOV		EDX, OFFSET uName
CALL	WriteString
CALL	CrLf
CALL	CrLf
; Explain rules
MOV		EDX, OFFSET ranges
CALL	WriteString
CALL	CrLf
MOV		EDX, OFFSET isDone
CALL	WriteString
CALL	CrLf
CALL	CrLf


; Take user inputs
_takeInputs:
	MOV		EAX, count
	ADD		EAX, 1
	CALL	WriteDec
	MOV		EDX, OFFSET inpNum
	CALL	WriteString
	CALL	ReadInt
	MOV		userInp, EAX
	JMP		_checkExit	; Checks if input is above zero


; Check if user input is non-negative and jump to validate the input/goodbye as necessary
_checkExit:
	CMP		userInp, 0
	JGE		_calcAvg
	JMP		_checkValid	; Validate input if below zero


; Validate user input if below zero
_checkValid:
	; Check if number is between -200 & -1
	CMP		userInp, LOWER_BOUND_1
	JL		_invalidInp
	CMP		userInp, UPPER_BOUND_2
	JG		_invalidInp
	; if num is between -200 & -1, if it is leq -100 or geq -50 then it is valid, otherwise invalid
	CMP		userInp, UPPER_BOUND_1
	JLE		_validInp
	CMP		userInp, LOWER_BOUND_2
	JGE		_validInp
	; number is in (-100, -50) and is thus invalid
	JMP		_invalidInp


; Input is valid. Recalc max, min, sum. Increment count
_validInp:
	; increment count and add input to sum
	INC		count
	MOV		EAX, userInp
	ADD		sum, EAX
	; compare input against current max and min and updates as necessary

	MOV		EAX, userInp
	CMP		EAX, max
	JLE		_notMax
	MOV		max, EAX
_notMax:
	CMP		EAX, min
	JGE		_notMin
	MOV		min, EAX
	; loop back to take another input
_notMin:
	JMP		_takeInputs


; Input is invalid
_invalidInp:
	MOV		EDX, OFFSET invalid
	CALL	WriteString
	CALL	CrLf
	JMP		_takeInputs
	

; Calculate average
_calcAvg:
	; jump to goodbye if no nums entered
	CMP		count, 0
	jz		_goodbye
	; otherwise calculate average and go to display results
	MOV		EAX, 0
	MOV		EDX, 0
	MOV		EAX, sum
	CDQ
	IDIV	count
	MOV		avg, EAX
	; properly round
	MOV		avgRem, EDX
	MOV		EBX, -2
	MOV		EAX, count
	CDQ
	IDIV	EBX
	MOV		EBX, avgRem
	CMP		EBX, EAX
	JL		_roundUp
	JMP		_displayResults
_roundUp:
	DEC		avg
	

; Display results
_displayResults:
	; Number of inputs recorded
	MOV		EDX, OFFSET numOut1
	CALL	WriteString
	MOV		EAX, count
	CALL	WriteDec
	MOV		EDX, OFFSET numOut2
	CALL	WriteString
	CALL	CrLf
		; Max of inputs
	MOV		EDX, OFFSET maxOut
	CALL	WriteString
	MOV		EAX, max
	CALL	WriteInt
	CALL	CrLf
		; Min of inputs
	MOV		EDX, OFFSET minOut
	CALL	WriteString
	MOV		EAX, min
	CALL	WriteInt
	CALL	CrLf
		; Sum of inputs
	MOV		EDX, OFFSET sumOut
	CALL	WriteString
	MOV		EAX, sum
	CALL	WriteInt
	CALL	CrLf
		; Avg of inputs
	MOV		EDX, OFFSET avgOut
	CALL	WriteString
	MOV		EAX, avg
	CALL	WriteInt
	CALL	CrLf


; Goodbye
_goodbye:
	CALL	CrLf
	MOV		EDX, OFFSET bye
	CALL	WriteString

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
