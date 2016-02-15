LIBS = $(wildcard libs/*/*.c)
CFLAGS = -std=c99 -Ilibs -Wall -lm -lcurl
STANDALONEFLAGS = -Wl,-rpath=libs -Llibs

all:
	$(CC) -o stobo *.c $(LIBS) $(CFLAGS)

standalone:
	$(CC) -o stobo-standalone *.c $(LIBS) $(CFLAGS) $(STANDALONEFLAGS) 
