; Name: Gabriel Santana Soto
; Creation date: 25 February 2023
; Last modified: 1 May 2023
;
; 
; Name of file: program2.asm
; Description: Performs basic statistics on valid entries.
		
; Assemble:	nasm -f elf -g -Wall -l program2.lst program2.asm
; Link:		gcc -m32 -no-pie program2.o -o program2
; Run:		./program2
; Output:	Enter your name: G
;           Welcome to Gabriel's Program 2, G.
;           This program sums and counts float integers between [e,π] and [17, 41].
;           It will continue prompting until 50 valid numbers are entered or a non-number is entered.

;           Enter a number: 3.1415
;           Enter a number: 17.5
;           Enter a number: 41.0
;           Enter a number: p
;           Count: 3
;           41.000000    17.500000    3.141500     
;           Sum: 61.641500
;           Max: 41.000000
;           Min: 3.141500
;           Mean: 20.547167
;           Goodbye, g.

extern printf
extern scanf

SECTION .data

    name:       dd 20
    nameinput:  db "%s", 0
    nameprompt: db "Enter your name: ", 0
    wel:        db "Welcome to Gabriel's Program 2, %s.", 10, 0
    istn1:      db "This program sums and counts float integers between [e,π] and [17, 41].", 10, 0
    istn2:      db "It will continue prompting until 50 valid numbers are entered or a non-number is entered.", 10, 10, 0
    bye:        db "Goodbye, %s.", 10, 0
    istn3:      db "Enter a number: ", 0
    badnum:     db "Invalid number.", 10, 0
    nocount:    db "No valid entries. Nothing to display.", 10, 0
    inmax:      dq 2.71828
    inmin:      dq 41.0
    dinput:     db "%lf", 0
    discount:   db "Count: %i", 10, 0
    disentry:   db "%lf    ", 0
    endl:       db " ", 10, 0
    dissum:     db "Sum: %lf", 10, 0
    dismax:     db "Max: %lf", 10, 0
    dismin:     db "Min: %lf", 10, 0
    dismean:    db "Mean: %lf", 10, 0
    sum:        dq 0.0
    mean:       dq 0.0
    mins_maxs:  dq 41.0, 17.0, 2.718281828459045
    num_arr:    dq 100 DUP(1.0) ;DUP(1.0) fills array with 1.0.
    int_1:      dq 1.0
    int_2:      dq 1.0

SECTION .bss

SECTION .text

global main

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
    push dword wel              ;"Welcome to Gabriel's Program 2, %s."
    call printf
    add esp, 4
    push dword istn1            ;"This program sums and counts float integers between [e,π] and [17, 41]."
    call printf
    add esp, 4
    push dword istn2            ;"It will continue prompting until 50 valid numbers are entered or a non-number is entered."
    call printf
    add esp, 4

    mov ebx, 0                  ;Setting count to zero.
    mov eax, 0                  ;Setting eax to zero, to be safe.
    finit                       ;Initialize the fpu. Must always be done before doing any float functions.

;Loops until 100 valid numbers entered or a non number character is entered.
.input_loop:
    cmp ebx, 100
    je .display_counts          ;if count == 100, jump to display_counts.

    push dword istn3            ;"Enter a number: "
    call printf
    add esp, 4

    ;What happens if the variable we're trying to push is greater than 32 bytes?
    ;Answer: You have to split up the 64 bit variable into left and right parts.
    ;Memory wise, this means they are separated by four bytes, hence the +4.
    ;The data is stored using little endian, so the bigger end is pushed first.
    ;DO NOT TRY TO COMPILE IN 64 BIT MODE TO "GET AROUND" THIS LIMITATION.
    push dword int_1 + 4
    push dword int_1
    push dword dinput           ;"%lf"
    call scanf
    add esp, 12
    test eax, eax               ;Less common way to compare with zero. Test sets the flags, in this case the zero flag.
    jz .display_counts          ;if zero flag is set, catch zero flag and jump to display_counts.

    ;Place to reference fpu instructions:
    ;https://redirect.cs.umbc.edu/courses/undergraduate/313/fall04/burt_katz/lectures/Lect12/floatingpoint.html

    ;We do not need to perform +4 here because we can push 64 bit variables into fpu.
    ;Notice 'qword'.
    fld qword [int_1]           ;Load input into st0.

    ;When performing an fcom, st0 is always the left operand and st# is always the right operand.
    ;Fpu has limited data storage. Keep track of the stack.

    ;if (e > int_1)
    fld qword mins_maxs[16]     ;Load e into st0, push input to st1.
    fcomip st0, st1             ;Compare st0 and st1, then pop st0. Input returns to st0.
    ja .invalid_entry           ;If e is above input, jump to invalid_entry.

    ;if (pi >= int_1)
    fldpi                       ;Load pi into st0, push input to st1.
    fcomip st0, st1
    jae .add_to_total           ;If pi is above input, jump to add_to_total.

    ;if (17 > int_1)
    fld qword mins_maxs[8]      ;Load 17 into st0, push input to st1.
    fcomip st0, st1
    ja .invalid_entry           ;If 17 is above input, jump to invalid_entry.

    ;if (41 < int_1)
    fld qword mins_maxs[0]      ;Load 41 into st0, push input to st1.
    fcomip st0, st1
    jb .invalid_entry           ;If 41 is below input, jump to invalid_entry.

    ;Fall through into add_to_total.

;The following four sections update variables.
.add_to_total:
    fst qword num_arr[ebx * 8]  ;Store st0 (input) in array[count * 8].
    inc ebx                     ;Increment count.

    ;if (min > int_1)
    fld qword [inmin]           ;Load minimum into st0, push input to st1.
    fcomip st0, st1             ;Compare st0 and st1, then pop st0. Input returns to st0.
    ja .new_min                 ;If min is above input, jump to new_min.

    ;if (max < int_1)
    fld qword [inmax]           ;Load maximum into st0, push input to st1.
    fcomip st0, st1 
    jb .new_max                 ;If maximum is below input, jump to new_max.
    jmp .add_to_sum             ;If neither new max or min, jump to add_to_sum.

.new_min:
    fst qword [inmin]

    ;if (max < int_1) //In case first entry.
    fld qword [inmax]
    fcomip st0, st1
    jb .new_max                 ;If max is below input, jump to new_max.
    jmp .add_to_sum             ;Else jump to add_to_sum.

.new_max:
    fst qword [inmax]
    ;Fall through to add_to_sum.

.add_to_sum:
    fadd qword [sum]            ;Add sum with st0 (input).
    fstp qword [sum]            ;Store st0 in sum, then pop st0. Fpu is now empty.
    jmp .input_loop             ;Jump back to input_loop.

;Informs user of invalid entry and returns to loop.
.invalid_entry:
    push dword badnum           ;"Invalid number."
    call printf
    add esp, 4
    ffree st0                   ;Frees st0. Several ways of doing this.
    jmp .input_loop             ;Jump back to input_loop.

;Displays count, sum, max, min, and mean of entered values. Skips if count is 0.
.display_counts:
    cmp ebx, 0
    je .no_entries              ;Count is zero. Nothing to do!

    push ebx
    push dword discount         ;"Count: %i"
    call printf
    add esp, 8
    dec ebx                     ;count--
    mov esi, 0                  ;set display_loop_count to zero.
    fld qword [mean]            ;Load mean into st0.

;Loops until every array value is displayed.
.display_entries:
    push dword num_arr[ebx * 8 + 4] ;array[count + 4]
    push dword num_arr[ebx * 8]     ;array[count]
    push dword disentry         ;"%lf    "
    call printf
    add esp, 12

    fadd qword [int_2]          ;Stores count, kinda. Count++ for each loop.
    dec ebx                     ;count--
    inc esi                     ;display_loop_count++
    cmp esi, 9
    je .newline                 ;If display_loop_count == 9, jump to newline.
    cmp ebx, 0
    jge .display_entries        ;If count is greater than or equal to 0, loop display_entries.
    jmp .display_data           ;Else jump to display_data.

;Adds a newline every 10th entry.
.newline:
    push dword endl             ;" ", 10, 0  //Lol
    call printf
    add esp, 4

    mov esi, 0                  ;Set display_loop_count back to zero.
    cmp ebx, 0
    jge .display_entries        ;If count is greater than or equal to 0, loop display_entries.

;Displays sum, max, min, and mean.
.display_data:
    push dword endl             ;" ", 10, 0
    call printf
    add esp, 4

    push dword [sum + 4]
    push dword [sum]
    push dword dissum           ;"Sum: %lf"
    call printf
    add esp, 12

    push dword [inmax + 4]
    push dword [inmax]
    push dword dismax           ;"Max: %lf"
    call printf
    add esp, 12

    push dword [inmin + 4]
    push dword [inmin]
    push dword dismin           ;"Min: %lf"
    call printf
    add esp, 12

    fdivr qword [sum]           ;Divides sum by st0 (count), stores result in st0.
    fstp qword [mean]           ;Store st0 (mean) in mean, then pop st0. Fpu is now empty.

    push dword [mean + 4]
    push dword [mean]
    push dword dismean          ;"Mean: %lf"
    call printf
    add esp, 12
    
    jmp .end

;Special message if count is zero.
.no_entries:
    push nocount                ;"No valid entries. Nothing to display."
    call printf
    add esp, 4

;Goodbye and exit.
.end: 
    push dword name
    push dword bye              ;"Goodbye, %s."
    call printf 
    add esp, 8

    mov esp, ebp
    pop ebp

    mov eax, 0
    ret