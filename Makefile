LIBS = $(wildcard libs/*/*.c)
CFLAGS = -Ilibs -Wall -lm -lcurl
STANDALONEFLAGS = -Wl,-rpath=libs -Llibs

all:
	$(CC) -o main main.c $(LIBS) $(CFLAGS)

standalone:
	$(CC) -o main-standalone main.c $(LIBS) $(CFLAGS) $(STANDALONEFLAGS) 