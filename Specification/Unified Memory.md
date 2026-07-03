# Module 2 Specification

## Unified Memory

**RTL File:** `unified_memory.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Unified Memory** is a single memory module that stores both **program instructions** and **program data**.

Unlike the Single-Cycle processor, which uses separate Instruction Memory and Data Memory, the Multi-Cycle processor shares a single memory because instruction fetch and data access occur in different clock cycles.

This shared-memory organization follows the **Von Neumann Architecture**, reducing hardware resources while maintaining correct processor operation.

---

# 2. Function

The Unified Memory performs the following functions:

- Stores program instructions.
- Stores program data.
- Supplies instructions during the **Instruction Fetch (IF)** stage.
- Reads data during **Load (`lw`)** instructions.
- Writes data during **Store (`sw`)** instructions.
- Supports byte-addressable memory.

Since this is a Multi-Cycle processor, **only one memory operation (instruction fetch or data access) occurs during a single clock cycle.**

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `mem_read` | 1 | Input | Enables memory read operation |
| `mem_write` | 1 | Input | Enables memory write operation |
| `address` | 32 | Input | 32-bit byte address supplied by the **IorD MUX** (selected from either the Program Counter or the ALUOut register) |
| `write_data` | 32 | Input | Data written into memory during Store instructions (from Register B) |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `read_data` | 32 | Output | 32-bit instruction or data read from memory |

---

# 4. Memory Specification

| Item | Specification |
|------|---------------|
| Memory Organization | Unified (Instruction + Data) |
| Memory Type | Byte Addressable |
| Word Width | 32 bits |
| Address Width | 32 bits |
| Access Width | 32-bit Word |

---

# 5. Memory Depth

For the initial implementation,

| Item | Value |
|------|-------|
| Number of Words | 64 |
| Word Width | 32 bits |
| Total Storage | 256 Bytes |

Memory declaration:

```verilog
reg [31:0] memory [0:63];
```

The memory depth may later be parameterized to support larger programs.

---

# 6. Address Mapping

The processor generates **32-bit byte addresses**, whereas the memory is organized as an array of **32-bit words**.

Therefore, the byte address must be converted into a word index.

```text
Memory Index = Address / 4
             = Address >> 2
             = Address[31:2]
```

Hence, memory is accessed as

```verilog
memory[address[31:2]]
```

### Address Mapping Examples

| Byte Address | Word Index | Memory Access |
|-------------:|-----------:|---------------|
| 0 | 0 | `memory[0]` |
| 4 | 1 | `memory[1]` |
| 8 | 2 | `memory[2]` |
| 12 | 3 | `memory[3]` |
| 16 | 4 | `memory[4]` |
| 20 | 5 | `memory[5]` |

The lower two address bits (`address[1:0]`) represent the byte offset within a 32-bit word and are ignored for aligned word accesses.

---

# 7. Functional Specification

## Instruction Fetch (IF)

During the Instruction Fetch stage, the Control FSM generates

```text
mem_read  = 1
mem_write = 0
IorD      = 0
IRWrite   = 1
```

The IorD MUX selects the Program Counter as the memory address.

```text
Address = PC
```

The Unified Memory performs

```text
read_data = memory[address[31:2]]
```

Since

```text
IRWrite = 1
```

the fetched instruction is loaded into the Instruction Register.

```text
IR ← read_data
```

After the Instruction Fetch stage,

```text
IRWrite = 0
```

The Instruction Register then retains the fetched instruction throughout the Decode, Execute, Memory, and Write-Back stages.

---

## Load Instruction (`lw`)

During a Load instruction,

```text
mem_read  = 1
mem_write = 0
IorD      = 1
```

The IorD MUX selects the ALUOut register.

```text
Address = ALUOut
```

The Unified Memory performs

```text
read_data = memory[address[31:2]]
```

The data is loaded into the Memory Data Register (MDR).

```text
MDR ← read_data
```

---

## Store Instruction (`sw`)

During a Store instruction,

```text
mem_read  = 0
mem_write = 1
IorD      = 1
```

The IorD MUX selects the ALUOut register.

```text
Address = ALUOut
```

The Unified Memory performs

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

<img width="371" height="501" alt="image" src="https://github.com/user-attachments/assets/a8577936-e260-4b54-849d-1681f65ce1c9" />


---

# 11. Control Signals Used

| Signal | Source |
|--------|--------|
| `mem_read` | Control FSM |
| `mem_write` | Control FSM |
| `IorD` | Control FSM |
| `address` | IorD MUX |
| `write_data` | Register B |

---

# 12. Design Decisions

## Why Unified Memory?

A Multi-Cycle processor never fetches an instruction and accesses data simultaneously.

Therefore, a single memory can safely perform both operations, reducing hardware complexity.

---

## Why Byte Addressable?

RV32I uses byte-addressable memory.

Although instructions are 32 bits wide, memory addresses always refer to byte locations.

---

## Why Use `address[31:2]`?

The processor generates byte addresses, but the memory is organized as 32-bit words.

Using

```text
address[31:2]
```

converts the byte address into the correct word index by dividing the address by four.

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
- Byte (`lb`), Halfword (`lh`), and Word (`lw`) loads
- Byte (`sb`), Halfword (`sh`), and Word (`sw`) stores
- Memory initialization using `$readmemh`
- FPGA Block RAM implementation
- External SRAM or DRAM interface

---

# 15. Verification Checklist

The testbench shall verify:

- Memory reset operation.
- Instruction fetch using the Program Counter.
- Correct loading of the Instruction Register when `IRWrite = 1`.
- Instruction Register retains its value when `IRWrite = 0`.
- Load (`lw`) operation.
- Store (`sw`) operation.
- Correct byte-address to word-index conversion (`address[31:2]`).
- Simultaneous assertion of `mem_read` and `mem_write` is not allowed.
- Boundary address accesses.
- Consecutive read and write operations.

---

# 16. Hardware Resources

| Resource | Quantity |
|----------|---------:|
| Memory Array | 64 × 32 bits |
| Total Storage | 256 Bytes |
| Read Port | 1 |
| Write Port | 1 |

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `unified_memory.v` |
| Category | Datapath |
| Memory Type | Unified (Instruction + Data) |
| Data Width | 32 bits |
| Address Width | 32 bits |
| Memory Depth | 64 × 32 bits |
| Total Storage | 256 Bytes |
| Read | Combinational |
| Write | Positive-edge clock |
| Addressing | Byte Addressable (`address[31:2]`) |
| Inputs | `clk`, `reset`, `mem_read`, `mem_write`, `address`, `write_data` |
| Output | `read_data` |
