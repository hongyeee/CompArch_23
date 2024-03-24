# Makefile for main.s using AT&T syntax

# Output executable name
TARGET = sorter

# Source assembly files
SOURCES = sorter.s allocate.s fileHandling.s parsing.s printX.s printY.s

# Object files corresponding to SOURCES
OBJECTS = $(SOURCES:.s=.o)

# Assembler and linker flags
ASFLAGS = -g              # No specific flags, as GNU Assembler defaults to AT&T syntax for x86_64
LDFLAGS = -m elf_x86_64 # Use the 64-bit linker

all: $(TARGET)

$(TARGET): $(OBJECTS)
	ld $(LDFLAGS) -o $(TARGET) $(OBJECTS)

%.o: %.s
	as $(ASFLAGS) -o $@ $<

clean:
	rm -f $(TARGET) $(OBJECTS)

.PHONY: all clean
