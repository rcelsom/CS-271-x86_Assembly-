TITLE Program Template     (template.asm)

; Author: Robert Elsom
; Last Modified: 1/29/2019
; OSU email address: elsomr@oregonstate.edu
; Course number/section: 271-400
; Project Number: 3                Due Date: 2/11/2019
; Description: Program that gets users name, gets user to input negative numbers
;				between -100 and -1 and calculates the sum and averages all of those 
;				numbers until the user enters a positive number to exit

INCLUDE Irvine32.inc

.const
upperLimit		DWORD	-1
lowerLimit		DWORD	-100

.data
titlePrompt				BYTE		"Welcome to the Integer Accumalator",0
creatorPrompt			BYTE		"Programmed by Robert Elsom",0
extraCredit1			BYTE		"**Extra Credit: Display number of lines during input",0
extraCredit2			BYTE		"**Extra Credit: Calculate and display average as floating point to nearest .001",0
userNamePrompt			BYTE		"What is your name? ",0
userName				BYTE		33 dup(0)
helloPrompt				BYTE		"Hello, ",0
instructionPrompt		BYTE		"Please enter numbers between [-100, -1].",0
instructionPrompt2		BYTE		"Enter a non-negative number when you are finished to see the results.",0
sum						SDWORD		0
number					SDWORD		?
decSym					BYTE		2eh, 0
spaceSym				BYTE		20h,0
floatQuotient			REAL4		?
floatRemainder			REAL4		?
floatDecimal			REAL4		?
decimalFactor			DWORd		-1
quotient				SDWORD		0
scaleFactor				DWORD		1000
lineCounter				DWORD		1
numberCounter			DWORD		0
inputPrompt				BYTE		"Enter a number: ",0
totalNumbersPrompt		BYTE		"You entered ",0
totalNumbersPrompt2		BYTE		" valid numbers.",0
sumPrompt				BYTE		"The sum of your valid numbers is ",0
averagePrompt			BYTE		"The rounded average is ",0
goodbyePrompt			BYTE		"Thank you for playing Integer Accumulator! ",0
goodbyePrompt2			BYTE		"It's been a pleasure to meet you, ",0
repeatValidIntPrompt	BYTE		"Sorry, that number is too low.",0		
noNegativePrompt		BYTE		"You entered 0 valid integers. No results to display.",0


.code
main PROC

;------------------------------------------------------------------------
;		Introduction
;		Displays starting title and extra credits
;------------------------------------------------------------------------	
	mov		edx, OFFSET titlePrompt
	call	WriteString
	call	CrLf
	mov		edx, OFFSET creatorPrompt
	call	WriteString
	call	CrLf
	mov		edx, OFFSET extraCredit1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET extraCredit2
	call	WriteString
	call	CrLf
	call	CrLf

;-----------------------------------------------------------------------
;		USER INSTRUCTIONS
;		Displays instructions to user and gets user name
;-----------------------------------------------------------------------	
	mov		edx, OFFSET userNamePrompt
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, SIZEOF userName
	call	ReadString	
	mov		edx, OFFSET helloPrompt
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructionPrompt
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructionPrompt2
	call	WriteString
	call	CrLf
	call	CrLf
	jmp		validInteger

;-----------------------------------------------------------------------------
;		GET USER DATA
;		Repeatedly gets a number from the user and updates the sum. 
;-----------------------------------------------------------------------------
validIntegerRepeat:
	mov		edx, OFFSET repeatValidIntPrompt
	call	WriteString
	call	CrLf
validInteger:
	;display prompt with line number and get number from user
	mov		eax, lineCounter
	call	WriteDec
	mov		edx, OFFSET decSym
	call	WriteString
	mov		edx, OFFSET spaceSym
	call	WriteString
	mov		edx, OFFSET inputPrompt
	call	WriteString
	call	ReadInt
	mov		number, eax
	;validate number is in valid range
	mov		ebx, lowerLimit
	cmp		number, ebx
	jl		validIntegerRepeat
	;if greater than, means it is positive and go to display results
	mov		ebx, upperLimit
	cmp		number, ebx
	jg		displayResults
	

	;update sum and inc numberCounter and lineCounter
	mov		eax, sum
	mov		ebx, number
	add		eax, ebx
	mov		sum, eax
	inc		numberCounter
	inc		lineCounter
	jmp		validInteger

;-----------------------------------------------------------------------------
;		Display Results
;		Once user inputs positive integer, displays number of valid ints,
;		sum, and average.
;-----------------------------------------------------------------------------
displayResults:
;check if there is not a negative integer, if there is jmp to normalResults
	call	CrLf
	mov		eax, numberCounter
	cmp		eax, 0
	jg		normalResults

	mov		edx, OFFSET noNegativePrompt
	call	WriteString
	call	CrLf
	jmp		goodByeMessage


normalResults:
	call	CrLf
	;print total number of numbers
	mov		edx, OFFSET totalNumbersPrompt
	call	WriteString
	mov		eax, numberCounter
	call	WriteDec
	mov		edx, OFFSET totalNumbersPrompt2
	call	WriteString
	call	CrLf

	;print sum
	mov		edx, OFFSET sumPrompt
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	CrLf

	;calculate average rounded to .001
	mov		eax, sum
	cdq
	mov		ebx, numberCounter
	idiv	ebx
	mov		quotient, eax

	fild	sum
	fdiv	numberCounter
	fmul	scaleFactor
	frndint
	fist	floatRemainder
	mov		eax, quotient
	mov		edx, scaleFactor
	mul		edx
	mov		floatQuotient, eax
	mov		eax, floatRemainder
	sub		eax, floatQuotient
	;make sure to change decimal to positive by multiplying by -1
	mov		edx, decimalFactor
	mul		edx
	mov		floatDecimal, eax
	
	;print average
	mov		edx, OFFSET averagePrompt
	call	WriteString
	mov		eax, quotient
	call	WriteInt
	mov		edx, OFFSET decSym
	call	WriteString
	mov		eax, floatDecimal
	call	WriteDec
	call	CrLf


;-------------------------------------------------------------------------------
;		GOODBYE
;		Tells user goodbye and exits
;-------------------------------------------------------------------------------
goodByeMessage:	
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbyePrompt
	call	WriteString
	call	CrLf

	mov		edx, OFFSET goodbyePrompt2
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf
	exit	; exit to operating system

main ENDP

END main
