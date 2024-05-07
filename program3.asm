; Name: Gabriel Santana Soto
; Creation date: 26 February 2023
; Last modified: 7 May 2024
;
; 
; Name of file: program3.asm
; Description: Generates and prints random numbers based on input key.
		
; Assemble:	nasm -f elf -g -Wall -l program3.lst program3.asm
; Link:		gcc -m32 -g3 -O0 -Wall -Werror -std=c11 -pedantic -no-pie   -c -o mt19937.o mt19937.c
;           gcc -m32 -no-pie program3.o mt19937.o -o program3
; Run:		./program3
; Output:	Enter your name: G
;           Welcome to Gabriel's Program 2, G.
;           This program generates and prints 50 random numbers between [0, 1).
;           You will be prompted to enter a number between 1000 and 10000 which is used as a key.

;           Enter a number: 1234
;           0.191519450378892286    0.622108771039831865    0.437727739007114480    0.785358583713769209    0.779975808118803515     
;           0.272592605282641620    0.276464255143096693    0.801872177535019270    0.958139353683705175    0.875932634742094707     
;           0.357817269957866668    0.500995125523458706    0.683462935172136299    0.712702026982900194    0.370250754790394931     
;           0.561196186065624936    0.503083165307809721    0.013768449590682241    0.772826621612374032    0.882641190636116568     
;           0.364885983901372279    0.615396178433493701    0.075381241642976549    0.368824006001974514    0.933140101982521619     
;           0.651378143226577389    0.397202577726154193    0.788730142940745504    0.316836122168871248    0.568098652626069178     
;           0.869127389561225816    0.436173423895679369    0.802147642080159096    0.143766824514564573    0.704260971118335410     
;           0.704581308189572542    0.218792105674088577    0.924867628615565041    0.442140755404176633    0.909315958972472527     
;           0.059809222779851900    0.184287083813813646    0.047355278801515133    0.674880943582330195    0.594624779934448844     
;           0.533310162998750559    0.043324062694803489    0.561433080063397871    0.329668445620915018    0.502966833112618361     
;           Mean: 0.522542843127267509

;           Enter a number: q
;           Goodbye, G.

extern printf
extern scanf
extern atoi
extern init_genrand
extern genrand_res53

SECTION .data

    name:       db 20
    nameinput:  db "%s", 0
    nameprompt: db "Enter your name: ", 0
    wel:        db "Welcome to Gabriel's Program 3, %s.", 10, 0
    istn1:      db "This program generates and prints 50 random numbers between [0, 1).", 10, 0
    istn2:      db "You will be prompted to enter a number between 1000 and 10000 which is used as a key.", 10, 10, 0
    bye:        db "Goodbye, %s.", 10, 0
    istn3:      db "Enter a number: ", 0
    badnum:     db "Invalid number.", 10, 0
    dinput:     db "%s", 0
    disentry:   db "%0.18lf    ", 0
    endl:       db " ", 10, 0
    dismean:    db "Mean: %0.18lf", 10, 10, 0
    mean:       dq 0.0
    num_arr:    dq 50 DUP(0)
    arraysize:  dq 50.0
    magiczero:  dq 0.0

SECTION .bss

    checkin:    resb 50
    initnum:    resd 1

SECTION .text

global main

main:
    push ebp
    mov ebp, esp



;Prompts for name and outputs welcome and program instructions.
.welcome:
    push dword nameprompt      ;"Enter your name: " 
    call printf
    add esp, 4

    push dword name
    push dword nameinput        ;"%s"
    call scanf
    add esp, 8

    push dword name
    push dword wel              ;"Welcome to Gabriel's Program 3, %s."
    call printf
    add esp, 4
    push dword istn1            ;"This program generates and prints 50 random numbers between [0, 1)."
    call printf
    add esp, 4
    push dword istn2            ;"You will be prompted to enter a number between 1000 and 10000 which is used as a key."
    call printf
    add esp, 4

    mov ebx, 0                  ;Clear ebx and eax. Both are not used for anything in particular in the next section.
    mov eax, 0
    finit



;Loops until q is entered. Verifies if input is a valid number between 1000 and 10000.
.input_loop:
    push dword istn3            ;"Enter a number: "
    call printf
    add esp, 4

    xor ebx, ebx                ;Clear ebx.
    mov [checkin], ebx          ;Clear checkin.

    push dword checkin
    push dword dinput           ;"%s"
    call scanf
    add esp, 8

    ;Exits program if 'q' is entered.
    mov eax, [checkin]
    cmp eax, 'q'                ;Yes, this is valid.
    je .end                     ;If eax is equal to 'q', then jump to end.

    push dword checkin
    call atoi                   ;Turns input string (checkin) into a number.
    add esp, 4
    test eax, eax
    jz .invalid_entry           ;If zero flag set, catch zero flag and jump to invalid_entry.

    mov [initnum], eax
    mov ebx, [initnum]          ;Cannot cmp variables with other values directly, must move to register first.

    ;if (initnum > 10000)
    cmp ebx, 10000
    jg .invalid_entry           ;If initnum is greater than 10000, then jump to invalid_entry.

    ;if (initnum < 1000)
    cmp ebx, 1000
    jl .invalid_entry           ;If initnum is less than 1000, then jump to invalid_entry.
    jmp .initialize             ;Else jump to initialize.


;Informs user of invalid entry and returns to loop.
.invalid_entry:
    push dword badnum           ;"Invalid number."
    call printf
    add esp, 4
    jmp .input_loop             ;Jump back to input_loop.



;Inserts key into function, prepares the FPU for calculations, and begins counters for loop.
.initialize:
    fld qword [magiczero]       ;The sum will be stored here, so I initialized with 0.

    push dword [initnum]
    call init_genrand           ;Must call this function with key to generate random numbers.
    add esp, 4

    mov esi, 0                  ;Sets line_count to 0.
    mov ebx, 0                  ;Sets loop_count to 0.



;Fills array, displays number generated, adds number to accumulated sum. Loops until array is full.
.display_data_loop:
    call genrand_res53          ;Generates one random number and inserts into fpu.
    fstp qword num_arr[ebx * 8] ;Store random number in num_arr, then pop fpu.
    
    push dword num_arr[ebx * 8 + 4]
    push dword num_arr[ebx * 8]
    push dword disentry         ;"%0.18lf    "
    call printf
    add esp, 12

    fadd qword num_arr[ebx * 8] ;Adds random number to sum in fpu.

    inc ebx                     ;Loop_count++
    inc esi                     ;Line_count++
    cmp esi, 5
    je .newline                 ;If line_count is equal to 5, then jump to newline.

    ;Shouldn't actually hit this section.
    cmp ebx, 50
    jl .display_data_loop       ;If loop_count is lower than 50, then jump to display_data_loop.
    jmp .input_loop             ;Else jump to input_loop.



;Makes a newline every 5 numbers. Also prints the average.
.newline:
    push dword endl             ;" ", 10, 0
    call printf
    add esp, 4

    mov esi, 0                  ;Reset line_count to 0.
    cmp ebx, 50
    jl .display_data_loop       ;If loop_count is less than 50, then jump to display_data_loop.

    fdiv qword [arraysize]      ;Divide sum by 50, then store result in st0.
    fstp qword [mean]           ;Store st0 in mean, then pop fpu. Fpu should now be empty.

    push dword [mean + 4]
    push dword [mean]
    push dword dismean          ;"Mean: %0.18lf"
    call printf
    add esp, 12

    jmp .input_loop             ;Jump back to input_loop.



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