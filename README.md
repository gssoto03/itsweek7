
# It's week 7. Oh no.

Here's some example code and some basic explanations/resources for this awful, awful week.

## Basics
Assembly is a low-level language that communicates with the cpu. In these programs, we use NASM and 32-bit registers along with the FPU. 

### Organization
There are 3 sections in Assembly.

`.data` - Used to declare initialized variables.

`.bss` - Used to declare uninitialized variables.

`.text` - Stores the code. Basically everything else.

### Reading Assembly Code
I have some explanations on `.data` and `.bss` in the comments of program 1, but how do I read the code?

Let's dissect a line.

`add esp, 4`

The first words define what action is being taken. In this case, we're adding some values. The first operand, `esp`, is the destination, and the second operand, 4, is the source. So, this line is adding 4 to `esp`. Different versions of Assembly may have destination and source swapped. Fun.


Now a small code chunk.
```
push dword name
push dword ninput
call scanf
```
Here, we're calling the function scanf and passing some values into it. The `push` is the action to move the `name` variable into the function as a parameter. The `dword` describes the size of the variable, in this case 32-bits. 

The order matters! In c, we would call this function using `scanf(ninput, name);`, but Assembly is so ass-backwards that we have to feed the variables in reverse! So, push name, then ninput, then call scanf.

One more.

```
main:
...
.welcome:
```
These are labels. They are both technically the same thing and are the result of naming conventions in Assembly. The first line generally refers to function labels and the second line refers to labels within functions.
We want labels so that we can `jmp` to them. 

What's the FPU? We'll get to that later.

### Registers
We have 8 registers. Don't mess with the stack registers. ESI and EDI sometimes don't place nice. The rest are free game (mostly).

`eax` - Accumulator. Used for arithmetic operations and stores results of functions.

`ecx` - Counter used for string, loop, and shift operations.

`edx` - I\O pointer. Used for arithmetic and I\O operations.

`ebx` - A Base. Used as pointer to data.

`esp` - Pointer to top of stack. Shouldn't be used for anything else.

`ebp` - Pointer to base of stack. Shouldn't be used for anything else.

`esi` - Source index. Used as pointer to data and source pointer for string/stream operations.

`edi` - Destination index. Used as pointer to data (or destination) and destination pointer for string/stream operations.

## Program 1
This program sums and counts integer entries between [-200,-100] and [-50, -1]. Also tracks max and min values.

This program introduces all the basics. Here's a quick reference resource.
https://web.stanford.edu/class/cs107/resources/x86-64-reference.pdf

## Program 2
This program sums and counts float integers between [e,π] and [17, 41].

This program introduces the FPU. Here's an excellent introduction to what it is, how it works, and a function reference guide: https://www.website.masmforum.com/tutorials/fptute/index.html#intro

Here's another resource for quickly referencing FPU functions: https://redirect.cs.umbc.edu/courses/undergraduate/313/fall04/burt_katz/lectures/Lect12/floatingpoint.html

## Program 3
This program generates and prints 50 random numbers between [0, 1). You will be prompted to enter a number between 1000 and 10000 which is used as a key. The instructions are confusing, but users input a key to generate 50 random numbers on a loop.

This program introduces linking and using external functions from other files. 

## Program 4
This program finds the nth value of the Fibonacci sequence either recursively or iteratively.

This program introduces the creation and calling of Assembly functions (outside of main).