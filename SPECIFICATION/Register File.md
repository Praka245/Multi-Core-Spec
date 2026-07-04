# Module 5 Specification

## Register File

**RTL File:** `register_file.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Register File** is a collection of **32 general-purpose registers**, each **32 bits wide**, used to store operands and computation results during program execution.

It provides two simultaneous read ports and one write port, enabling the processor to read two source operands and write one destination operand.

The Register File implements the RV32I register set (`x0`–`x31`).

---

# 2. Function

The Register File performs the following functions:

- Stores thirty-two 32-bit registers.
- Provides two independent read ports.
- Provides one write port.
- Supplies source operands (`rs1` and `rs2`) to the datapath.
- Writes computation or memory results into the destination register (`rd`).
- Keeps register `x0` permanently equal to zero.

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `RegWrite` | 1 | Input | Register write enable |
| `rs1` [19-15]| 5 | Input | Source Register 1 address |
| `rs2` [24-20]| 5 | Input | Source Register 2 address |
| `rd` [11-7]| 5 | Input | Destination Register address |
| `write_data` | 32 | Input | Data to be written into the destination register |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `read_data1` | 32 | Output | Data stored in register `rs1` |
| `read_data2` | 32 | Output | Data stored in register `rs2` |

---

# 4. Register Specification

| Item | Specification |
|------|---------------|
| Number of Registers | 32 |
| Register Width | 32 bits |
| Total Storage | 1024 bits |

Register Declaration

```verilog
reg [31:0] register_file [0:31];
```

---

# 5. Register Mapping

| Register Number | Register Name |
|----------------:|---------------|
| 0 | x0 |
| 1 | x1 |
| 2 | x2 |
| ... | ... |
| 31 | x31 |

---

# 6. Functional Specification

## Reset

When

```text
reset = 0
```

all registers are cleared.

```text
x0 = 0
x1 = 0
...
x31 = 0
```

---

## Read Operation

The Register File provides two simultaneous asynchronous read ports.

```text
read_data1 = register_file[rs1]

read_data2 = register_file[rs2]
```

These outputs are continuously available.

---

## Write Operation

On the positive edge of the clock,

If

```text
RegWrite = 1
```

and

```text
rd ≠ 0
```

then

```text
register_file[rd] ← write_data
```

---

## Register x0

Register `x0` is hardwired to zero.

Therefore,

```text
x0 = 32'h00000000
```

Writing to register `x0` has no effect.

---

# 7. Timing Specification

| Item | Specification |
|------|---------------|
| Read Operation | Combinational (Asynchronous) |
| Write Operation | Positive-edge triggered |
| Reset | Asynchronous Active-Low |

---

# 8. Reset Behavior

When

```text
reset = 0
```

all 32 registers are cleared.

```text
register_file[i] = 32'h00000000
```

for

```text
i = 0 to 31
```

---

# 9. Interface Connections

<img width="389" height="491" alt="image" src="https://github.com/user-attachments/assets/a8a6622d-c579-45f8-a77f-f96f0b086210" />

---

# 10. Control Signals Used

| Signal | Source |
|--------|--------|
| `RegWrite` | Control FSM |
| `clk` | System Clock |
| `reset` | System Reset |

---

# 11. Design Decisions

## Why Two Read Ports?

Most RV32I instructions require two source operands.

Example:

```assembly
add x5, x2, x3
```

The processor must simultaneously read:

- x2
- x3

Therefore, two independent read ports are required.

---

## Why One Write Port?

Each RV32I instruction writes to at most one destination register.

Example

```assembly
add x5, x2, x3
```

Only register `x5` is updated.

Hence, one write port is sufficient.

---

## Why is x0 Always Zero?

According to the RV32I ISA,

```text
x0 = 0
```

at all times.

Any attempt to write to `x0` is ignored.

---

# 12. Design Assumptions

- RV32I Base ISA
- 32 general-purpose registers
- Register width is 32 bits
- Two asynchronous read ports
- One synchronous write port
- Positive-edge-triggered write
- Active-low asynchronous reset

---

# 13. Future Scalability

This module can later support:

- RV64I (64-bit registers)
- Register banking
- Multi-port register files
- Pipelined processors
- Out-of-order processors

---

# 14. Verification Checklist

The testbench shall verify:

- Reset clears all registers.
- Two simultaneous read operations.
- Single write operation.
- Read-after-write behavior.
- Writes occur only when `RegWrite = 1`.
- Writes to `x0` are ignored.
- Boundary registers (`x0` and `x31`).
- Consecutive write operations.

---

# 15. Hardware Resources

| Resource | Quantity |
|----------|---------:|
| Registers | 32 |
| Width | 32 bits each |
| Read Ports | 2 |
| Write Ports | 1 |
| Total Storage | 1024 bits |

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `register_file.v` |
| Category | Datapath |
| Registers | 32 |
| Register Width | 32 bits |
| Read Ports | 2 |
| Write Ports | 1 |
| Read | Asynchronous |
| Write | Positive-edge clock |
| Reset | Active-low asynchronous |
| Write Enable | `RegWrite` |
| Outputs | `read_data1`, `read_data2` |
| Inputs | `clk`, `reset`, `RegWrite`, `rs1`, `rs2`, `rd`, `write_data` |
