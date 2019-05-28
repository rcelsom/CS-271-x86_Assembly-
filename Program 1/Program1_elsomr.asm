TITLE Elementary Arithmetic     (Program1.asm)

; Author: Robert Elsom
; Last Modified: 1/11/2019
; OSU email address: elsomr@oregonstate.edu
; Course number/section: 271 400
; Project Number: 1                Due Date: 1/21/2019
; Description: Basic program that takes two integer inputs from the user
;				and then multiplies, divides, adds, and subtracts the two 
;				numbers and outputs the results it back to the user.

INCLUDE Irvine32.inc

.data

nameAndTitle	BYTE	"		Elementary Arithmetic	by Robert Elsom",0	
extraCredit1	BYTE	"**EC: Program verifies that second number is less than first",0
extraCredit2	BYTE	"**EC: Repeat until user chooses to quit",0
extraCredit3	BYTE	"**EC: Calculates and displays quotient as a floating-point number, rounded to the nearest .001",0

prompt1			BYTE	"Enter 2 numbers, and I will show you the sum, difference, product, quotient, and remaider.",0
numCompare		BYTE	"Sorry, the second number must be less than the first!",0
firstNumPrompt	BYTE	"First Number: ",0
secNumPrompt	BYTE	"Second Number: ",0
spaceSym		BYTE	20h,0
addSym			BYTE	2bh,0
subSym			BYTE	2dh,0
mulSym			BYTE	78h,0
divSym			BYTE	0f6h ,0
decSym			BYTE	2eh, 0
eqSym			BYTE	3dh,0
remainPrompt	BYTE	" remainder: ",0
firstNum		DWORD	?
secondNum		DWORD	?
sum				DWORD	?
difference		DWORD	?
product			DWORD	?
quotient		DWORD	?
remainder		DWORD	?
floatQuotient	REAL4	?
floatHelper		REAL4	?
floatRemainder	REAL4	?
floatDecimal	DWORD	?
scaleFactor		DWORD	1000
repeatPrompt1	BYTE	"Would you like to repeat the program?",0
repeatPrompt2	BYTE	"1. Repeat the program",0
repeatPrompt3	BYTE	"2. Quit",0
repeatPrompt4	BYTE	"Sorry, that is not a valid option. Please choose either 1 or 2.",0
repeatNum		DWORD	1
goodBye			BYTE	"Thank you, good-bye",0


.code
main PROC

;----------------------------------------------------------
;		TITLE AND EXTRA CREDIT
;		Description: Displays the title, creator, and all
;					extra credits attempted in the program
;----------------------------------------------------------

; Display name of creator and program title
	mov		edx, OFFSET nameAndTitle
	call	WriteString
	call	CrLf

; Display extra credit options
	call	CrLf
	mov		edx, OFFSET extraCredit1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET extraCredit2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET extraCredit3
	call	WriteString
	call	CrLf

repeatProgram:
;------------------------------------------------------------------
;		INSTRUCTIONS AND INPUT
;		Description: Displays instructions and takes the input from
;					the user and stores in two variables
;------------------------------------------------------------------

; Display instructions
	call	CrLf
	mov		edx, OFFSET prompt1
	call	WriteString
	call	CrLf

; Prompt user for two numbers and store
	mov		edx, OFFSET firstNumPrompt
	call	WriteString
	call	ReadInt
	mov		firstNum, eax
	mov		edx, OFFSET secNumPrompt
	call	WriteString
	call	ReadInt
	mov		secondNum, eax

;----------------------------------------------------------
;		NUMBER COMPARISON
;		**EXTRA CREDIT
;		Description: checks if second number is less than
;					first, if not, then jumps to repeat menu
;------------------------------------------------------------

;Check if second is less than first 
	mov		ebx, secondNum
	mov		eax, firstNum
	cmp		eax, ebx
	jl		secondLarger
	jmp	secondSmaller
	secondLarger:
		call	CrLf
		mov		edx, OFFSET numCompare
		call	WriteString
		call	CrLf
		jmp		repeatMenu
	secondSmaller:

;-----------------------------------------------------
;		COMPUTING SECTION
;		Description: contains all the math operations
;-----------------------------------------------------

;Calculate sum and store in a variable
	mov		eax, firstNum
	add		eax, secondNum
	mov		sum, eax

;Calculate difference and store in a variable
	mov		eax, firstNum
	sub		eax, secondNum
	mov		difference, eax

;Calculate product and store in a variable
	mov		eax, firstnum
	mov		edx, secondNum
	mul		edx
	mov		product, eax

;Calculate quotient and remainder and store in two variables
	mov		eax, firstNum
	mov		edx, 0
	mov		ebx, secondNum
	div		ebx
	mov		quotient, eax
	mov		remainder, edx

;Calculate quotient and display float to the nearest thousandth
	;used commands found on https://en.wikipedia.org/wiki/X86_instruction_listings#Original_8087_instructions
	;used https://stackoverflow.com/questions/15934315/how-to-round-a-floating-point-to-the-nearest-001 for ideas on how to display as a rounded decimal
	fild	firstNum
	fdiv	secondNum
	fmul	scaleFactor
	frndint
	fist	floatRemainder
	mov		eax, quotient
	mov		edx, scaleFactor
	mul		edx
	mov		floatQuotient, eax
	mov		eax, floatRemainder
	sub		eax, floatQuotient
	mov		floatDecimal, eax

;-----------------------------------------------------
;		OUTPUT SECTION
;		Description: prints outputs of the functions to the user
;-----------------------------------------------------

	;addition output
	mov		eax, firstNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET addSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, secondNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf

	;subtraction output
	mov		eax, firstNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET subSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, secondNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLf

	;multiplication output
	mov		eax, firstNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET mulSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, secondNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf

	;division output
	mov		eax, firstNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET divSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, secondNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov 	edx, OFFSET remainPrompt
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf

	;float division output. **EC display division output as floating point to .001
	mov		eax, firstNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET divSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, secondNum
	call	WriteDec
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET eqSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET decSym
	call	WriteString
	mov		eax, floatDecimal
	call	WriteDec
	call	CrLf

;-----------------------------------------------------
;		REPEAT MENU
;		**EXTRA CREDIT
;		Description: prompts the user to repeat the program
;		   			or quit
;------------------------------------------------------
repeatMenu:
;prompt user to repeat again or quit
	call	CrLf
	mov		edx, OFFSET repeatPrompt1
	call	WriteString
	call	CrLf
menuInput:
	mov		edx, OFFSET repeatPrompt2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET repeatPrompt3
	call	WriteString
	call	CrLf	
	call	ReadInt
	mov		repeatNum, eax

;validates user input to repeat or exit program, if not valid asks for input again
	mov		eax, repeatNum
	cmp		eax, 1
	je		repeatProgram
	cmp		eax, 2
	je		goodByeLbl
	call	CrLf
	mov		edx, OFFSET repeatPrompt4
	call	WriteString
	call	CrLf
	jmp		menuInput

;--------------------------------------------------------------------
;		GOOD-BYE
;		Description: Displays good-bye then exits the program
;---------------------------------------------------------------------
goodByeLbl:	
	call	CrLf
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLf
	exit	; exit to operating system


main ENDP
END main
