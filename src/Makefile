LIBS = $(wildcard libs/*/*.c)
CFLAGS = -Ilibs -Wall -lm -lcurl

all:
	$(CC) $(CFLAGS) -g -o main main.c $(LIBS)
