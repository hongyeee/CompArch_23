CC = gcc
TARGET = detectCycles

all: $(TARGET)

$(TARGET): LinkedList.o Graph.o cycleDetection.o main.o
	$(CC) -o $(TARGET) LinkedList.o Graph.o cycleDetection.o main.o

LinkedList.o: LinkedList.c
	$(CC) -c -o LinkedList.o LinkedList.c

Graph.o: Graph.c
	$(CC) -c -o Graph.o Graph.c

cycleDetection.o: cycleDetection.c
	$(CC) -c -o cycleDetection.o cycleDetection.c

main.o: main.c
	$(CC) -c -o main.o main.c

clean:
	rm -f *.o $(TARGET)
