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




; Validate user inputs

; Recalculate max, min, and sum

; print invalid input and jump back to take user inputs
MOV		EAX, 0
	MOV		EAX, count
	MOV		EBX, 2
	IDIV	EBX
	CMP		avgRem, EBX
	JG		_roundUp
	JMP		_displayResults
_roundUp:
	DEC		avg
; Calculate average of inputs
_calcAvg:
	;;

; Results and goobye
	

	




	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
