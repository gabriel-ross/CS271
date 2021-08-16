TITLE Project 5: Arrays, Addressing, and Stack-Passed Parameters     (proj5_rossgab.asm)

; Author: Gabriel Ross
; Last Modified: 31-Jul-21
; OSU email address: rossgab@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5                Due Date: 08-Aug-21
; Description: This program generates a random array, prints it, sorts it in 
; ascending order, prints the sorted array's median and the sorted array itself, 
; then prints the number of instances of each number in the sorted array.

INCLUDE Irvine32.inc


HI = 29
LO = 10
ARRAY_SIZE = 200

.data
; intro, title, and outro strings
prog	BYTE	"Project 5: Arrays, Addressing, and Stack-Passed Parameters. By Gabriel Ross.",0
desc	BYTE	"This program generates a random array of length 200 with integers in the range [10, 29] and displayes the random list.",0
desc2	BYTE	"It then sorts the list in ascending order and displayes the median value, the sorted list, and the number of occurrences of each number.",0
randArr	BYTE	"Unsorted array:",0
space	BYTE	" ",0
med		BYTE	"Median value of the sorted array:",0
sorted	BYTE	"Sorted array:",0
numOf	BYTE	"Number of instances of each number in the provided random range:",0
bye		BYTE	"Glad you made it this far. Thanks for reading!",0

; memory allocations for array to be sorted and array containing number of instances of each number
array	DWORD	ARRAY_SIZE	DUP(?)
counts	DWORD	HI+1-LO	DUP(?)


.code
main PROC

; Print intro
	PUSH	OFFSET prog
	PUSH	OFFSET desc
	PUSH	OFFSET desc2
	CALL	intro

	; Generate random array
	PUSH	HI
	PUSH	LO
	PUSH	ARRAY_SIZE
	PUSH	OFFSET array ; Mem offset of empty array to be filled
	PUSH	TYPE array
	CALL	genRandArray

	; Display random array
	PUSH	OFFSET randArr ; String introducing rand array, not the array itself
	PUSH	ARRAY_SIZE
	PUSH	OFFSET array
	PUSH	TYPE array
	CALL	printArray

	; Sort array
	PUSH	OFFSET array
	PUSH	ARRAY_SIZE
	PUSH	TYPE array
	CALL	sortArray

	; Calculate and display median of sorted array
	PUSH	OFFSET med
	PUSH	OFFSET array
	PUSH	ARRAY_SIZE
	PUSH	TYPE array
	CALL	displayMedian

	; Display sorted array
	PUSH	OFFSET sorted 
	PUSH	ARRAY_SIZE
	PUSH	OFFSET array
	PUSH	TYPE array
	CALL	printArray

	; Count instances of each number
	PUSH	OFFSET array
	PUSH	ARRAY_SIZE
	PUSH	OFFSET counts
	PUSH	TYPE array
	CALL	countArray

	; Print counts array
	PUSH	OFFSET numOf
	PUSH	HI+1-LO
	PUSH	OFFSET counts
	PUSH	TYPE counts
	CALL	printArray

	; Say goodbye
	PUSH	OFFSET bye
	CALL	writeThis

	Invoke ExitProcess,0	; exit to operating system
main ENDP


;-----------------------------------------------------
; Name: intro
; Description: Prints the title of the program and explains what it does to the user
; Preconditions: Title and description are strings stored on stack in order: title, first half description, second half description
; Postconditions: None
; Receives:
;		[EBP+20] = Title of program
;		[EBP+16] = First half of description
;		[EBP+12] = Second half of description
; Returns: None
;-----------------------------------------------------
intro PROC USES EDX
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP+20]
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, [EBP+16]
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, [EBP+12]
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	POP		EBP
	RET		12
intro ENDP

;-----------------------------------------------------
; Name: genRandArray
; Description: Generates an array of passed size filled with random numbers in the passed range
; Preconditions: Arguments passed on stack in order: upper range, lower range, array size, array offset, data type of array
; Postconditions: None
; Receives:
;		[EBP+36] = upper range of the random nums 
;		[EBP+32] = lower range of the random nums
;		[EBP+28] = size of array to be filled
;		[EBP+24] = memory offset of output array to be filled
;		[EBP+20] = data type contained in array
; Returns: Array passed as argument, filled with random numbers
;-----------------------------------------------------
genRandArray PROC USES EAX ECX EDI
	PUSH	EBP
	MOV		EBP, ESP

	MOV		ECX, [EBP+28]
	MOV		EDI, [EBP+24]
	CALL	Randomize
	_fillarray:
	; gen rand num
	MOV		EAX, HI+1-LO
	CALL	RandomRange
	ADD		EAX, LO
	; move to mem address contained in [EDI]
	MOV		[EDI], EAX
	; move to next index
	ADD		EDI, [EBP+20]
	LOOP	_fillArray

	POP		EBP
	RET		20
genRandArray ENDP


;-----------------------------------------------------
; Name: printArray
; Description: Prints given array to console with one space between each integer and 20 integers per line
; Preconditions: 
;		Arguments passed on stack in order: array title, array size, array address, data type of array
;		Array filled with DWORD integers
; Postconditions: None
; Receives:
;		[EBP+40] = title of array being printed
;		[EBP+36] = size of array being printed
;		[EBP+32] = memory address of first index of array to be printed
;		[EBP+28] = data type contained in array
; Returns: None
;-----------------------------------------------------
printArray PROC USES EAX EBX ECX EDX ESI
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP+40]
	CALL	WriteString
	CALL	CrLf
	
	MOV		EBX, 0 ; Counts number of ints on current line
	MOV		ECX, [EBP+36]
	MOV		ESI, [EBP+32]
	_iterateOverArr:
	CMP		EBX, 20
	JE		_newLine
	_newLineChecked:
	; Print int from current index in array
	MOV		EAX, [ESI]
	CALL	WriteDec
	; Write a space in between integers
	MOV		EDX, OFFSET space
	CALL	WriteString
	
	INC		EBX
	ADD		ESI, [EBP+28]
	LOOP	_iterateOverArr
	JMP		_return

	; If number of ints on current line is 20 go to new line and reset counter
	_newLine:
	CALL	CrLf
	MOV		EBX, 0
	JMP		_newLineChecked

	_return:
	CALL	CrLf
	CALL	CrLf
	POP		EBP
	RET		16
printArray ENDP


;-----------------------------------------------------
; Name: sortArray
; Description: Sorts the input array using bubble sort
; Preconditions: 
;		Arguments passed on stack in order: memory address of array, size of array, data type of array
;		Array filled with DWORD integers
; Postconditions:
; Receives:
;		[EBP+36] = Memory offset of first index of arrau
;		[EBP+32] = Size of array
;		[EBP+28] = data type of contained array
; Returns:
;-----------------------------------------------------
sortArray PROC USES EAX EBX ECX EDI ESI
	PUSH	EBP
	MOV		EBP, ESP

	

	MOV		ECX, [EBP+32]
	DEC		ECX
	
	_iterate:
	MOV		EBX, ECX ; Preserve ECX
	; ESI will contain mem. address of current index in array
	; EDI will contain mem. address of next index in array
	MOV		ESI, [EBP+36]
	MOV		EDI, ESI
	ADD		EDI, [EBP+28]
	_innerLoop:
	MOV		EAX, [ESI]
	; Compare the current value to the next value in the array
	CMP		EAX, [EDI]
	JA		_swap
	_nextIdx:
	; Move to next index in array
	MOV		ESI, EDI
	ADD		EDI, [EBP+28]
	LOOP	_innerLoop
	MOV		ECX, EBX ; Restore ECX
	LOOP	_iterate

	JMP		_return

	; Swap the values at the two indices
	_swap:
	PUSH	ESI
	PUSH	EDI
	CALL	exchangeEle
	JMP		_nextIdx

	_return:
	POP		EBP
	RET		8
sortArray ENDP


;-----------------------------------------------------
; Name: exchangeEle
; Description: Swaps the values of two memory addresses
; Preconditions: Arguments are memory addresses passed on the stack
; Postconditions: Modifies the array(s) passed in
; Receives: 
;		[EBP+28] = Memory address of first element 
;		[EBP+24] = Memory address of second element
; Returns: None
;-----------------------------------------------------
exchangeEle PROC USES EAX EBX EDI ESI
	PUSH	EBP
	MOV		EBP, ESP

	; Move the memory offsets to be swapped into ESI & EDI
	MOV		ESI, [EBP+28]
	MOV		EDI, [EBP+24]

	; Move the values to be swapped into EAX & EBX
	MOV		EAX, [ESI]
	MOV		EBX, [EDI]

	; Swap the values
	MOV		[EDI], EAX
	MOV		[ESI], EBX

	POP		EBP
	RET		8
exchangeEle ENDP


;-----------------------------------------------------
; Name: displayMedian
; Description: Calculates and displayes the median of the input array. If array size is even it uses the average of the two middle values.
; Preconditions: 
;		Arguments are passed on the stack in order: title, memory address of array, size of array, data type of array
;		Input array is an array of integers
;		Title is string
; Postconditions: None
; Receives:
;		[EBP+36] = title
;		[EBP+32] = Memory offset of first index of input array
;		[EBP+28] = Size of input array
;		[EBP+24] = data type of input array
; Returns: None
;-----------------------------------------------------
displayMedian PROC USES EAX EBX EDX ESI
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP+36]
	CALL	WriteString
	CALL	CrLf


	MOV		ESI, [EBP+32]
	; Divides array size by two to determine index of median
	MOV		EDX, 0
	MOV		EAX, [EBP+28]
	MOV		EBX, 2
	DIV		EBX
	CMP		EDX, 0
	JE		_evenSizedArray

	; if size of array is odd we just return the middle value
	_oddSizedArray:
	; EAX contains index of middle value. Multiply by array data type to get memory offset of middle value.
	MUL		DWORD PTR [EBP+24]
	ADD		ESI, EAX
  	MOV		EAX, [ESI]
	CALL	WriteDec
	JMP		_exit

	; If the array size is even we return the average of the two middle values
	_evenSizedArray:
	; Move two middle values to EAX and EBX for comparison
	MUL		DWORD PTR [EBP+24]
	ADD		ESI, EAX
	MOV		EAX, [ESI]
	SUB		ESI, [EBP+24]
	MOV		EBX, [ESI]

	CMP		EAX, EBX
	JNE		_midValsNotEqual

	; If the two middle values are equal we don't need to calculate an average
	_midValsEqual:
	CALL	WriteDec
	JMP		_return

	; If the middle values are not equal we must calculate the average
	_midValsNotEqual:
	; Find average of middle values
	PUSH	EAX
	PUSH	EBX
	CALL	findAverage
	CALL	WriteDec
	JMP		_return
	

	_return:
	CALL	CrLf
	CALL	CrLf
	POP		EBP
	RET
displayMedian ENDP



;-----------------------------------------------------
; Name: findAverage
; Description: Helper procesdure for displayMedian. Finds the average of two integers passed on the stack, rounding to the nearest integer.
; Preconditions: Values are of type DWORD
; Postconditions: Modifies EAX, EBX
; Receives:
;		[EBP+16] = Value one
;		[EBP+12] = Value two
; Returns:
;		EAX = Rounded integer average of the two values
;-----------------------------------------------------
findAverage PROC USES EDX
	PUSH	EBP
	MOV		EBP, ESP

	; Add the two numbers and divide the sum by two
	MOV		EAX, [EBP+16]
	ADD		EAX, [EBP+12]
	MOV		EDX, 0
	MOV		EBX, 2
	DIV		EBX

	; If the remainder is below 0.5 round down
	CMP		EDX, 1
	JB		return

	; If remainder is above or equal to 0.5 round up
	_roundUp:
	INC		EAX
	
	return:
	POP		EBP
	RET		8
findAverage ENDP

;-----------------------------------------------------
; Name: countArray
; Description: Counts the number of instances of each number of input array
; Preconditions: 
;		Integers in input array are in range [HI,LO] 
;		Counting array is filled with zeroes
; Postconditions: Modifies counting array
; Receives:
;		[EBP+40] = Memory offset of first index of array to be counted
;		[EBP+36] = Size of input array
;		[EBP+32] = output array where counts will be written
;		[EBP+28] = data type of array to be counted
; Returns: Counting array = number of instances of each number in input array
;-----------------------------------------------------
countArray PROC USES EAX ECX EDX ESI EDI
	PUSH	EBP
	MOV		EBP, ESP

	MOV		ECX, [EBP+36]
	MOV		ESI, [EBP+40]
	MOV		EDI, [EBP+32]

	; Current number is used to determine which index in the counting array to index by subtracting the LO
	; value from it and then multiplying it by the data type of the counting array
	_iterate:
	MOV		EAX, [ESI]
	SUB		EAX, LO
	MUL		DWORD PTR [EBP+28]
	INC		[EDI+DWORD PTR [EAX]]

	; Go to next index in array
	ADD		ESI, [EBP+28]
	LOOP	_iterate

	POP		EBP
	RET		16
countArray ENDP



;-----------------------------------------------------
; Name: writeThis
; Description: Writes the passed in string to the console
; Preconditions: Input is memory address of a string, passed on the stack
; Postconditions: None
; Receives:
;		[EBP+12] = Memory offset of string to be written
; Returns: None
;-----------------------------------------------------
writeThis PROC USES EDX
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP+12]
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	POP		EBP	
	RET		4
writeThis ENDP

END main








