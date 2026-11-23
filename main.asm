
.ORIG x3000

; Register custom TRAP routines
LD R0, INPUT_ADDR
STI R0, INPUT_VECTOR
LD R0, OUTPUT_ADDR
STI R0, OUTPUT_VECTOR

; Initialize runtime stack
LD R6, STACK_START
ADD R6, R6, #-1
STR R5, R6, #0
ADD R5, R6, #0

; Initialize head pointer
ADD R6, R6, #-1
AND R0, R0, #0
STR R0, R5, #-1

; Initialize heap
LD R0, HEAP_START
ST R0, NEXT_FREE
AND R0, R0, #0
ST R0, FREE_HEAD

; Display main menu
MAIN_LOOP
LEA R0, MENU
PUTS

; Read menu selection
READ_CHOICE
GETC
LD R1, NEG_ONE
ADD R1, R0, R1
BRn READ_CHOICE
ADD R2, R1, #-3
BRp READ_CHOICE
OUT

LD R1, NEG_ONE
ADD R1, R0, R1
BRz DO_PRINT
ADD R1, R1, #-1
BRz DO_ADD
ADD R1, R1, #-1
BRz DO_REMOVE
BRnzp QUIT

; Print linked list
DO_PRINT
LDR R0, R5, #-1
ADD R6, R6, #-1
STR R0, R6, #0
JSR PRINT_LIST
ADD R6, R6, #1
BRnzp MAIN_LOOP

; Add a number
DO_ADD
LEA R0, ADD_PROMPT
PUTS
TRAP x40

; Push number
ADD R6, R6, #-1
STR R0, R6, #0

; Push address of head pointer
ADD R0, R5, #-1
ADD R6, R6, #-1
STR R0, R6, #0

JSR ADD_NODE

ADD R6, R6, #2
BRnzp MAIN_LOOP

; Remove a number
DO_REMOVE
LEA R0, REMOVE_PROMPT
PUTS
TRAP x40

; Push number
ADD R6, R6, #-1
STR R0, R6, #0

; Push address of head pointer
ADD R0, R5, #-1
ADD R6, R6, #-1
STR R0, R6, #0

JSR REMOVE_NODE

ADD R6, R6, #2
BRnzp MAIN_LOOP

; Restore stack and quit
QUIT
LEA R0, GOODBYE
PUTS

ADD R6, R5, #0
LDR R5, R6, #0
ADD R6, R6, #1
HALT

; Main program constants
INPUT_ADDR    .FILL x4000
OUTPUT_ADDR   .FILL x5000
INPUT_VECTOR  .FILL x0040
OUTPUT_VECTOR .FILL x0041
STACK_START   .FILL xBFFF
HEAP_START    .FILL x6000
NEG_ONE       .FILL #-49

; Main program messages
MENU .STRINGZ "\n1. Print\n2. Add\n3. Remove\n4. Quit\nEnter choice: "
ADD_PROMPT .STRINGZ "\nEnter number to add: "
REMOVE_PROMPT .STRINGZ "\nEnter number to remove: "
GOODBYE .STRINGZ "\nGoodbye!\n"

; Print linked list subroutine
PRINT_LIST
ADD R6, R6, #-1
STR R7, R6, #0
ADD R6, R6, #-1
STR R5, R6, #0
ADD R5, R6, #0

LEA R0, LIST_MSG
PUTS

; Get head pointer
LDR R1, R5, #2
BRz PRINT_EMPTY

PRINT_LOOP
LDR R0, R1, #0
TRAP x41

LD R0, SPACE
OUT

; Move to next node
LDR R1, R1, #1
BRnp PRINT_LOOP
BRnzp PRINT_DONE

PRINT_EMPTY
LEA R0, EMPTY_MSG
PUTS

PRINT_DONE
LD R0, NEWLINE
OUT

; Restore stack frame
LDR R5, R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6, R6, #1
RET

; Print constants
SPACE .FILL #32
NEWLINE .FILL #10
LIST_MSG .STRINGZ "\nLinked list: "
EMPTY_MSG .STRINGZ "Empty"

; Heap variables
NEG_HEAP_END .FILL x9000
NEXT_FREE .BLKW #1
FREE_HEAD .BLKW #1

; Add node subroutine
ADD_NODE
ADD R6, R6, #-1
STR R7, R6, #0
ADD R6, R6, #-1
STR R5, R6, #0
ADD R5, R6, #0

; Get arguments from stack
LDR R1, R5, #2
LDR R2, R5, #3

; Check for reusable nodes
LD R3, FREE_HEAD
BRz ALLOC_NEW

LDR R0, R3, #1
ST R0, FREE_HEAD
BRnzp ADD_STORE

; Allocate new node
ALLOC_NEW
LD R3, NEXT_FREE
LD R0, NEG_HEAP_END
ADD R0, R3, R0
BRzp ADD_FULL

ADD R0, R3, #2
ST R0, NEXT_FREE

; Store data and next pointer
ADD_STORE
STR R2, R3, #0
AND R0, R0, #0
STR R0, R3, #1

; Find end of linked list
ADD_SEARCH
LDR R0, R1, #0
BRz ADD_LINK
ADD R1, R0, #1
BRnzp ADD_SEARCH

; Connect new node
ADD_LINK
STR R3, R1, #0
LEA R0, ADDED_MSG
PUTS
BRnzp ADD_DONE

ADD_FULL
LEA R0, FULL_MSG
PUTS

ADD_DONE
LDR R5, R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6, R6, #1
RET

ADDED_MSG .STRINGZ "\nNumber added.\n"
FULL_MSG .STRINGZ "\nMemory full.\n"

; Remove node subroutine
REMOVE_NODE
ADD R6, R6, #-1
STR R7, R6, #0
ADD R6, R6, #-1
STR R5, R6, #0
ADD R5, R6, #0

; Get arguments from stack
LDR R1, R5, #2
LDR R2, R5, #3

NOT R2, R2
ADD R2, R2, #1

; Search for matching node
REMOVE_LOOP
LDR R3, R1, #0
BRz NOT_FOUND

LDR R0, R3, #0
ADD R0, R0, R2
BRz REMOVE_FOUND

ADD R1, R3, #1
BRnzp REMOVE_LOOP

; Remove matching node
REMOVE_FOUND
LDR R0, R3, #1
STR R0, R1, #0

; Return node to free list
LD R0, FREE_HEAD
STR R0, R3, #1
ST R3, FREE_HEAD

LEA R0, REMOVED_MSG
PUTS
BRnzp REMOVE_DONE

NOT_FOUND
LEA R0, NOT_FOUND_MSG
PUTS

; Restore stack frame
REMOVE_DONE
LDR R5, R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6, R6, #1
RET

REMOVED_MSG .STRINGZ "\nNumber removed.\n"
NOT_FOUND_MSG .STRINGZ "\nNumber not found.\n"

.END
