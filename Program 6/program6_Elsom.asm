TITLE Program 6     (program6_Elsom.asm)

; Author: Robert Elsom
; Last Modified: 3/3/2019
; OSU email address: elsomr@oregonstate.edu
; Course number/section: 271 - 400
; Project Number: 6                Due Date: 3/18/2019
; Description: Program that implements its own ReadVal and WriteVal for unsigned integers
;				and macros getString and displayString. The program test these macros and procedures
;				by getting 10 user inputted strings, validates the input, then converts to an unsigned it
;				and displays the list of ints, sum, and average

INCLUDE Irvine32.inc

;-------------------------------------------------------------
;		getString Macro
;Macro thet displays a prompt and stores user input to a memory location
;Receives: Address of prompt to display and address of empty array to store string in
;Returns: Array with user inputted value in it
;Preconditions: none
;Registers changed: edx, ecx, eax
;--------------------------------------------------------------
getString MACRO	inputAddress, inputLength, letterCount
	push	ecx
	push	edx
	push	eax

	mov		edx, inputAddress
	mov		ecx, inputLength
	dec		ecx
	call	ReadString
	mov		[letterCount], eax

	push	eax
	pop		edx
	pop		ecx

ENDM


;-------------------------------------------------------------
;		displayString Macro
;Macro to print the string which is stored in a specific memory location.
;Receives: Parameter of string name needed to output
;Returns: Outputs string from memory location passed in as parameter buffer
;Preconditions: none
;Registers changed: edx 
;--------------------------------------------------------------
displayString MACRO bufferAddress
	push	edx
	mov		edx, bufferAddress
	call	WriteString
	pop		edx
ENDM


.const
LO_ASCII			DWORD	48
HI_ASCII			DWORD	57
MAX_INT				DWORD	4294967295


.data
titlePrompt			BYTE	"Program 6: Designing Low Level I/O Procedures			by Robert Elsom",0
instructPrompt		BYTE	"Please provide 10 unisgned integers. ", 0dh, 0ah
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register. ", 0dh, 0ah
					BYTE	"Therefore, any input will only record the first 10 digits.", 0dh, 0ah
					BYTE	"After you have finished inputting the raw numbers I will display a list ",0dh, 0ah
					BYTE	"of the intgers, their sum, and their average value. ", 0
userInputPrompt		BYTE	"Please enter an unsigned number:    ",0
errorPrompt			BYTE	"ERROR: You did not enter an unsigned integer or your number was too big. ",0dh, 0ah
					BYTE	"Please try again:    ",0
displayNumPrompt	BYTE	"You entered the following numbers: ", 0
commaSpaceSym		BYTE	2ch, 20h,0
displaySumPrompt	BYTE	"The sum of these numbers is:   ", 0
displayAvePrompt	BYTE	"The average is:  ", 0
average				DWORD	0
sum					DWORD	0
array				DWORD	10 DUP(?)
counter				DWORD	0
userString			BYTE	12 DUP(?)
tempString			BYTE	12 DUP(?)
numberSize			DWORD	?
exitPrompt			BYTE    "Bye! Thanks for playing!",0


.code
main PROC

;display intro and extra credits
	push	OFFSET instructPrompt
	push	OFFSET titlePrompt
	call	introduction

;loop 10 times to get user to fill in array with 10 ints
	mov		ecx, 10
L1:
	;save loop counter before procedure call
	push	ecx
;get user input and convert string to ints, then store in an array
	push	OFFSET counter
	push	OFFSET errorPrompt
	push	OFFSET array
	push	OFFSET numberSize
	push	OFFSET userInputPrompt
	push	OFFSET userString
	push	SIZEOF userString
	call	readVal
	pop		ecx
	loop	L1
	
;calculate sum of array elements
	push	OFFSET array
	push	OFFSET sum
	call	sumInts

;calculate average of array elements
	push	OFFSET sum
	push	OFFSET average
	call	averageInts

;print results
	push	OFFSET tempString
	push	OFFSET array
	push	OFFSET sum
	push	OFFSET average
	push	OFFSET displayNumPrompt
	push	OFFSET commaSpaceSym
	push	OFFSET displaySumPrompt
	push	OFFSET displayAvePrompt
	call	printResults

;print exit
	push	OFFSET exitPrompt
	call	exitPrint

	exit	; exit to operating system
main ENDP

;-------------------------------------------------------------
;		INTRODUCTION Procedure
;Procedure to display welcome message, extra credit and instructions to user
;Receives: instructPrompt, title
;Returns: displays title and instructions for the user
;Preconditions: none
;Registers changed: edx
;--------------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp
	push	edx

	displayString [ebp+8]
	call	CrLf
	call	CrLf
	displayString [ebp+12]
	call	CrLf
	call	CrLf

	pop		edx
	pop		ebp
	ret		8
introduction ENDP


;-------------------------------------------------------------
;		READ VAL Procedure
;Procedure to invoke getString macro to get user string of digits, 
;	then converts the string to numeric and validates input
;Receives: userString, LENGTHOF userString, arrayAddress, LENGTHOF array counter, 
;		size of number, and instruction prompts
;Returns: array with number added to it
;Preconditions: none
;Registers changed: eax, ebx, ecx, edx, esi, edi
;--------------------------------------------------------------
readVal	PROC
	push	ebp
	mov		ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	
	mov		esi, [ebp+12]
	displayString [ebp+16]
;gets user inputted string to convert to int
GetStrings:
	getString	[ebp+12], [ebp+8], [ebp+20]
	mov		ecx, [ebp+20]
	mov		esi, [ebp+12]
	cld

;makes sure string does not exceded the maximum length
checkLength:
	cmp		ecx, 10				;make sure number does not have more than 10 digits
	jg		invalidInput

	mov		ebx, 10
	mov		edx, 0

;loop to convert string to int
stringLoop:
	xor		eax, eax
	lodsb
   ;make sure eax is in rance 48-57 for an ASCII numbers
	cmp		HI_ASCII, eax
	jl		invalidInput
	cmp		eax, LO_ASCII
	jl		invalidInput
  ;convert string to int using formula for each character of string x = 10 ^ ecx * (x- 48) from lecture 23 slides 
	sub		eax, 48
	push	eax
	mov		eax, edx
  ;checks that carry flag is 0 when multiplying by 10
	mul		ebx
	jc		invalidInput
	mov		edx, eax
	pop		eax

  ;checks that carry flag is 0 when adding next plaxe value
	add		edx, eax
	jc		invalidInput
	cmp		MAX_INT, edx
	jg		invalidInput
	loop	stringLoop

;store number in array
	mov		edi, [ebp+24]
	mov		ebx, [ebp+32]
	mov		ebx, [ebx]
	mov		[edi+ebx*4], edx
	jmp		done

;displays error and reprompts user for number
invalidInput:
	displayString [ebp+28]
	jmp GetStrings


done:
;increments counter and restore registers
	push	edx
	push	eax
	push	ebx

	mov		edx, [ebp+32]
	mov		ebx, [edx]
	inc		ebx
	mov		[edx], ebx

;restoring registers and emptying stack
	pop		ebx
	pop		eax
	pop		edx

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	mov		esp, ebp
	pop		ebp
	ret		28
readVal		ENDP


;-------------------------------------------------------------
;		WRITE VAL Procedure
;Procedure to convert numeric value to a string of digits, and 
;	invoke displayString macro to produce the output
;Receives: tempString and int value
;Returns: none
;Preconditions: none 
;Registers changed: eax, edi, ecx, 
;--------------------------------------------------------------
writeVal PROC
	push	ebp
	mov		ebp, esp
	push	edi
	push	eax
	push	ecx


;move tempString into edi
	mov		edi, [ebp+12]
	mov		eax, [ebp+8]
	mov		ecx, 10
	push	0			;represents end of string
	
;pushes each place value onto the stack in reverse order, starts with ones place and works way up
conversionLoop:
	mov		edx, 0
	div		ecx
	add		edx, 48
	push	edx
  ;checks if reached end of int, if not, loops back through and pushes next values
	cmp		eax, 0
	jne		conversionLoop


;takes stack, pops into eax then uses stosb to store into edi.
	mov		ecx, 10
storeStringLoop:
	pop		eax
	stosb
  ;compare to test if end of string to break loop
	cmp		eax, 0
	jne		storeStringLoop

  ;use macro to display tempString variable
	displayString [ebp+12]

	pop		ecx
	pop		eax
	pop		edi
	mov		esp, ebp
	pop		ebp
	ret		8
writeVal ENDP

;-------------------------------------------------------------
;		SUM INTS Procedure
;Procedure to sum all ints in an array
;Receives: array
;Returns: sum
;Preconditions: array is filled
;Registers changed: esi, eax, ebx, ecx
;--------------------------------------------------------------
sumInts	PROC
	push	ebp
	mov		ebp, esp

	push	eax
	push	ebx
	push	ecx

	mov		esi, [ebp+12]
	mov		eax, [ebp+8]
	mov		eax, [eax]

	mov		ecx, 0
;loops through array and calcualtes sum of all ints
sumLoop:
	mov		ebx, [esi + ecx * 4]
	add		eax, ebx
	inc		ecx
	cmp		ecx, 10
	jl		sumLoop
	mov		ebx, [ebp+8]
	mov		[ebx], eax

	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret		4
sumInts ENDP

;-------------------------------------------------------------
;		AVERAGE INTS Procedure
;Procedure to average numbers in an array
;Receives: sum
;Returns: average
;Preconditions: sum is calculated
;Registers changed: eax, ebx, edx, ecx
;--------------------------------------------------------------
averageInts PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx

;calculate average using sum and 10 for the number of terms
	mov		eax, [ebp+12]
	mov		eax, [eax]
	mov		ebx, 10
	xor		edx, edx
	div		ebx
  ;checks if needing to round up or down based on remainder, since dividing by 10 every time
	cmp		edx, 5
	jl		roundDown
roundUp:
	inc		eax
roundDown:
  ;store quotient into average variable
	mov		ecx, [ebp+8]
	mov		[ecx], eax

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret		8
averageInts ENDP

;-------------------------------------------------------------
;		PRINT RESULTS Procedure
;Procedure to average numbers in an array
;Receives: average, array, sum
;Returns: prints sum, average, and array of ints
;Preconditions: none
;Registers changed: eax, ecx
;--------------------------------------------------------------
printResults PROC
	push	ebp
	mov		ebp, esp

	push	eax
	push	ecx

;print array prompt
	call	CrLf
	displayString [ebp+20]

	mov		ecx, 0

;prints array by looping through each int and passing into writeVal to display
printLoop:
	push	[ebp+36]
	push	[esi + ecx * 4]
	call	writeVal
	cmp		ecx, 9
	jge		skipComma	
  ;print comma and space
	displayString [ebp+16]
	
skipComma:
	inc		ecx
	cmp		ecx, 10
	jl		printLoop
	call	CrLf

;print sum
	call	CrLf
	displayString [ebp+12]
  ;use writeVal proc to display sum
	mov		eax, [ebp+28]
	push	[ebp+36]
	push	[eax]
	call	writeVal
	call	CrLf


;print average
	call	CrLf
	displayString [ebp+8]

  ;use writeVal to display average
	mov		eax, [ebp+24]
	push	[ebp+36]
	push	[eax]
	call	writeVal
	call	CrLf

	pop		ecx
	pop		eax

	mov		esp, ebp
	pop		ebp
	ret		32
printResults ENDP

;-------------------------------------------------------------
;		EXIT PRINT Procedure
;Procedure to display exit message
;Receives: exitPrompt
;Returns: prints exit prompts
;Preconditions: none
;Registers changed: edx
;--------------------------------------------------------------
exitPrint PROC
	push	ebp
	mov		ebp, esp
	call	CrLf
	
	push	edx
  ;display exit prompts
	mov		edx, [ebp+8]
	displayString edx
	
	call	CrLf
	call	CrLf

	pop		edx
	pop		ebp
	ret		4
exitPrint ENDP


END main