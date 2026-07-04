# Module 2 Specification

## Unified Memory

**RTL File:** `unified_memory.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Unified Memory** is a single memory module used for storing both **instructions** and **data**.

Unlike the Single-Cycle processor, where Instruction Memory and Data Memory are separate, the Multi-Cycle processor accesses the same memory in different clock cycles. This allows a single memory block to perform both instruction fetch and data read/write operations.

---

# 2. Function

The Unified Memory performs the following functions:

- Stores the program instructions.
- Stores program data.
- Supplies instructions during the Instruction Fetch (IF) stage.
- Reads data during Load (`lw`) instructions.
- Writes data during Store (`sw`) instructions.
- Supports byte-addressable memory.

Only **one memory operation** (instruction fetch or data access) occurs during a clock cycle.

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `MemRead` | 1 | Input | Enables memory read operation |
| `MemWrite` | 1 | Input | Enables memory write operation |
| `address` | 32 | Input | Byte address supplied by the IorD MUX |
| `write_data` | 32 | Input | Data to be written into memory during Store instructions |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `read_data` | 32 | Output | Data or instruction read from memory |

---

# 4. Memory Specification

| Item | Specification |
|------|---------------|
| Memory Organization | Unified (Instruction + Data) |
| Data Width | 32 bits |
| Address Width | 32 bits |
| Memory Type | Word Addressable (32 - bit) |
| Access Width | Word (32-bit) |

---

# 5. Memory Depth

For our first implementation,

| Item | Value |
|------|-------|
| Number of Words | 256 or 1024 |
| Word Width | 32 bits |
| Total Memory Size | 1KB or 4KB |

Memory declaration:

```verilog
reg [31:0] memory [0: DEPTH - 1];
```

Here `DEPTH` can be parameterized.

---

# 6. Address Mapping

Since the processor is **byte-addressable**, the Program Counter increments by **4** for each instruction.

Therefore,

```text
Memory Index = Address[31:2]  or [pc >> 2]
```

Examples:

| Byte Address (PC output) | Memory Index |
|-------------:|-------------:|
| 0 | 0 |
| 4 | 1 |
| 8 | 2 |
| 12 | 3 |
| 16 | 4 |
| 20 | 5 |

Thus,

```verilog
memory[address[31:2]]
```

is used to access the memory.

---

# 7. Functional Specification

## Instruction Fetch

When

```text
MemRead = 1
MemWrite = 0
```

and the IorD MUX selects the Program Counter,

the memory outputs

```text
Instruction = memory[address[31:2]]
```

The instruction is then loaded into the **Instruction Register (IR)**.

---

## Load Instruction

When

```text
MemRead = 1
MemWrite = 0
```

and the IorD MUX selects the ALUOut register,

the memory outputs

```text
Data = memory[address[31:2]]
```

The data is then loaded into the **Memory Data Register (MDR)**.

---

## Store Instruction

When

```text
MemWrite = 1
MemRead = 0
```

the memory performs

```text
memory[address[31:2]] ← write_data
```

where

```text
write_data = Register B
```

---

# 8. Timing Specification

| Item | Specification |
|------|---------------|
| Read Operation | Combinational |
| Write Operation | Positive-edge triggered |
| Reset | Asynchronous Active-Low |

---

# 9. Reset Behavior

When

```text
reset = 0
```

the entire memory is cleared.

```verilog
for(i = 0; i < 64; i = i + 1)
    memory[i] <= 32'd0;
```

---

# 10. Interface Connections

<img width="371" height="501" alt="Screenshot 2026-07-03 095310" src="https://github.com/user-attachments/assets/abd619f1-27be-473c-aa78-16a45b5f5981" />


```text
                    +-----------+
PC ---------------->|           |
                    |           |
ALUOut ------------>| IorD MUX  |
                    |           |
                    +-----------+
                           │
                           ▼
                  +------------------+
                  |  Unified Memory  |
                  +------------------+
                     │           │
                     │           │
                     ▼           ▼
          Instruction Register   Memory Data Register
```

---

# 11. Control Signals Used

| Signal | Source |
|--------|--------|
| `MemRead` | Control FSM |
| `MemWrite` | Control FSM |
| `address` | IorD MUX |
| `write_data` | Register B |

---

# 12. Design Decisions

## Why Unified Memory?

A Multi-Cycle processor never fetches an instruction and accesses data in the same clock cycle.

Therefore, one memory block can be shared for both operations, reducing hardware resources.

---

## Why Byte Addressable?

RV32I uses byte-addressable memory.

Although each instruction occupies 4 bytes, memory addresses always represent byte locations.

---

## Why Use `address[31:2]`?

Memory is organized as an array of 32-bit words.

Removing the lower two address bits converts the byte address into the corresponding word index.

---

# 13. Design Assumptions

- RV32I Base ISA
- Von Neumann Architecture
- Byte-addressable memory
- Word-aligned accesses
- Single memory access per clock cycle
- Positive-edge synchronous writes
- Combinational reads

---

# 14. Future Scalability

This module can later support:

- Parameterized memory depth
- Byte, Halfword, and Word accesses (`lb`, `lh`, `lw`, `sb`, `sh`, `sw`)
- Memory initialization using `$readmemh`
- External RAM interface
- Block RAM implementation on FPGA

---

# 15. Verification Checklist

The testbench shall verify:

- Memory reset operation.
- Instruction fetch using the Program Counter.
- Load (`lw`) operation.
- Store (`sw`) operation.
- Simultaneous assertion of `mem_read` and `mem_write` is not allowed.
- Boundary address accesses.
- Consecutive read and write operations.

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `unified_memory.v` |
| Category | Datapath |
| Memory Type | Unified |
| Data Width | 32 bits |
| Address Width | 32 bits |
| Memory Depth | DEPTH × 32 bits |
| Total Size | Based on `DEPTH` size Bytes |
| Read | Combinational |
| Write | Positive-edge clock |
| Addressing | Byte Addressable (`address[31:2]`) |
| Outputs | `read_data` |
| Inputs | `clk`, `reset`, `MemRead`, `MemWrite`, `address`, `write_data` |
