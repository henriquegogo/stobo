BINNAME = stobo
SRC = $(wildcard src/*.c)
LIBS = $(wildcard libs/*/*.c)
CFLAGS = -std=c99 -Ilibs -Wall -lm -lcurl
STANDALONEFLAGS = -Wl,-rpath=libs -Llibs

all:
	$(CC) -o $(BINNAME) $(SRC) $(LIBS) $(CFLAGS)

run:
	./$(BINNAME)

standalone:
	$(CC) -o $(BINNAME)-standalone $(SRC) $(LIBS) $(CFLAGS) $(STANDALONEFLAGS) 

runstandalone:
	./$(BINNAME)-standalone

clean:
	rm $(BINNAME)
	rm $(BINNAME)-standalone
