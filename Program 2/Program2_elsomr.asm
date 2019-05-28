TITLE Program Template     (template.asm)

; Author:
; Last Modified:
; OSU email address: 
; Course number/section:
; Project Number:                 Due Date:
; Description:
TITLE Elementary Arithmetic     (Program2_elsomr.asm)

; Author: Robert Elsom
; Last Modified: 1/18/2019
; OSU email address: elsomr@oregonstate.edu
; Course number/section: 271 400
; Project Number: 2                Due Date: 1/28/2019
; Description: Program that prompts user for their name, displays
;			the name back to them, and then prompts the user for the
;			number of Fibonacci numbers to be displayed between
;			1 and 46. Then it calculates and displays that many
;			Fibonnaci numbers, 5 terms per line with atleast 5 spaces
;			between them. Lastly, program says good bye and exits. 
;			Do something amazing extra credit prompts user to input a number
;			between 2 and 1000 and changes their color to blue. 

INCLUDE Irvine32.inc

.CONST
; (insert constant definitions here)
upperLimit				DWORD		46
lowerLimit				DWORD		1


.data
; (insert variable definitions here)
titlePrompt				BYTE		"Fibonnaci Numbers",0
creatorPrompt			BYTE		"Programmed by Robert Elsom",0
extraCredit1			BYTE		"**Extra Credit: Display numbers in aligned columns.",0
extraCredit2			BYTE		"**Extra Credit: Do something amazing",0
userNamePrompt			BYTE		"What is your name? ",0
userName				BYTE		33 dup(0)
helloPrompt				BYTE		"Hello, ",0
instructionPrompt		BYTE		"Enter the number of Fibonnaci terms to be displayed.",0
instructionPrompt2		BYTE		"Give the number as an integer in the range [1...46]",0
instructionPrompt3		BYTE		"How many Fibonacci terms do you want? ",0
numberOfTerms			DWORD		?
invalidNumberPrompt		BYTE		"Out of range. Enter a number in [1...46]",0
goodbyePrompt			BYTE		"Results certified by Robert Elsom",0
goodbyePrompt2			BYTE		"Goodbye, ",0
tabSymbol				BYTE		09h,0
count					DWORD		2
temp					DWORD		?
sum						DWORD		?
spaceSym				BYTE		20h,0
spaceCounter			DWORD		? 
digitsInNumber			DWORD		? 
previousNumber			DWORD		?
firstTwoTerms			BYTE		"              1              1",0
divisor					DWORD		10
ten						DWORD		10
;**EC do something incredible
multipleInput			DWORD		999
multipleInputPrompt		BYTE		"Please enter a number in the range [2...1000] to see its Fibonnaci multiples.",0
multipleInputPrompt0	BYTE		"Enter 0 to skip.",0
multipleInputPrompt2	BYTE		"The multiples of ",0
multipleInputPrompt3	BYTE		" are in blue",0
validMultiplePrompt		BYTE		"Sorry, that number is not valid. ",0



.code
main PROC

;------------------------------------------------------------------------
;		Introduction
;		displays starting title and prompts
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
;		displays instructions to user and gets user name
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
	jmp		validInt

;-----------------------------------------------------------------------------
;		GET USER DATA
;		takes the number of terms from the user and validates it is between
;		the upper and lower limits. If not, repeats the prompt and tries again
;-----------------------------------------------------------------------------
validIntRepeat:
	mov		edx, OFFSET	invalidNumberPrompt
	call	WriteString
	call	CrLf
validInt:
	mov		edx, OFFSET instructionPrompt3
	call	WriteString
	call	ReadInt
	mov		numberOfTerms, eax
	mov		ebx, upperLimit
	cmp		eax, ebx
	jg		validIntRepeat
	mov		ecx, lowerLimit
	cmp		eax, ecx
	jl		validIntRepeat
	jmp		validMultiple

	;*EC checks if user inputs valid integer to display multiple of
validMultipleRepeat:
	mov		edx, OFFSET validMultiplePrompt
	call	WriteString
	call	CrLf
validMultiple:
	mov		edx, OFFSET multipleInputPrompt
	call	WriteString
	call	CrLf
	mov		edx, OFFSET multipleInputPrompt0
	call	WriteString
	call	ReadInt
	cmp		eax, 0
	je		preloop
	cmp		eax, 1000
	jg		validMultipleRepeat
	cmp		eax, 2
	jl		validMultipleRepeat
	mov		multipleInput, eax
	call	CrLf
	mov		edx, OFFSET multipleInputPrompt2
	call	WriteString
	call	WriteDec
	mov		edx, OFFSET multipleInputPrompt3
	call	WriteString
	call	CrLf
;-------------------------------------------------------------------------
;		DISPLAY FIBONNACI LOOP
;		Calculates the fibonnaci numbers in the loop and outputs them as soon
;		as it is calculated
;-------------------------------------------------------------------------
preloop:
	;start fibonacci loop with ones
	mov		eax,brown+(black*16)
    call	SetTextColor
	cmp		eax, 1
	mov		eax, lowerLimit
	mov		ebx, lowerLimit

	;display first 2 terms and change color
	mov		edx, OFFSET firstTwoTerms
	call	WriteString
	

fibonnaciLoop:
	add		eax, ebx
	mov		sum, eax
	mov		previousNumber, ebx
	;store outer counter

	;set spaces to print based on size of number
	mov		digitsInNumber, 1
	mov		spaceCounter, 14
	mov		divisor, 10

	;calulates how many digits are in the variable sum  
numberSize:
	;check to make sure digits do not excede DWORD size
	cmp		digitsInNumber, 10
	jge		calculateSpaces
	mov		eax, sum
	mov		ebx, divisor
	cmp		eax, ebx
	jl		calculateSpaces
	inc		digitsInNumber
	mov		eax, ten
	mul		ebx
	mov		divisor, eax
	jmp		numberSize
	
	;calculates number of spaces needed to print based on how many digits are in a number
calculateSpaces:
	mov		eax, spaceCounter
	sub		eax, digitsInNumber
	mov		ecx, eax
	
	;print spaces based on spaceCounter size
spacePrint:
	mov		edx, OFFSET spaceSym
	call	WriteString
	dec		ecx
	cmp		ecx, 0
	jge		spacePrint

continueLoop:
	inc		count
	mov		eax, sum
	mov		edx, 0
	mov		ebx, multipleInput
	div		ebx
	cmp		edx, 0
	; if it is not a multiple, skip over changing color
	jne		doNotChangeColor
	mov		eax,blue+(black*16)
    call	SetTextColor

doNotChangeColor:
	mov		eax, sum
	call	WriteDec
	;change color of text back after changing if it is a multiple
	mov		eax,brown+(black*16)
    call	SetTextColor
	;checking to move to next line after 5 terms is printed
	mov		edx, 0
	mov		eax, count
	mov		ecx, 5
	div		ecx
	cmp		edx, 0
	jne		resetECX
	call	CrLf

resetECX:
	mov		ecx, count
	mov		eax, previousNumber
	mov		ebx, sum


;compares if run the proper number of loops
	cmp		numberOfTerms, ecx
	jg		fibonnaciLoop

	;**EC change color back to black and white after printing out series
	mov  eax,white+(black*16)
    call SetTextColor


;-------------------------------------------------------------------------------
;		GOODBYE
;		Tells user goodbye and exits
;-------------------------------------------------------------------------------
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

; (insert additional procedures here)

END main
