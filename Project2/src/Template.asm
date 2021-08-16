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
myChecker   BYTE   12h
            BYTE   34h
            BYTE   56h
            BYTE   78h
            BYTE   90h
; (insert variable definitions here)

.code
main PROC

; (insert executable instructions here)

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
