LIBS = $(wildcard libs/*/*.c)
CFLAGS = -Ilibs -Wall -lm -lcurl

all:
	$(CC) -o main main.c $(LIBS) $(CFLAGS)
