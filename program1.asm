; Name: Gabriel Santana Soto
; Creation date: 24 February 2023
; Last modified: 1 May 2024
;
; 
; Name of file: program1.asm
; Description: Performs basic statistics on valid entries.
		
; Assemble:	nasm -f elf -g -Wall -l program1.lst program1.asm
; Link:		gcc -m32 -no-pie program1.o -o program1
; Run:		./program1
;
; Output:	Enter your name: G
;           Welcome to Gabriel's Program 1, G.
;           This program sums and counts integer entries between [-200,-100] and [-50, -1].
;           It will continue prompting until a positive number is entered.
;
;           Enter a number: -50
;           Enter a number: -150
;           Enter a number: 0
;           Count: 2
;           Sum: -200
;           Max: -150
;           Min: -50
;           Mean: -100
;           Goodbye, G.

;When using c functions, must declare external functions here.
extern printf
extern scanf

;This area is usually used for initializing variables and strings.
SECTION .data

    ;dd is dword sized data (32 bit) and is followed by the value it is initialized to.
    ;db is byte sized data (4 bits), usually reserved for making strings.
    ;A string followed by 10 means a newline is appended.
    ;A string followed by 0 means a null character '\0' is appended.
    ;Variables defined here and in .bss are also GLOBAL. This is relevant in program 4.

    name:   dd 20
    ninput: db "%s", 0
    npmt:   db "Enter your name: ", 0
    wel:    db "Welcome to Gabriel's Program 1, %s.", 10, 0
    istn1:  db "This program sums and counts integer entries between [-200,-100] and [-50, -1].", 10, 0
    istn2:  db "It will continue prompting until a positive number is entered.", 10, 10, 0
    bye:    db "Goodbye, %s.", 10, 0
    istn3:  db "Enter a number: ", 0
    badnum: db "Invalid number.", 10, 0
    nocnt:  db "No valid entries. Nothing to display.", 10, 0
    inmax:  dd 0
    inmin:  dd -200
    dinput: db "%i", 0
    count:  db "Count: %i", 10, 0
    dissum: db "Sum: %i", 10, 0
    dismax: db "Max: %i", 10, 0
    dismin: db "Min: %i", 10, 0
    dimean: db "Mean: %i", 10, 0
    sum:    dd 0
    mean:   dd 0

;This area is usually used for initializing arrays or uninitialized variables.
SECTION .bss

    ;res means to reserve.
    ;d, q, b, etc refers to the size of each index.
    ;The following number means the size of the array.

    int1:   resd 1

;The code section.
SECTION .text

global main

main:
    ;Do this at beginning every time.
    ;Initializes the program's base and stack pointer.
    ;Will pop at the end of program.
    push ebp
    mov ebp, esp

;Prompts for name and outputs welcome and program instructions.
.welcome:
    push dword npmt         ;"Enter your name:"
    call printf
    add esp, 4

    ;Function calls must always go in reverse order.
    ;Normally goes: scanf(ninput, name), so scanf -> ninput -> name
    ;In reverse, it goes: name -> ninput -> scanf
    push dword name
    push dword ninput       ;"%s"
    call scanf
    add esp, 8
    ;Must keep track of stack pointer.
    ;Add 4 for every dword push performed.

    push dword name
    push dword wel          ;"Welcome to Gabriel's Program 1, %s."
    call printf
    add esp, 4
    push dword istn1        ;"This program sums and counts integer entries between [-200,-100] and [-50, -1]."
    call printf
    add esp, 4
    push dword istn2        ;"It will continue prompting until a positive number is entered."
    call printf
    add esp, 4

    mov ebx, 0              ;Set count to 0.
    mov eax, 0              ;Set input to 0.

;Loops until positive number entered, jumps to .add_to_total if number is in [-200, -100] U [-50, -1].
.input_loop:
    push dword istn3        ;"Enter a number: "
    call printf
    add esp, 4
    push dword int1
    push dword dinput       ;"%i"
    call scanf
    add esp, 8

    ;Notice that this the variable is in brackets here.
    ;The square brackets are analagous to dereferencing in c/c++.
    ;In the following line, we are moving the *contents* of int1 to eax, rather than the memory address.
    ;More info: https://stackoverflow.com/questions/48608423/what-do-square-brackets-mean-in-x86-assembly
    ;On input (e.g. scanf), we *do not* use square brackets.
    ;When moving data, we *do* use square brackets.
    ;On output (e.g. printf), we *do* use square brackets.
    mov eax, [int1]         ;Move user input into eax.
    cmp eax, 0
    jns .display_results    ;Jump if not negative.

    ;if (int1 > -1)
    cmp eax, -1             ;Redundant
    jg .invalid_entry       ;If input is greater than -1, jump to invalid_entry.

    ;if (int1 >= -50)
    cmp eax, -50
    jge .add_to_total       ;If input is greater than or equal to -50, jump to add_to_total.

    ;if (int1 < -200)
    cmp eax, -200
    jl .invalid_entry       ;If input is less than -200, jump to invalid_entry.

    ;if (int1 > -100)
    cmp eax, -100
    jg .invalid_entry       ;If input is greater than -100, jump to invalid_entry.

    ;Fall through to add_to_total.

    ;It is also possible to loop using ecx and the loop instruction. Example:
    ;https://stackoverflow.com/questions/2209419/how-to-make-a-loop-in-x86-assembly-language
    ;Most students will not do this because doing a jump is easier.
    ;The loop instruction will decrement ecx and perform a jump if ecx != 0.
    ;In that way, it is closer to a for loop than a while loop.

;The following three update variables.
.add_to_total:
    add [sum], eax          ;eax is user input.
    inc ebx                 ;ebx holds count.

    ;if (int1 > min)
    cmp eax, [inmin]
    jg .new_min             ;Jump if new minimum is found.

    ;if (int1 < max)
    cmp eax, [inmax]
    jl .new_max             ;Jump if new maximum is found.
    jmp .input_loop         ;If not caught elsewhere, return to input loop.

.new_min:
    mov [inmin], eax

    ;if (int1 < max) ;In case of first entry, insert to both min and max.
    cmp eax, [inmax]
    jl .new_max
    jmp .input_loop         ;Return to input loop.

.new_max:
    mov [inmax], eax
    jmp .input_loop         ;Return to input loop.

;Informs user of invalid entry and returns to loop.
.invalid_entry:
    push dword badnum       ;"Invalid number."
    call printf
    add esp, 4
    jmp .input_loop         ;Return to input loop.

;Displays count, sum, max, min, and mean of entered values. Skips if count is 0.
.display_results:
    cmp ebx, 0
    je .no_entries          ;No entries. Nothing to do!

    xor eax, eax            ;Xor register with itself to empty/set all bits to 0.
    xor edx, edx
    mov eax, [sum]          ;Move sum to eax, the numerator of fraction.
    cdq                     ;Always do this before a div or idiv.
    idiv ebx                ;ebx is count, and is denominator of fraction.
    mov [mean], eax         ;Division result stored in eax, move into variable.

    push ebx
    push dword count        ;"Count: %i"
    call printf
    add esp, 8

    push dword [sum]
    push dword dissum       ;"Sum: %i"
    call printf
    add esp, 8

    push dword [inmax]
    push dword dismax       ;"Max: %i"
    call printf
    add esp, 8

    push dword [inmin]
    push dword dismin       ;"Min: %i"
    call printf
    add esp, 8

    push dword [mean]
    push dword dimean       ;"Mean: %i"
    call printf
    add esp, 8
    
    jmp .end

;Special message if count is zero.
.no_entries:
    push nocnt              ;"No valid entries. Nothing to display."
    call printf
    add esp, 4

.end: 
    push dword name
    push dword bye          ;"Goodbye, %s."
    call printf
    add esp, 8

    mov esp, ebp
    pop ebp

    mov eax, 0
    ret                     ;return 0, similar to c/c++