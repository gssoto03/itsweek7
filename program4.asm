; Name: Gabriel Santana Soto
; Creation date: 27 February 2023
; Last modified: 7 May 2024
;
; 
; Name of file: program4.asm
; Description: Calculates nth fibonacci number.
		
; Assemble:	nasm -f elf -g -Wall -l program4.lst program4.asm
; Link:		gcc -m32 -no-pie program4.o -o program4
; Run:		./program4
; Output:	Enter your name: G
;           Welcome to Gabriel's Program 4, G.
;           This program finds the nth value of the Fibonacci sequence either recursively or iteratively.
;           You will be prompted to enter a number an n value and to decide to recursively or iteratively calculate.

;           Enter an n: 50
;           Enter 'i' or 'r': r
;           Result: 12586269025
;           Inaccuracies arise and accumulate from floating point error. n_values below 79 are accurate.
;           Goodbye, G.

extern printf
extern scanf

SECTION .data

    name:       db 20
    nameinput:  db "%s", 0
    nameprompt: db "Enter your name: ", 0
    wel:        db "Welcome to Gabriel's Program 4, %s.", 10, 0
    istn1:      db "This program finds the nth value of the Fibonacci sequence either recursively or iteratively.", 10, 0
    istn2:      db "You will be prompted to enter a number an n value and to decide to recursively or iteratively calculate.", 10, 10, 0
    note:       db "Inaccuracies arise and accumulate from floating point error. n_values below 79 are accurate.", 10, 0
    bye:        db "Goodbye, %s.", 10, 0
    istn3:      db "Enter an n: ", 0
    istn4:      db "Enter 'i' or 'r': ", 0
    badnum:     db "Invalid value. Start over.", 10, 0
    ninput      db "%i", 0
    irinput:    db "%s", 0
    result:     db "Result: %.0f", 10, 0
    number:     dq 1.0
    magiczero:  dq 0.0

SECTION .bss

    n_value:    resd 1
    ir_value:   resb 3

SECTION .text

global main


;Uses recursion to calculate fibonacci. Each recursion decrements ebx, using it as a counter.
recursion:
    push ebp                    ;Initializes base and stack pointer for function.
    mov ebp, esp

    sub esp, 100                ;Assigns 100 bytes to function. 100 is an arbitrarily large value.
    mov ebx, [ebp + 8]          ;Moves function parameter (pushed value) to count (ebx).

    cmp ebx, -1
    je .print_result            ;If count is equal to -1, then jump to print_result.

    ;Starts with:
    ;a (num) = whatever
    ;b (st0) = 0
    ;c (st1) = 1
    fst qword [number]          ;a = b
    faddp st1, st0              ;c = b + c      //Pop moves st1 -> st0.
    fld qword [number]          ;b = a          //Load moves st0 -> st1.
    fxch                        ;b,c = c,b      //Swap.
                                ;Repeat n times recursively.  

    dec ebx                     ;count--
    push ebx
    call recursion              ;recursion(count)   //Call recursion and pass count to function.
    pop ebx                     ;Pop values as they return from function calls. Not strictly necessary.
    jmp .end                    ;Jump to end.

.print_result:
    push dword [number + 4]
    push dword [number]
    push dword result           ;"Result: %.0f"
    call printf
    add esp, 12

.end:
    ;Exact same process as the end of main.
    mov esp, ebp
    pop ebp

    mov eax, 0
    ret



;Uses ebx as a counter to iteratively calculate fibonacci.
iterative:
    push ebp                    ;Initializes base and stack pointer for function.
    mov ebp, esp

    sub esp, 100                ;Assigns 100 bytes to function. 100 is an arbitrarily large value.
    mov ebx, [ebp + 8]          ;Moves function parameter (pushed value) to count (ebx).

.add:
    cmp ebx, -1
    je .print_result            ;If count is equal to -1, then jump to print_result.

    ;Starts with:
    ;a (num) = whatever
    ;b (st0) = 0
    ;c (st1) = 1
    fst qword [number]          ;a = b
    faddp st1, st0              ;c = b + c      //Pop moves st1 -> st0.
    fld qword [number]          ;b = a          //Load moves st0 -> st1.
    fxch                        ;b,c = c,b      //Swap.
                                ;Repeat n times.

    dec ebx                     ;count--
    jmp .add                    ;Jump to add.

.return:
    push dword [number + 4]
    push dword [number]
    push dword result           ;"Result: %.0f"
    call printf
    add esp, 12

    ;Exact same process as the end of main.
    mov esp, ebp
    pop ebp

    mov eax, 0
    ret



main:
    push ebp
    mov ebp, esp



;Prompts for name and outputs welcome and program instructions.
.welcome:
    push dword nameprompt       ;"Enter your name: "
    call printf
    add esp, 4

    push dword name
    push dword nameinput        ;"%s"
    call scanf
    add esp, 8

    push dword name
    push dword wel              ;"Welcome to Gabriel's Program 4, %s."
    call printf
    add esp, 4
    push dword istn1            ;"This program finds the nth value of the Fibonacci sequence either recursively or iteratively."
    call printf
    add esp, 4
    push dword istn2            ;"You will be prompted to enter a number an n value and to decide to recursively or iteratively calculate."
    call printf
    add esp, 4

    finit
    fld qword [number]          ;Load 1 into fpu.
    fld qword [magiczero]       ;Load 0 into fpu.



;Loops until a valid n value is entered.
.n_number_loop:
    push dword istn3            ;"Enter an n: "
    call printf
    add esp, 4

    push dword n_value
    push dword ninput           ;"%i"
    call scanf
    add esp, 4
    test eax, eax
    jz .n_number_loop           ;If zero flag set, catch zero flag then jump to n_number_loop.

    mov eax, [n_value]

    ;if (n_value > 1000)
    cmp eax, 1000
    jg .invalid_entry           ;If n_values is greater than 1000, then jump to invalid_entry.

    ;if (n_value < 0)
    cmp eax, 0
    jl .invalid_entry           ;If n_value is less than 0, then jump to invalid_entry.



;Loops until 'i' or 'r' is entered. Decides iterative or recursive calls.
.ir_value_loop:
    push dword istn4            ;"Enter 'i' or 'r': "
    call printf
    add esp, 4

    push dword ir_value
    push dword irinput          ;"%s"
    call scanf
    add esp, 8

    ;if (ir_value == 'i')
    mov eax, [ir_value]
    cmp eax, 'i'
    je .iterative_call          ;If ir_value is equal to 'i', then jump to iterative_call.

    ;if (ir_value == 'r')
    cmp eax, 'r'
    je .recursive_call          ;if ir_value is equal to 'r', then jump to recursive_call.

    ;Fall through if neither is true.


;Restarts inputs if a user enters invalid value.
.invalid_entry:
    ;Reset
    xor eax, eax
    mov [n_value], eax
    mov [ir_value], eax

    push dword badnum           ;"Invalid value. Start over."
    call printf
    add esp, 4
    jmp .n_number_loop          ;Jump to n_number_loop.



;Calls recursion. Pushes n_value as parameter.
.recursive_call:
    mov eax, [n_value]
    push eax                    ;Push means to call recursive with a parameter. In this case, it is n.
    call recursion
    add esp, 4

    jmp .end                    ;Jump to end once function is done.



;Calls iterative. Pushes n_value as paramter.
.iterative_call:
    mov eax, [n_value]
    push eax                    ;Push means to call recursive with a parameter. In this case, it is n.
    call iterative
    add esp, 4
    
    ;Fall through to end once function is done.

;Goodbye and exit.
.end: 
    push dword note             ;"Inaccuracies arise and accumulate from floating point error. n_values below 79 are accurate."
    call printf
    add esp, 4

    push dword name
    push dword bye              ;"Goodbye, %s."
    call printf
    add esp, 8

    mov esp, ebp
    pop ebp

    mov eax, 0
    ret