.section .data

# Reserve space or store constants
filename:                .quad 0    # space for the filename
file_descriptor:         .quad 0    # store the file descriptor
buffer:                  .quad 0    # reserves 8 bytes to store the address of buffer
DataBuffer:              .quad 0    # Address for buffer to store the parsed Data
numLines:                .quad 0    # Address to store number of lines

# Error messages and their lengths
noarg_err_msg:                .string "Error: No filename provided as argument.\n"
.equ noarg_err_len, . - noarg_err_msg # computes the length of the error message

manyarg_err_msg:              .string "Error: Too many arguments.\n"
.equ manyarg_err_len, . - manyarg_err_msg # computes the length of the error message

open_error_msg:                .string "Error: Unable to open the file.\n"
.equ open_error_len, . - open_error_msg # computes the length of the open error message

read_error_msg:                .string "Error: Unable to read the file.\n"
.equ read_error_len, . - read_error_msg # computes the length of the read error message

partial_read_error_msg:        .string "Error: Error while reading the file.\n"
.equ partial_read_error_len, . - partial_read_error_msg # computes the length of the partial read error message

noLines_error_msg:             .string "Error: File contains 0 Lines.\n"
.equ noLines_error_len, . - noLines_error_msg # computes the length of the no Line error message

.section .bss

.section .text
.global _start

_start:
    # Get the number of command line arguments (including the program name)
    movq (%rsp), %rdi              # Move argument count to %rdi

    # Ensure that the user provided a filename as the second argument
    cmpq $2, %rdi                  # Compare argument count with 2
    jl no_argument                 # If less than 2, jump to 'no_argument' label
    jg too_many_arguments          # If greater than 2, jump to 'too_many_arguments' label

    # Retrieve the filename from the command line arguments
    movq 16(%rsp), %rdi            # Move the address of the second argument (filename) to %rdi
    movq %rdi, filename            # Save the filename's address in 'filename' variable
    movq $2, %rax                 # Set syscall number for sys_open in %rax
    movq filename, %rdi           # Get the address of the filename
    movq $0, %rsi                 # Use O_RDONLY flag to open the file in read-only mode
    syscall                       # Execute syscall

    # Check the result of sys_open to ensure the file opened without errors
    test %rax, %rax               # Test the return value in %rax
    js open_error                 # If the sign bit is set (indicating an error), jump to 'open_error' label

    # Store the file descriptor returned by sys_open
    movq %rax, file_descriptor   # Save the file descriptor in 'file_descriptor' variable

memoryAllocation:
    movq (file_descriptor), %rdi       # Move file descriptor into rdi register
    call getFileSize                   # Get size of the file
    movq %rax, %rbx                    # Store file size into rbx
    movq %rax, %rdi                    # Pass File size into rdi register for allocate call
    call allocate                      # Call allocate function
    movq %rax, buffer                  # Store the address of the allocated buffer

readToBuffer:
    movq $0, %rax                      # Set syscall number for sys_read (0 is the syscall code for read operation)
    movq (file_descriptor), %rdi       # Load file descriptor into %rdi (1st argument for sys_read)
    movq buffer, %rsi                  # Load the address of the buffer into %rsi (2nd argument for sys_read)
    movq %rbx, %rdx                    # Load number of bytes to read (file size) into %rdx (3rd argument for sys_read)
    syscall                            # Invoke the syscall. This will read the file and put its contents into the buffer
    cmpq $-1, %rax                     # Check for an error
    jl read_error                      # Jump to error handling if less than 0
    cmpq %rbx, %rax                    # Check if read bytes are equal to file size
    jne partial_read_error             # Jump to error handling if not equal

closeFile:
    movq $3, %rax                      # Set syscall number for sys_close (3 is the syscall code for close operation)
    movq (file_descriptor), %rdi       # Load file descriptor into %rdi (1st argument for sys_close)
    syscall                            # Invoke the syscall to close the file

getNumberOfCoordinates:
    # Set up arguments for the getLineCount function
    movq buffer, %rdi                  # Address of the buffer (with file content) to %rdi
    movq %rbx, %rsi                    # Size of the file to %rsi
    call getLineCount                  # Call getLineCount function
    movq %rax, numLines

    # Check if numLines is 0
    cmpq $0, numLines          # Compare the number of lines with 1
    je noLines_error           # If equal, jump to 'output_data' label

# newMemoryAllocation - Allocate memory for parsed coordinates
newMemoryAllocation:
    # Calculate the memory requirement for the parsed data
    shlq $4, %rax              # Multiply number of lines by 16 to account for both x and y (each 8 bytes)

    # Request memory allocation for parsed coordinates
    movq %rax, %rdi            # Move the required memory size to %rdi
    call allocate              # Call allocate function to get the memory
    movq %rax, DataBuffer      # Move the address of the allocated memory to DataBuffer

    movq DataBuffer, %rdx      # Move the address of the allocated memory to rdx
    movq buffer, %rdi          # Pass the address of the buffer (with file content) to %rdi
    movq %rbx, %rsi            # Pass the length of that buffer to %rsi

    # Parse the file content into (x, y) coordinate pairs
    call parseData

    # Check if numLines is 1, and if so, skip to output
    cmpq $1, numLines          # Compare the number of lines with 1
    je skip_sort               # If equal, jump to 'skip_sort' label

    # Sort the parsed coordinates based on y-values
    call sort_coordinates

skip_sort:
    # Print the sorted coordinates
    call output_data

exitProgram:
    # Prepare to exit the program
    movq $60, %rax                     # Set up for sys_exit syscall
    xorq %rdi, %rdi                    # Set exit status to 0 (success)
    syscall                            # Exit the program

# Bubble Sort
# Sort the parsed data based on y-coordinate using bubble sort
sort_coordinates:
    movq DataBuffer, %r8        # Backup the start address of parsed data for outer loop
    movq (numLines), %r9        # Store the number of (x, y) pairs for the loop counter
    shlq $4, %r9                # Convert to bytes (each pair is 16 bytes: 8 for x and 8 for y)
    addq %r8, %r9               # r9 points to the end of the list

outer_loop:
    movq %r8, %r10             # r10 points to the start of the list for the inner loop
    xorq %r15, %r15            # Initialize swap flag to 0

inner_loop:
    addq $16, %r10             # Point to the next pair first
    cmpq %r9, %r10             # If we've reached the end of the current scope, we stop
    je check_swap

    movq 8(%r10), %r11         # Load the y value of the next pair in r11
    cmpq -8(%r10), %r11        # Compare previous y value with the y value of the next pair
    jge no_swap                # If previous y is smaller or equal to the next, no need to swap

    # Swap the x, y pairs
    movq -16(%r10), %r12       # Load previous x
    movq -8(%r10), %r13        # Load previous y
    movq (%r10), %r14          # Load current x

    movq %r14, -16(%r10)       # Swap x
    movq %r11, -8(%r10)        # Swap y
    movq %r12, (%r10)          # Swap x
    movq %r13, 8(%r10)         # Swap y

    movq $1, %r15              # Set swap flag to 1
    jmp inner_loop             # Continue the inner loop

no_swap:
    jmp inner_loop             # Continue the inner loop

check_swap:
    testq %r15, %r15           # Test if swap flag is set
    jz sorting_done            # If no swaps were made, we're done

    subq $16, %r9              # Decrement the end pointer for the outer loop
    cmpq %r9, %r8              # Check if we've processed all pairs (beginning of the data)
    je sorting_done
    jmp outer_loop             # Continue the outer loop

sorting_done:
    ret

# Print parsed (x, y) coordinate pairs
output_data:
    movq DataBuffer, %r8               # Backup the start address of parsed data for looping
    movq (numLines), %r9               # Store the number of (x, y) pairs as our loop counter

print_loop:
    # Process and print x-coordinate:
    push %r8                           # Preserve current position in the data
    movq 0(%r8), %rdi                  # Load x value (64-bit representation of 16-bit number)
    call printX                        # Convert x value to string and print it
    pop %r8                            # Restore the current position in the data
    addq $8, %r8                       # Move to next 8-byte chunk (the y-coordinate)

    # Process and print y-coordinate:
    push %r8                           # Preserve current position in the data again for y-coordinate
    movq 0(%r8), %rdi                  # Load y value (similarly, a 64-bit representation of 16-bit number)
    call printY                        # Convert y value to string and print it
    pop %r8                            # Restore the current position in the data
    addq $8, %r8                       # Move to the next coordinate pair

    decq %r9                           # Decrease the loop counter
    testq %r9, %r9                     # Test if we've processed all pairs
    jg print_loop                      # If not, loop back and process the next pair

    ret                                # Return from the function


# Common Error Handling Routine
# Parameters:
#   rdi = address of the error message
#   rsi = length of the error message
handle_error:
    # Write error message to stderr
    movq $1, %rax               # System call number for sys_write
    movq $2, %rdi               # File descriptor for stderr
    syscall                     # Invoke system call to write error message

    # Exit program
    movq $60, %rax              # System call number for sys_exit
    xorq %rdi, %rdi             # Set exit status to 0
    syscall                     # Invoke system call to exit
    ret                         # Just a safety return, syscall for exit won't return anyway

# Handle an error while opening a file.
open_error:
    leaq open_error_msg(%rip), %rsi   # Pointer to the open error message
    movq $open_error_len, %rdx        # Length of the open error message
    call handle_error

# Handle when no argument is provided.
no_argument:
    leaq noarg_err_msg(%rip), %rsi    # Pointer to the no argument error message
    movq $noarg_err_len, %rdx         # Length of the error message
    call handle_error

# Handle when too many arguments are provided.
too_many_arguments:
    leaq manyarg_err_msg(%rip), %rsi    # Pointer to the no argument error message
    movq $manyarg_err_len, %rdx         # Length of the error message
    call handle_error

# Handle read error.
read_error:
    leaq read_error_msg(%rip), %rsi   # Pointer to the read error message
    movq $read_error_len, %rdx        # Length of the read error message
    call handle_error

# Handle partial read error.
partial_read_error:
    leaq partial_read_error_msg(%rip), %rsi   # Pointer to the partial read error message
    movq $partial_read_error_len, %rdx        # Length of the error message
    call handle_error

# Handle no Lines error.
noLines_error:
    leaq noLines_error_msg(%rip), %rsi   # Pointer to the no Lines error message
    movq $noLines_error_len, %rdx        # Length of the error message
    call handle_error
