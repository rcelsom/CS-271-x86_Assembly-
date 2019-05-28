TITLE Composite Numbers     (program4_elsom.asm)

; Author: Robert Elsom
; Last Modified: 2/6/2019
; OSU email address: elsomr@oregonstate.edu	
; Course number/section: 271-400
; Project Number: 4                Due Date: 2/18/2018
; Description: Gets user input on how many composite numbers between 1 
;				and 400 to display, then outputs that number of composites
;				in aligned columns, 10 numbers per line with atleast 3 spaces
;				seperating them

;Implementation Notes:
;	This program is implemented using procedures.
;	All variables are global, no parameters are passed




INCLUDE Irvine32.inc

.const
upperLimit			DWORD	400
lowerLimit			DWORD	1

.data
titlePrmpt			BYTE	"Composite Numbers         by Robert Elsom",0
ecPrompt			BYTE	"**EC: Align the output columns",0
ecPrompt2			BYTE	"**EC: Only check against prime divisors",0
userInstructPrmpt	BYTE	"Enter the number of composite numbers you would like to see.",0
userInstructPrmpt2	BYTE	"I'll accept any number for up to 400 composites.",0
userInputPrmpt		BYTE	"Enter the number of composites to be displayed [1...400]: ",0
invalidInputPrmpt	BYTE	"Sorry, out of range. Try again.",0
numberOfComposites	DWORD	?
goodByePrmpt		BYTE	"Results certified by Robert Elsom. Good-Bye.",0

;only need array size 100 to cover first 400 composites
primeArr			DWORD	100 DUP(2)
;contains first two number to start checking for primes
startPrimeArr		DWORD	2,3
arrayCounter		DWORD	0
compositeCounter	DWORD	-1
compositeNumber		DWORD	4
userNumber			DWORD	?
spaceSym			BYTE	20h,0
compositeFlag		DWORD	0
tempCount			DWORD	?
numOfSpaces			DWORD	6


.code
main PROC
	call	introduction
invalidNumber:
	call	getUserData
	call	fillPrimeArray
	call	showComposites
	call	farewell


	exit
main ENDP

;-------------------------------------------------------------
;		INTRODUCTION Procedure
;Procedure to display welcome message, extra credit and instructions to user
;Recieves: titlePrmpt, userInstructPrmpt, and userInstructPrmpt2
;			are global variables
;Returns: None
;Preconditions: None
;Registers changed: edx
;--------------------------------------------------------------

introduction	PROC

;display title
	mov		edx, OFFSET titlePrmpt
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ecPrompt
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ecPrompt2
	call	WriteString
	call	CrLf
	call	CrLf

;display user instructions
	mov		edx, OFFSET userInstructPrmpt
	call	WriteString
	call	CrLf
	mov		edx, OFFSET userInstructPrmpt2
	call	WriteString
	call	CrLf
	call	CrLf

	ret
introduction	ENDP

;-------------------------------------------------------------
;		GETUSERDATA Procedure
;Displays input instructions and user inputs a number between 1 and 400
;Recieves: userInputPrompt and compositeNumber are global variables
;Returns: global compositeNumber = user input
;Preconditions: None
;Registers changed: edx, eax
;--------------------------------------------------------------

getUserData		PROC

	;display input message
	mov		edx, OFFSET userInputPrmpt
	call	WriteString

	;get input
	call	ReadInt
	mov		userNumber, eax
	
	;validate input
	call		validate
	
	ret
getUserData		ENDP

;-------------------------------------------------------------
;		VALIDATE Procedure
;Procedure to validate user input is between 1 and 400
;Recieves: compositeNumber and invalidInputPrmpt are global variables
;Returns: returns nothing if input was valid, else recalls getUserData to try again
;Preconditions: user has inputted a number in compositeNumber
;Registers changed: edx, eax
;--------------------------------------------------------------
validate		PROC

	;jmp to compare input to limits before calling getUserData
	jmp		continueValidation

;displays error and recalls for user to input data
notValid:
	mov		edx, OFFSET invalidInputPrmpt
	call	WriteString
	call	CrLf
	call	getUserData

continueValidation:

	;check if user input is greater than or eq to lower limit
	;if not, jump to not valid
	mov		eax, userNumber
	cmp		eax, lowerLimit
	jl		notValid

	;check if user input is less than or eq to upper limit
	;if not, jump to not valid
	mov		eax, userNumber
	cmp		eax, upperLimit
	jg		notValid

	ret
validate		ENDP

;-------------------------------------------------------------
;		FILLPRIMEARRAY Procedure
;Procedure to fill in prime array with first two primes from startPrimeArray
;Recieves: primeArr and startPrimeArr are global variables
;Returns: primeArr with first two values set to 2 and 3
;Preconditions: None
;Registers changed: esi, edi, ecx
;--------------------------------------------------------------
;found help at https://stackoverflow.com/questions/26132914/arrays-in-masm-assembly-very-confused-beginner

fillPrimeArray		PROC
	mov		edi, OFFSET startPrimeArr
	mov		esi, OFFSET primeArr
	mov		ecx, 0

Fill:
	;move value from startPrime into eax
	mov		eax, [edi + ecx * 4]
	;move eax into primeArr
	mov		[esi + ecx * 4], eax
	inc		ecx
	inc		arrayCounter
	cmp		ecx, LENGTHOF startPrimeArr
	jl		Fill

	ret
fillPrimeArray		ENDP



;-------------------------------------------------------------
;		SHOWCOMPOSITES Procedure
;Procedure to output the number of composites up to the user input
;Recieves: compositeCounter, numOfSpaces, and compositeNumber are global variables
;Returns: Nothing
;Preconditions: None
;Registers changed: eax, ebx, ecx, edx, 
;--------------------------------------------------------------
showComposites	PROC
	
	mov		ecx, userNumber

	;calls isComposite to get if number is composite,
	;then outputs display with formatted number of spaces
	;and continues looping until reaching user inputted number
CompositeLoop:
	mov		tempCount, ecx
	;test if number is composite
	call	isComposite
	;if not composite skip to isPrimeNum
	cmp		compositeFlag, 0
	je		isPrimeNum
	inc		compositeCounter
	;new line if ten terms are printed
	mov		eax, compositeCounter
	xor		edx, edx
	mov		ebx, 10
	div		ebx
	cmp		edx, 0
	jne		sameLine
	call	CrLf

sameLine:
	call	formattedOutput
	mov		ecx, numOfSpaces
	;print number of spaces to format output
SpaceLoop:
	mov		edx, OFFSET spaceSym
	call	WriteString
	loop	SpaceLoop
	
	mov		eax, compositeNumber
	call	WriteDec
	jmp		endLoop

isPrimeNum:
	;make sure this loop does not count towards number of composites
	inc		tempCount
	
endLoop:
	inc		compositeNumber
	mov		ecx, tempCount
	loop	CompositeLoop

	ret
showComposites	ENDP

;-------------------------------------------------------------
;		FORMATTEDOUTPUT Procedure
;Procedure to format output to the screen
;Recieves: compositeNumber is a global variable
;Returns: numOfSpaces as a global variable
;Preconditions: non
;Registers changed: eax
;--------------------------------------------------------------

formattedOutput	PROC
	;reset numOfSpaces
	mov		numOfSpaces, 6
	mov		eax, compositeNumber
	cmp		eax, 100
	jl		fiveSpaces
	dec		numOfSpaces
fiveSpaces:
	cmp		eax, 10
	jl		sixSpaces
	dec		numOfSpaces
sixSpaces:

	ret
formattedOutput	ENDP

;-------------------------------------------------------------
;		ISCOMPOSITE Procedure
;Procedure to validate a test number is composite
;Recieves: primeArr, arrayCounter, compositeFlac are global variables
;Returns: Composite flag set to true if compositeNumber is composite
;Preconditions: none
;Registers changed: eax, edx, ebx, esi
;--------------------------------------------------------------

isComposite		PROC
	;set composite flag to 0	
	mov		eax, 0
	mov		compositeFlag, eax

	;compares number to array of primes to make sure it is divisible by a prime number
	mov		esi, OFFSET primeArr
	mov		ecx, arrayCounter
compareLoop:
	;divide number by primes in primeArr, if any number divides evenly, set flag to one
	mov		eax, compositeNumber
	xor		edx, edx
	mov		ebx, [esi + ecx * 4]
	div		ebx
	cmp		edx, 0
	je		passedComposite
	loop	compareLoop
	;if finished loop and no number was able to divide into number
	call	addPrime
	jmp		isPrimeNumber

passedComposite:
	;set compositeFlag to true
	mov		compositeFlag, 1

;skips setting composite flag if number is prime
isPrimeNumber:
	ret
isComposite		ENDP

;-------------------------------------------------------------
;		ADDPRIME Procedure
;Procedure to add prime into primeArr if number is not composite
;Recieves: compositeNumber and primeArr are global variables
;Returns: primeArr with one new number added
;Preconditions: compositeNumber is not composite
;Registers changed: esi, eax, ecx
;--------------------------------------------------------------

addPrime		PROC
	;store new prime into primeArr
	mov		esi, OFFSET primeArr
	mov		ecx, arrayCounter
	mov		eax, compositeNumber
	mov		[esi + ecx * 4], eax
	inc		arrayCounter

	ret
addPrime		ENDP


;-------------------------------------------------------------
;		FAREWELL Procedure
;Procedure to display good-bye message to user
;Recieves: goodByePrmpt is a global variable
;Returns: None
;Preconditions: None 
;Registers changed: edx
;--------------------------------------------------------------

farewell		PROC
	;print good bye message
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodByePrmpt
	call	WriteString
	call	CrLf

	ret
farewell		ENDP


END main
