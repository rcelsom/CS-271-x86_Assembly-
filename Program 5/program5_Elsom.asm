TITLE Sorting Random Integers    (program5.asm)

; Author: Robert Elsom
; Last Modified: 2/25/2019
; OSU email address: elsomr@oregonstate.edu
; Course number/section: 271-400
; Project Number: 5                Due Date: 3/4/2019
; Description: Gets user the size of the array, fills the array with random numbers
; displays the new array, then sorts the array. Lastly it calculates and 
;displays median rounded to nearest int and prints the final sorted list.

INCLUDE Irvine32.inc

.const
min			DWORD	10
max			DWORD	200
hi			DWORD	999
lo			DWORD	100

.data
titlePrompt			BYTE	"Sorting Random Integers			by Robert Elsom",0
ecPrompt			BYTE	"**EC: Align the output columns",0
ecPrompt2			BYTE	"**EC: Only check against prime divisors",0
instructPrompt		BYTE	"This program generates random numbers in range [100-999], ", 0dh, 0ah
					BYTE	"displays the original list, sorts the list, and calculates the ", 0dh, 0ah
					BYTE	"median value. Finally, it displays the list sorted in descending order",0
userInstructPrmpt	BYTE	"How many numbers should be generated? [10 ... 200]:  ",0
invalidInputPrmpt	BYTE	"Sorry, that is not in the correct range [10...200]. Try again: ",0

sortedDisplay		BYTE	"The sorted random numbers are: ", 0
unsortedDisplay		BYTE	"The unsorted random numbers are: ", 0
medianDisplay		BYTE	"The median is ",0
periodSym			BYTE	2Eh
spaceSymbols		BYTE	"     ",0

median				DWORD	?
request				DWORD	?
array				DWORD	190 DUP(?)

.code
main PROC
	pop		eax
;call randomize
	call	Randomize

;display intro and extra credits
	push	OFFSET instructPrompt
	push	OFFSET titlePrompt
	call	introduction

;get user inputted data
	push	OFFSET invalidInputPrmpt
	push	OFFSET userInstructPrmpt
	push	OFFSET request
	call	getData

;fill array based on data
	push	OFFSET array
	push	request
	call	fillArray

;print unsorted array
	push	OFFSET spaceSymbols
	push	OFFSET array
	push	request
	push	OFFSET unsortedDisplay
	call	displayList

;sort array
	push	OFFSET array
	push	request
	call	sortArray

;calculate and display median
	push	OFFSET array
	push	request
	push	OFFSET medianDisplay
	push	OFFSET periodSym
	call	displayMedian

;print sorted array
	push	OFFSET spaceSymbols
	push	OFFSET array
	push	request
	push	OFFSET sortedDisplay
	call	displayList


	exit	; exit to operating system
main ENDP


;-------------------------------------------------------------
;		INTRODUCTION Procedure
;Procedure to display welcome message, extra credit and instructions to user
;Receives: instructPrompt, title
;Returns: none
;Preconditions: none
;Registers changed: edx
;--------------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp
	;display welcome prompts
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, [ebp+12]
	call	WriteString
	call	CrLf
	call	CrLf


	pop		ebp
	ret		12
introduction ENDP


;-------------------------------------------------------------
;		GET DATA Procedure
;Procedure to get input from user
;Receives: request (by reference)
;Returns: user inputted value stored in request
;Preconditions: None
;Registers changed: edx, eax
;--------------------------------------------------------------
getData PROC
	push	ebp
	mov		ebp, esp

;display instructions
	mov		edx, [ebp + 12]
	call	WriteString
	jmp		Validate
Invalid:
	mov		edx, [ebp + 16]
	call	WriteString

;validate input, if not, reprompt
Validate:
	;get user input
	mov		edx, [ebp + 8]
	call	ReadInt
	cmp		eax, min
	jl		Invalid
	cmp		eax, max
	jg		Invalid
;store input into data
	mov		[edx], eax


	pop		ebp
	ret		12
getData ENDP


;-------------------------------------------------------------
;		FILL ARRAY Procedure
;Procedure to fill the array with random values
;Receives: array (by reference), request (by value)
;Returns: array filled with random values
;Preconditions: array is declared and pushed
;Registers changed:  ecx, eax, edi, ecx
;--------------------------------------------------------------

fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, 0

Fill:
;create random number
	mov		eax, hi
	sub		eax, lo
	inc		eax
	call	RandomRange
	add		eax, lo	
;store in array
	mov		edi, [ebp + 12]
	mov		[edi + ecx * 4], eax
;move to next array element and loop if counter is less than request
	inc		ecx
	cmp		ecx, [ebp+8]
	jl		Fill

	pop		ebp
	ret		12
fillArray ENDP

;-------------------------------------------------------------
;		SORT Procedure
;Procedure to sort the array
;Receives: array(by reference), request (by value)
;Returns: Array with elements sorted in descending order
;Preconditions: none
;Registers changed: ecx, esi, eax
;--------------------------------------------------------------
sortArray PROC
	push	ebp
	mov		ebp, esp

;code used is slightly altered version of BubbleSort Proc in text book on page 375
	mov		ecx, [ebp + 8]
	dec		ecx

OuterLoop:
	push	ecx
	mov		esi, [ebp + 12]

InnerLoop:
	mov		eax, [esi]
	cmp		eax, [esi + 4]
	jg		NoExchange
;pushes a[i] and a[j] onto stack for exchangeElements procedure
	push	esi
	add		esi, 4
	push	esi
	sub		esi, 4
	call	exchangeElements
NoExchange:
;moves pointers to next value to test
	add		esi, 4
	loop	InnerLoop

	pop		ecx
	loop	OuterLoop

	pop		ebp
	ret		
sortArray ENDP


;-------------------------------------------------------------
;		EXCHANGE ELEMENTS Procedure
;Procedure to exchange two elements when sorting the array
;Receives: array[i] (reference), array[j] (reference), where i and j are index
;of elements to be exchanged
;Returns: a[i] and a[j] with swapped values
;Preconditions: a[i] > a[j]
;Registers changed: eax, ebx, edi, esi
;--------------------------------------------------------------
exchangeElements PROC
	push	ebp
	mov		ebp, esp

;store addresses 
	mov		edi, [ebp + 8]
	mov		esi, [ebp + 12]

;store values and swap
	mov		eax, [edi]
	mov		ebx, [esi]
	mov		[esi], eax
	mov		[edi], ebx

    pop		ebp
    ret		8
exchangeElements ENDP


;-------------------------------------------------------------
;		DISPLAY MEDIAN Procedure
;Procedure to display the median value
;Receives: array (reference), request(value)
;Returns: median
;Preconditions: Array filled
;Registers changed: eax, edx, ebx, ecx, edi, 
;--------------------------------------------------------------
displayMedian	PROC
	push	ebp
	mov		ebp, esp

;display median prompt
	mov		edx, [ebp+12]
	call	WriteString

;finds median value 
;if request % 2 = 1, median = a[request /2 +1]
	mov		edx, 0
	mov		ebx, 2
	mov		eax, [ebp + 16]
	div		ebx
	mov		ecx, eax
	cmp		edx, 1
	jne		average
	mov		edi, [ebp + 20]
	mov		eax, [edi + ecx * 4]
	call	WriteDec
	jmp		DisplayPeriod

;calculates average of two middle numbers when even number of total values
average:
;if request %2 = 0; median = (a[request/2] + a[request/2+1]) / 2 + 1
	mov		edi, [ebp + 20]
	mov		ebx, [edi + ecx * 4]
	dec		ecx
	mov		ecx, [edi + ecx * 4]
	add		ecx, ebx
	mov		edx, 0
	mov		eax, ecx
	mov		ecx, 2
	div		ecx
;cmp to see if decimal is .5, if so need to inc eax to round up
	cmp		edx, 1
	jne		dividedEvenly

	inc		eax
dividedEvenly:
	call	WriteDec

;display period
DisplayPeriod:
	mov		edx, [ebp + 8]
	call	WriteString
	call	CrLf
	call	CrLf

	pop		ebp
	ret		20
displayMedian  ENDP


;-------------------------------------------------------------
;		DISPLAY LIST Procedure
;Procedure to print an array
;Receives: array(reference), request (value), title(reference)
;Returns: Printed array to console screen
;Preconditions: Array has values
;Registers changed: edx, ecx, edi, eax, ebx
;--------------------------------------------------------------
displayList PROC
	push	ebp
	mov		ebp, esp

;display title for sort or unsort
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	mov		ecx, 0

Print:
;move value from array into eax
	mov		edi, [ebp + 16]
	mov		eax, [edi + ecx * 4]
;move eax into primeArr
	call	WriteDec
	mov		edx, [ebp + 20]
	call	WriteString
	inc		ecx
;if divisible by ten, break to new line
	mov		edx, 0
	mov		ebx, 10
	mov		eax, ecx
	div		ebx
	cmp		edx, 0
	je		newLine
;resume after getting new line
ResumePrint:
	;compare if printing all terms
	cmp		ecx, [ebp+12]
	jl		Print
	jge		finishPrint

;creates a new line
newLine:
	call	CrLf
	jmp		ResumePrint

;finishes printing
finishPrint:
	call	CrLf
	call	CrLf
	pop		ebp
	ret		16
displayList ENDP

END main
