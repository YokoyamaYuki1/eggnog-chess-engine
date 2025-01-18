CFILES = main.c \
         syzygy.c \
         bitboard.c \
         board.c \
         perft.c \
         uci.c \
         search.c \
         timeman.c \
         transposition.c \
         Fathom/*.c \
         nnue.c \
         see.c \
         nnom.c \
         moveorder.c

AVX2_OBJS = $(CFILES:.c=.c.avx2.o)
AVX_OBJS = $(CFILES:.c=.c.avx.o)
SSE2_OBJS = $(CFILES:.c=.c.sse2.o)
SSE_OBJS = $(CFILES:.c=.c.sse.o)
POPCNT_OBJS = $(CFILES:.c=.c.popcnt.o)

OS = linux
RELEASE = false
FILE = ./bin/eggnog-chess-engine
COMMONFLAGS = -O3 -fcommon

ifeq ($(RELEASE), true)
COMMONFLAGS = -O3 -fcommon -DRELEASE
endif

ifeq ($(OS), linux)
EXECUTABLE_FILENAME =
CC=gcc
LINK_OPTS = -lpthread -lm
else ifeq ($(OS), mac)
EXECUTABLE_FILENAME =
CC=gcc
LINK_OPTS = -lpthread -lm
else
EXECUTABLE_FILENAME =.exe
CC=x86_64-w64-mingw32-gcc
LINK_OPTS = -lm
endif

release:
	mkdir -p ./bin/eggnog-windows
	mkdir -p ./bin/eggnog-linux
	cp ./bin/network.nnom ./bin/eggnog-windows/
	cp ./bin/network.nnom ./bin/eggnog-linux/
	cp ./bin/network.nnue ./bin/eggnog-linux/
	cp ./bin/network.nnue ./bin/eggnog-windows/

	make all
	mv ./bin/eggnog-chess-engine* ./bin/eggnog-linux/
	make clean
	make all OS=win
	mv ./bin/eggnog-chess-engine* ./bin/eggnog-windows/
	make clean

all: avx2 avx sse sse2 popcnt

avx2: $(AVX2_OBJS)
	$(CC) $(AVX2_OBJS) $(LINK_OPTS) -o $(FILE)-avx2-$(OS)$(EXECUTABLE_FILENAME)

avx: $(AVX_OBJS)
	$(CC) $(AVX_OBJS) $(LINK_OPTS) -o $(FILE)-avx-$(OS)$(EXECUTABLE_FILENAME)

sse2: $(SSE2_OBJS)
	$(CC) $(SSE2_OBJS) $(LINK_OPTS) -o $(FILE)-sse2-$(OS)$(EXECUTABLE_FILENAME)

sse: $(SSE_OBJS)
	$(CC) $(SSE_OBJS) $(LINK_OPTS) -o $(FILE)-sse-$(OS)$(EXECUTABLE_FILENAME)

popcnt: $(POPCNT_OBJS)
	$(CC) $(POPCNT_OBJS) $(LINK_OPTS) -o $(FILE)-popcnt-$(OS)$(EXECUTABLE_FILENAME)

%.c.avx2.o: %.c
	$(CC) $< $(COMMONFLAGS) -D AVX2 -mavx2 -c -o $@

%.c.sse.o: %.c
	$(CC) $< $(COMMONFLAGS) -D SSE -msse -c -o $@

%.c.sse2.o: %.c
	$(CC) $< $(COMMONFLAGS) -D SSE2 -msse2 -c -o $@

%.c.avx.o: %.c
	$(CC) $< $(COMMONFLAGS) -D AVX -mavx -c -o $@

%.c.popcnt.o: %.c
	$(CC) $< $(COMMONFLAGS) -D POPCNT -mpopcnt -c -o $@

mingw:
	make OS=win

mingwj:
	make OS=win -j

debug:
	$(CC) $(CFILES) -pthread -o $(FILE)-debug

gdb:
	$(CC) $(COMMONFLAGS) -DAVX2 -mavx2 $(LINK_OPTS) $(CFILES) -g
	mv ./a.out ./bin/a.out

prof:
	$(CC) -pg $(LINK_OPTS) -fcommon -DAVX2 -mavx2 -O3 $(CFILES) -o $(FILE)-prof

clean:
	rm -f ./bin/a.out ./bin/gmon.out
	rm -f ./bin/eggnog-chess-engine*
	rm -f *.s
	rm -f *.o nnue/*.o Fathom/*.o
	rm -f $(AVX2_OBJS) $(AVX_OBJS) $(SSE2_OBJS) $(SSE_OBJS) $(POPCNT_OBJS)
