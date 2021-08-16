TITLE Project 6: String Primitives & Macros     (rossgab.asm)

; Author: Gabriel Ross
; Last Modified: 12-Aug-21
; OSU email address: rossgab@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number: 6                Due Date: 13-Aug-21
; Description: This program prompts the user for 10 32-bit integers,
; takes the user input as ASCII strings, validates they are valid integers, and converts them 
; to a SWORDs for processing,then converts them back to ASCII strings for processing. Additionally, 
; the program calculates the sum and average of the input integers and prints them by converting
; them to ASCII strings.

INCLUDE Irvine32.inc

;-----------------------------------------------------
; Name: mGetString
; Description: prints a prompt, then takes user input and stores it 
; in the provided location
; Preconditions: prompt, output array, and output length are passed by reference
; Postconditions: None
; Receives: 
;		prompt = memory offset of prompt string to be displayed
;		inpAddr = memory offset of byte array where suer input will be stored
;		maxLen = length of BYTE array where string will be stored
;		outLen = number of characters user entered
; Returns: None
;-----------------------------------------------------
mGetString MACRO prompt:REQ, inpAddr:REQ, maxLen:REQ, outLen:REQ

	PUSH	EAX
	PUSH	ECX
    PUSH    EDX

    MOV     EDX, prompt
    CALL    WriteString

	MOV		EDX, inpAddr
	MOV		ECX, maxLen
	CALL	ReadString
	MOV		outLen, EAX

	POP     EDX
	POP		ECX
	POP		EAX
ENDM


;-----------------------------------------------------
; Name: mDisplayString
; Description: prints the string at the given memory offset
; Preconditions: input is BYTE string passed by reference
; Postconditions: None
; Receives: 
;		strOffset = memory offset of BYTE string to be printed
; Returns: None
;-----------------------------------------------------
mDisplayString MACRO strOffset:REQ

	PUSH	EDX

	MOV		EDX, strOffset
	CALL	WriteString

	POP		EDX

ENDM


ASCII_ZERO = 48
ASCII_NINE = 57
ASCII_PLUS = 43
ASCII_MINUS = 45

.data

projIntro	BYTE	"Project 6: String Primitives and Macros",0
author		BYTE	"By Gabriel Ross",0
instruct	BYTE	"Please provide 10 signed decimal integers. This program will display the list of integers, their sum, and their average.",0
constraint	BYTE	"Each integer must be able to fit in a 32-bit register.",0
inPrompt	BYTE	"Enter a signed integer: ",0
error		BYTE	"ERROR: You entered an invalid character or your integer was too big.",0
space		BYTE	", ",0
entered		BYTE	"You entered the following numbers: ",0
sumStr		BYTE	"The sum of these numbers is: ",0
avgStr		BYTE	"The floor-rounded average is: ",0
bye			BYTE	"Thanks for playing",0
retry		BYTE	"Please try again: ",0

userInp		BYTE	13 DUP(0)
inpSize		DWORD	?
validVals	SDWORD	5 DUP(0)
; temp string for SDWORD to string conversions
numToStr	BYTE	LENGTHOF userInp DUP(0)

.code
main PROC
;----------------------------
; introduce program and display instructions
;----------------------------
	mDisplayString	OFFSET projIntro
	CALL			CrLf
	mDisplayString	OFFSET author
	CALL			CrLf
	CALL			CrLf
	mDisplayString	OFFSET instruct
	CALL			CrLf
	mDisplayString	OFFSET constraint
	CALL			CrLf
	CALL			CrLf

;----------------------------
; collect 10 valid inputs from user and store them
; in the array validVals
;----------------------------
	MOV				ECX, LENGTHOF validVals
	MOV				EDI, OFFSET validVals
_collectInp:
	PUSH			OFFSET retry
	PUSH			OFFSET inPrompt
	PUSH			OFFSET userInp
	PUSH			OFFSET inpSize
	PUSH			SIZEOF userInp
	PUSH			EDI 
	PUSH			OFFSET error
	CALL			readVal
	ADD				EDI, TYPE validVals
	LOOP			_collectInp

;----------------------------
; print values from validVals
;----------------------------
	MOV				ECX, LENGTHOF validVals
	DEC				ECX ; last element will be printed outside of loop so it is not followed by a comma
	MOV				ESI, OFFSET validVals
	mDisplayString OFFSET entered
	CALL			CrLf
_printValidVals:
	PUSH			[ESI]
	PUSH			OFFSET numToStr
	PUSH			LENGTHOF numToStr
	CALL			writeVal
	mDisplayString OFFSET space
	ADD				ESI, TYPE validVals
	LOOP			_printValidVals
	; Inserted outside loop so last integer isn't followed by a comma
	PUSH			[ESI]
	PUSH			OFFSET numToStr
	PUSH			LENGTHOF numToStr
	CALL			writeVal
	CALL			CrLf

;----------------------------
; calculate sum and average of elements in validVals
;----------------------------
	PUSH			OFFSET validVals
	PUSH			LENGTHOF validVals
	PUSH			TYPE validVals
	CALL			calcSumAndAvg ; returns sum & avg in EBX & EAX respectively

;----------------------------
; display sum
;----------------------------
	mDisplayString OFFSET sumStr
	PUSH			EBX
	PUSH			OFFSET numToStr
	PUSH			LENGTHOF numToStr
	CALL			writeVal
	CALL			CrLf

;----------------------------
; display average
;----------------------------
	mDisplayString OFFSET avgStr
	PUSH			EAX
	PUSH			OFFSET numToStr
	PUSH			LENGTHOF numToStr
	CALL			writeVal
	CALL			CrLf
	
;----------------------------
; print outro
;----------------------------
	CALL			CrLf
	mDisplayString	OFFSET bye


	Invoke ExitProcess,0	; exit to operating system
main ENDP


;-----------------------------------------------------
; Name: readVal
; Description: Reads user input as a string, validates that it is a valid
; ASCII representation of an integer, and stores the resulting SWORD integer
; at the memory location provided as an argument
; Preconditions: 
;		- user input variable is a BYTE array
;		- [EBP+40, 36, 24, 20] are memory addresses
; Postconditions: None
; Receives: 
;		;EBP+44] = memory offset of input prompt to be shown after an invalid input
;		[EBP+40] = memory offset of input prompt
;		[EBP+36] = memory offset of where to store raw user input
;		[EBP+32] = where to store length of user input
;		[EBP+28] = max size of user input
;		[EBP+24] = memory offset of where to store processed user input
;		[EBP+20] = memory offset of error message to be displayed upon invalid input
; Returns: None
;-----------------------------------------------------
readVal PROC USES EAX EDX EDI
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDI, [EBP+24]

	; get user input
	mGetString [EBP+40], [EBP+36], [EBP+28], [EBP+32]
_validateInp:
	; Check if input is too long to be a SWORD number
	MOV		EAX, [EBP+32]
	DEC		EAX
	CMP		EAX, [EBP+28]
	JG		_inpTooLarge

	; convert to integer/validate using parseInt procedure
	PUSH	[EBP+36] ; Memory offset where we stored raw user input
	PUSH	[EBP+32] ; Length of user input
	CALL	parseInp

	; If input is valid store it in given location and return
	CMP		EDX, 0
	JE		_validInp
_inpTooLarge:
	MOV		EDX, [EBP+20]
	mDisplayString [EBP+20]
	CALL	CrLf
	mGetString [EBP+44], [EBP+36], [EBP+28], [EBP+32]
	JMP		_validateInp

_validInp:
	MOV		[EDI], EAX ; store SWORD repr of number in given location
	POP		EBP	
	RET		24
readVal ENDP


;-----------------------------------------------------
; Name: parseInp
; Description: Helper function for readVal. Parses input string of ASCII characters,
; validates it is an ASCII representation of an integer, and converts it to SDWORD value
; Preconditions: 
;		- input string is BYTE array
;		- [EBP+24] is a memory address
; Postconditions: Modifies EAX, EDX
; Receives: 
;		[EBP+24] = memory offset where input string is stored
;		[EBP+20] = size of user input 
; Returns: 
;		[EAX] = SWORD representation of input if input was valid
;		[EDX] = 0 if input was valid and fully parsed, 1 if input was invalid
;-----------------------------------------------------
parseInp PROC USES EBX ECX ESI

	PUSH	EBP
	MOV		EBP, ESP

	MOV		EBX, 0 ; Will carry running total
	MOV		EDX, 1 ; Will be used as a flag as to sign of input
	MOV		ECX, [EBP+20]
	MOV		ESI, [EBP+24]
	CLD	; Clear direction flag so we are iterating left -> right

	; check if first character is a sign
	MOV		EAX, 0
	LODSB
	CMP		AL, ASCII_MINUS
	JE		_negSign
	CMP		AL, ASCII_PLUS
	JE		_posSign
	DEC		ESI
	JMP		_parsePos

_negSign:
	DEC		ECX
	JMP		_parseNeg

_posSign:
	DEC		ECX
	JMP		_parsePos

_parseNeg:
	; if ASCII code is out of range [48, 58] the code does not correspond to a number in the range [0,9] and is invalid
	LODSB	; Moves char into AL
	CMP		AL, ASCII_NINE
	JA		_invalidInp
	CMP		AL, ASCII_ZERO
	JL		_invalidInp

	IMUL	EBX, 10
	JO		_invalidInp
	SUB		EAX, 48
	NEG		EAX
	ADD		EBX, EAX
	JO		_invalidInp

	LOOP	_parseNeg

	MOV		EAX, EBX
	MOV		EDX, 0
	JMP		_return


_parsePos:
	; if ASCII code is out of range [48, 58] the code does not correspond to a number in the range [0,9] and is invalid
	LODSB	; Moves char into AL
	CMP		AL, ASCII_NINE
	JA		_invalidInp
	CMP		AL, ASCII_ZERO
	JL		_invalidInp

	IMUL	EBX, 10
	JO		_invalidInp
	SUB		EAX, 48
	ADD		EBX, EAX
	JO		_invalidInp

	LOOP	_parsePos

	MOV		EAX, EBX
	MOV		EDX, 0
	JMP		_return


; returning EDX w/ value != 0 indicates an invalid input
_invalidInp:
	MOV		EAX, 0
	MOV		EDX, 1
	JMP		_return

_return:
	POP		EBP
	RET		8

parseInp ENDP


;-----------------------------------------------------
; Name: writeVal
; Description: Takes in a SDWORD integer, converts the integer to a string, and prints it
; Preconditions: 
;		- input is SDWORD, passed by value
;		- temp array where string is built is type BYTE
; Postconditions: None
; Receives: 
;		[EBP+32] = SWORD integer to be printed
;		[EBP+28] = memory offset of byte array to store in-process string repr of integer
;		[EBP+24] = total length of byte array where string will be stored
; Returns: None
;-----------------------------------------------------
writeVal PROC USES EAX ECX EDX EDI
	PUSH	EBP
	MOV		EBP, ESP

	; Store last index of string array in EDI
	MOV		EDI, [EBP+28]
	ADD		EDI, [EBP+24]
	STD ; set direction flag as we will be writing the string right -> left

	; Zero-terminate string
	MOV		AL, 0
	STOSB

	; digest the absolute value of the number and add an appropriate sign after
	MOV		EAX, [EBP+32]
	MOV		ECX, 10
	CMP		EAX, 0
	JG		_divide
	NEG		EAX
	
; continually divide the number by 10 to pull out the ones place, convert to ASCII repr, and store in a string from right -> left
_divide:
	CDQ
	IDIV	ECX
	
	; helper procedure allows us to use String primitives without having to preserve
	; EAX here
	PUSH	EDX
	CALL	storeInString

	; if the remainder (in EAX) is zero we have converted all digits to corresponding ASCII codes
	CMP		EAX, 0
	JNE		_divide

	; check if input was negative and add sign if so
	MOV		EAX, [EBP+32]
	CMP		EAX, 0
	JL		_isNeg
	JMP		_printNum

; if the input number was negative we add a sign in front of the string
_isNeg: 
	MOV		AL, ASCII_MINUS
	STOSB

_printNum:
	; because of how EDI is decremented in the loop it will be one byte before where the string starts so we must increment
	INC		EDI
	mDisplayString EDI
	POP		EBP	
	RET		12

writeVal ENDP



;-----------------------------------------------------
; Name: storeInString
; Description: Helper function for writeVal that takes in a digit value in [0,9], converts it to ASCII, and
; stores it at the memory address pointed to by EDI, then decrements EDI
; Preconditions: EDI contains correct index in string to store number
; Postconditions: Modifies EDI (decrements it)
; Receives: 
;		[EBP+12] = the number to be converted to ASCII & stored in string
; Returns: None
;-----------------------------------------------------
storeInString PROC USES EAX

	PUSH	EBP
	MOV		EBP, ESP

	MOV		EAX, [EBP+12]
	ADD		EAX, 48 ; add 48 to convert to corresponding ASCII code
	STOSB

	POP		EBP
	RET		4
storeInString ENDP


;-----------------------------------------------------
; Name: calcSumAndAvg
; Description: Calculates sum and average of input array of SDWORD numbers
; Preconditions: Input array is filled with integers
; Postconditions: Modifies EAX, EBX
; Receives: 
;		[EBP+28] = Offset of input array
;		[EBP+24] = length of input array
;		[EBP+20] = Data type of input array
; Returns: 
;		[EAX] = average of elements of input array
;		[EBX] = sum of elements of input array
;-----------------------------------------------------
calcSumAndAvg PROC USES ECX EDX ESI

	PUSH	EBP
	MOV		EBP, ESP

	MOV		EAX, 0
	MOV		ESI, [EBP+28]
	MOV		ECX, [EBP+24]

_iterate:
	; sum all elements in array
	ADD		EAX, [ESI]
	ADD		ESI, [EBP+20]

	LOOP	_iterate

	; divide sum by number of elements and return both sum and average
	MOV		EBX, EAX
	CDQ
	MOV		ECX, [EBP+24]
	IDIV	ECX

	POP		EBP
	RET		12

calcSumAndAvg ENDP



END main

