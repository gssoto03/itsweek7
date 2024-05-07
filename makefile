OBJS = program1.o program2.o program3.o mt19937.o program4.o
CSRCS = mt19937.c
ASRCS = program1.asm program2.asm program3.asm program4.asm
AOBJS = program1.o program2.o program3.o program4.o
COBJS = mt19937.c
PRGM1OBJS = program1.o 
PRGM2OBJS = program2.o
PRGM3OBJS = program3.o
PRGM4OBJS = program4.o
MTOBJS = mt19937.o
AFLAGS = -f elf -g -Wall
CFLAGS = -m32 -g3 -O0 -Wall -Werror -std=c11 -pedantic -no-pie
LDFLAGS = -m32 -no-pie
TARGETS = program1 program2 program3 program4
LISTINGS = program1.lst program2.lst program3.lst program4.lst
AS = nasm
CC = gcc

all: $(TARGETS)

.PHONY: clean

$(AOBJS): $(ASRCS)
	$(AS) $(AFLAGS) -l $(@:.o=.lst) $(@:.o=.asm)

$(COBJS): $(CSRCS)
	$(CC) $(CFLAGS) -c $(@:.o=.c) 

program1: $(PRGM1OBJS)
	$(CC) $(LDFLAGS) $(<) -o $(@)

program2: $(PRGM2OBJS)
	$(CC) $(LDFLAGS) $(<) -o $(@)

program3: $(PRGM3OBJS) $(MTOBJS)
	$(CC) $(LDFLAGS) $(<) $(MTOBJS) -o $(@)

program4: $(PRGM4OBJS)
	$(CC) $(LDFLAGS) $(<) -o $(@)

clean:
	rm -f $(OBJS) $(LISTINGS) $(TARGETS)