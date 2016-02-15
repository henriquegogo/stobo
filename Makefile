SRC = $(wildcard *.c)
LIBS = $(wildcard libs/*/*.c)
CFLAGS = -std=c99 -Ilibs -Wall -lm -lcurl
STANDALONEFLAGS = -Wl,-rpath=libs -Llibs

all:
	$(CC) -o stobo $(SRC) $(LIBS) $(CFLAGS)

standalone:
	$(CC) -o stobo-standalone $(SRC) $(LIBS) $(CFLAGS) $(STANDALONEFLAGS) 
