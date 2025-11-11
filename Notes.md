 # Registers

Registers are small memory chunks that are found within the cpu, making them fast. 

Mostly used for storing low sized data, and actual memory adresses.

---

## Genral Purpose Registers (GPRs)

These are the main working registers, doing the calculations and data holding/allocations.

There were originally *8* registers in the 32 bit version, but on the 64 bit version it has double that with *16* registers

The old registers start with the prefix `R` and the new ones have `E` which indicate Extended

| Register | Name | Descrption |
|----------|------|------------|
| RAX | Accumulator | Traditionally used for arithmetic, and to store return values of functions |
| RBX | Base | Used as a genral purpose register |
| RCX | Counter | Used as a loop counter in the `LOOP` instruction |
| RDX | Data | Often used with `RAX` to hold the upper 64 bbits in a multiplication when it rises to 128 bits |
| RSI | Source Index | The source pointer for string/memory |
| RDI | Destination Index | Destination pointer for string/memory
| RSP | Stack Pointer | **Crucial** Points to the program's stack |
| RBP | Base Pointer | **Crucial** Points to the base of the current function's stack |

The New 8 (R8 - R15) are trully general purpose registers.

---

## Hierarchy of registers

Lets take **RAX** for this example, 

- RAX - The full 64 bit register

- EAX - The lower 32 bit register of RAX

- AX - The lower 16 bit register of EAX

- AL - The lower 8 bit of AX

- AH - The higher 8 bit of AX

---

## Special Purpose Registers

### RIP (Instruction Pointer (formerrly EIP, IP))

Regarded as one of the most important registers within the CPU, and it holds the next instruction

It is changed by instruction like, 

- `JMP` (Jump)
- `CALL` (Call a function)
- `RET` (Return from a function

### RFLAGS

RFLAGS (formerly EFLAGS/FLAGS) is a 64 bit register where each bit (or small group of bits) is a "flag".

Set or cleared by arithmetic instructions (like CMP, ADD, SUB) to report status of the operation

Conditional jump instructions (like JE, JNE, JG) read these flags whether to jump 

**KEY FLAGS:**
ZF (Zero Flag): Set if the operation result was Zero
SF (Sign Flag): Set if the result was negative
CF (Carry Flag): Set if the results overflows 
OF (Overflow Flag): Set if the signed operation overflows

