.type printX, @function
.globl printX
printX:
    push %rbp
    movq %rsp, %rbp

    # save registers
    push %rax
    push %rdi
    push %rsi
    push %rdx
    push %rcx
    push %r8
    push %r9

    movq %rdi, %rax # Load the number to be printed

    movq $1, %r9    # This will count the number of digits, starting with 1 for the \t
	push $9         # Push ASCII value for '\t' onto the stack

.LprintNum_convertLoop:
    movq $0, %rdx   # Clear the high part for division
    movq $10, %rcx
    idivq %rcx      # Divide by 10, result in RAX, remainder in RDX
    addq $48, %rdx  # Convert remainder to ASCII
    push %rdx       # Push the ASCII character onto the stack
    incq %r9        # Increment digit count
    testq %rax, %rax# Check if quotient is 0
    jnz .LprintNum_convertLoop

.LprintNum_printLoop:
    movq $1, %rax   # sys_write
    movq $1, %rdi   # stdout
    movq %rsp, %rsi # point to top of stack (next character to print)
    movq $1, %rdx   # length = 1 character
    syscall
    addq $8, %rsp   # Adjust the stack pointer for the next character
    decq %r9        # Decrease the count of remaining characters to print
    jnz .LprintNum_printLoop

    # restore registers
    pop %r9
    pop %r8
    pop %rcx
    pop %rdx
    pop %rsi
    pop %rdi
    pop %rax

    pop %rbp
    ret
