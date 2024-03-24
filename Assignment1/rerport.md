# 1. Introduction

This project involves the implementation of a program in x86-64 Linux
assembly language. The program's primary task is to read (x, y)
coordinates from a given file, sort them based on their y-values, and
output the sorted coordinates. This report provides a comprehensive
explanation of the code implementation while evaluating its performance.

# 2. Design Decisions

Bubble Sort was selected due to its straightforward logic and inherent
in-place sorting nature. The mechanism involves iterating over the list
multiple times, comparing neighboring elements, and making swaps when
necessary until the entire list becomes ordered. Given the scope of this
project---working with (x, y) coordinates and ensuring a clear
demonstration of assembly language programming---the ease of Bubble
Sort's implementation made it an appropriate choice. Although it may not
be the most efficient for extensive datasets, its implementation in
assembly language serves as an effective illustration of sorting
algorithms in a low-level language setting.

# 3. Implementation

The process began by configuring an array to store the (x, y)
coordinates read from the input file. Each element of the array
represented a coordinate pair. Proper initialization and memory
allocation were guaranteed. Following this setup, the Bubble Sort
algorithm was employed to sort these coordinates based on their
y-values. The sorted (x, y) pairs were then formatted and outputted in
the same format as the input file.

## 3.1 Bubble Sort Implementation

The Bubble Sort implementation aims to sort the (x, y) coordinates based
on their y-values. The sorting process takes advantage of registers for
optimized handling of data during the sorting mechanism.

### 3.1.1 Initialization

Initially, the starting address of the parsed data is backed up in the
`%r8` register. The number of (x, y) pairs is loaded into the `%r9`
register. By shifting left by 4, it's converted to bytes, since each
pair is 16 bytes: 8 bytes for x and 8 for y. The `%r9` register is then
updated to point to the end of the list.

### 3.1.2 Outer Loop

The outer loop is responsible for going through the entire array. The
start address for this loop is stored in the `%r10` register, and the
swap flag is initialized to 0 using `%r15` register.

### 3.1.3 Inner Loop and Swapping

``` gas
inner_loop:
    ...
    movq 8(%r10), %r11         
    cmpq -8(%r10), %r11        
    jge no_swap                

    ...
    movq $1, %r15              
    jmp inner_loop             
```

The inner loop performs comparisons between adjacent (x, y) pairs based
on their y-values. If the y-value of the current pair is smaller than
the y-value of the next pair, the pairs are swapped. The swap operation
involves saving the values of the pairs in temporary registers and then
interchanging their positions in the array. Once a swap occurs, the swap
flag is set to 1.

### 3.1.4 Checking and Finalizing

``` gas
check_swap:
    testq %r15, %r15           
    jz sorting_done            

    subq $16, %r9              
    cmpq %r9, %r8              
    je sorting_done
    jmp outer_loop             
```

After completing the inner loop, the program checks if any swaps were
made using the swap flag. If no swaps occurred, the sorting process is
complete. If swaps did happen, the pointer indicating the end of the
current scope for sorting is decremented, and the outer loop is executed
again. This narrowing of scope ensures optimization in the number of
comparisons made during the sort.

### 3.1.5 Termination

Upon ensuring that the data is fully sorted, the program exits the
sorting routine.

## 3.2 Print

Following the sorting of the coordinates, the program proceeded with the
printing function. This function traversed the sorted data array, with
the `r8` register serving as a pointer and the `r9` register managing
the loop count.

To print the (x, y) coordinate pairs, the program employed two distinct
procedures: printX and printY. The printX procedure was responsible for
displaying the x-coordinate, followed by a tab character. Conversely,
the printY procedure showcased the y-coordinate, ending with a newline
character. Each coordinate was loaded into the `rdi` register before the
respective print function was invoked, ensuring accurate representation
and formatting during the printing process.

The program continued this process until all coordinate pairs from the
sorted array were printed.

## 3.3 Error Handling

Various error-handling routines have been incorporated in the program to
address potential issues that might arise during its execution. The
following are the identified error conditions:

-   **No Filename Argument**: Triggered when no filename is provided as
    a command-line argument.

-   **Too Many Arguments**: Activated when multiple arguments are
    passed, which the program doesn't expect.

-   **Open Error**: Occurs when the program encounters issues opening a
    specified file.

-   **Read Error**: Arises when the program fails to read the content of
    the file.

-   **Partial Read Error**: This error is encountered when there's a
    problem during file reading, possibly due to unexpected EOF or file
    corruption.

-   **No Lines in File**: Triggered when the file being processed
    contains no lines.

All these error handlers invoke the `handle_error` routine to display
the corresponding error message and subsequently exit the program.

# 4. Program Evaluation

This section systematically presents the performance evaluation of the
sorting program, with datasets of varying sizes, and offers a
comprehensive discussion of the results, comparing the observed findings
with theoretical expectations.

## 4.1 Dataset and Procedure

Datasets of coordinates, ranging from 10,000 to potentially 5,000,000,
were employed for the assessment. To ensure robustness, each dataset
size was subjected to three trials.

**Benchmarking Steps:**

1.  Generate uniformly random coordinates across multiple instances for
    each dataset size.

2.  Record the program's "real"/"wall" time using the `time` command.

3.  Count the number of comparison operations during each sorting
    process.

4.  Derive the rate of comparisons per second for each test instance.

## 4.2 Runtime Evaluation and Discussion

   |number of coordinates | time in seconds | cmp Instructions per second|
   |:---:|:---:|:---:|
   |10,000|0.125|799,716,480|
   |50,000|4.501|555,427,535|
   |100,000|17.997|555,556,611|
   |500,000|440.835|567,137,667|
   |1,000,000|1851.317| 540,203,207|

  Table 1 : Runtimes and cmp Instructions per second of the sorting program.

The data reveals a notable trend: smaller datasets have a comparatively
higher rate of 'cmp' instructions per second. Several factors underpin
this observation:

-   **Startup Overhead**: Such overheads have a more pronounced effect
    on smaller datasets, elevating their 'cmp' rates.

-   **Memory Hierarchy**: Smaller datasets benefit from efficient cache
    utilization, which expedites comparisons.

-   **Algorithmic Behavior**: While Bubble Sort tends to have a
    quadratic behavior, certain inputs or early termination conditions
    might influence its performance.

## 4.3 Theoretical Complexity Evaluation and Discussion

   |number of coordinates|theoretical complexity|cmp Instructions|
   |:---:|:---:|:---:|
   |10,000|100,000,000|99,964,560|
   |50,000|2,500,000,000|2,499,904,418|
   |100,000|10,000,000,000|9,999,618,570|
   |500,000|250,000,000,000|249,996,989,360|
   |1,000,000|1,000,000,000,000|999,996,505,180|

  Table 2 : Comparison of theoretical complexity and observed cmp Instructions.

The table above compares the theoretical complexity of Bubble Sort
($O(n^2)$) with the observed number of comparisons. It's evident that
the actual program performance closely mirrors the theoretical
expectations, even if there are minor deviations due to machine-specific
or input-specific conditions.

Such alignment between theory and practice underscores the reliability
of the implemented sorting program. It also suggests that while Bubble
Sort may not be the most efficient for larger datasets, the consistency
in its behavior can be leveraged for datasets within the observed size
range.

## 4.4 Overhead time Evaluation and Discussion

   |number of coordinates|time in seconds| 
   |:---:|:---:|
   |10,000|0.036|       
   |50,000|0.180|       
   |100,000|0.364|      
   |500,000|1.839|      
   |1,000,000|3.64|9      

  Table 3 : Running time excluding the sorting time.

The table above illustrates the correlation between the number of
coordinates and the corresponding overhead time, excluding the sorting
time. As the number of coordinates in the file increases, the overhead
time exhibits a linear growth pattern, aligning with the theoretical
expectation of $O(n)$ complexity. This linear relationship validates the
theoretical analysis, demonstrating that the program's overhead time
scales linearly with the file size, a characteristic expected in $O(n)$
algorithms.

# 5. Discussion

The implementation of the Bubble Sort algorithm in assembly language
provided an opportunity to examine algorithm performance at a granular
level. Several observations and insights emerged from this
investigation:

-   **Performance Discrepancies**: While the program evaluation revealed
    a stark increase in runtime for larger datasets, this is consistent
    with Bubble Sort's $O(n^2)$ time complexity. Despite this expected
    behavior, smaller datasets were sorted quite efficiently, hinting
    that the algorithm's simplicity can be advantageous for certain
    applications or size constraints.

-   **Assembly's Intimate Interaction**: Programming in assembly allowed
    for a detailed observation of the program's operations. For example,
    the direct tracking of comparison instructions gave a precise
    measure of the algorithm's inner workings and reinforced the
    theoretical complexities of Bubble Sort.

-   **Cache Utilization**: The varying rates of 'cmp' instructions per
    second, especially with smaller datasets, highlight the importance
    of hardware-level intricacies like cache memory. When datasets fit
    well within cache sizes, retrieval times decrease, leading to faster
    comparisons and an overall boost in performance.

The results underscore the significance of algorithmic choices,
especially in low-level languages like assembly. While more efficient
algorithms might be chosen for larger datasets, understanding the
foundational principles and performance characteristics of simpler
algorithms like Bubble Sort remains crucial.

# 6. Conclusion

In this project, we explored low-level programming and algorithm design
using Bubble Sort as a case study. Its behavior in assembly, along with
performance insights, underscores its importance as a basic sorting
method.
