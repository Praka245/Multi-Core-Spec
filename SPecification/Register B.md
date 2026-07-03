# Module 7 Specification

## Register B

**RTL File:** `register_b.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Register B** is a **32-bit temporary register** that stores the value read from the **second read port (`read_data2`)** of the Register File during the **Instruction Decode (ID)** stage.

It holds this operand constant throughout the Execute, Memory, and Write-Back stages of the current instruction.

For **Store (`sw`)** instructions, Register B supplies the data that will be written into the Unified Memory.

---

# 2. Function

The Register B performs the following functions:

- Receives data from the Register File (`read_data2`).
- Stores one 32-bit operand.
- Holds the operand until the instruction execution is completed.
- Supplies Operand B to the ALU through the **ALUSrcB MUX**.
- Supplies write data to the Unified Memory during Store (`sw`) instructions.

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `BWrite` | 1 | Input | Enables loading of Register B |
| `read_data2` | 32 | Input | Operand read from Register File (`rs2`) |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `B_out` | 32 | Output | Stored operand supplied to the ALU and Unified Memory |

---

# 4. Register Specification

| Register | Width | Description |
|----------|------:|-------------|
| Register B | 32 bits | Stores the second source operand |

Only one internal register is required.

---

# 5. Data Width

| Item | Value |
|------|-------|
| Register Width | 32 bits |
| Operand Width | 32 bits |

---

# 6. Functional Specification

## Reset

When

```text
reset = 0
```

the register is cleared.

```text
B ← 0x00000000
```

---

## Operand Load

During the Instruction Decode stage,

```text
BWrite = 1
```

The register loads the value read from the Register File.

```text
B ← read_data2
```

---

## Hold Operation

During the Execute, Memory, and Write-Back stages,

```text
BWrite = 0
```

The register retains its previous value.

```text
B ← B
```

---

# 7. Timing Specification

| Item | Specification |
|------|---------------|
| Trigger | Positive-edge clock |
| Reset | Asynchronous Active-Low |
| Output Type | Registered |

---

# 8. Reset Behavior

When

```text
reset = 0
```

the register is cleared.

```text
B_out = 32'h00000000
```

---

# 9. Interface Connections

<img width="450" height="584" alt="image" src="https://github.com/user-attachments/assets/ca891bdd-386a-4b6e-aa68-d0357be49ad1" />

---

# 10. Control Signals Used

| Signal | Source |
|--------|--------|
| `BWrite` | Control FSM |
| `clk` | System Clock |
| `reset` | System Reset |

---

# 11. Design Decisions

## Why is Register B Required?

In a Multi-Cycle processor, the Register File is accessed only during the Decode stage.

The second source operand must be preserved for the remaining execution stages.

Register B stores this operand until it is required by either:

- The ALU (arithmetic, logical, branch, address calculation)
- The Unified Memory (Store instructions)

---

## Why Use `BWrite`?

The operand should only be captured during the Decode stage.

```text
BWrite = 1  → Load operand

BWrite = 0  → Hold operand
```

This prevents Register B from unintentionally capturing new values during later execution stages.

---

# 12. Design Assumptions

- RV32I Base ISA
- Operand width is 32 bits
- Positive-edge-triggered register
- Active-low asynchronous reset
- Operand loaded during the Decode stage

---

# 13. Future Scalability

This module can later support:

- RV64I (64-bit operands)
- Pipelined processors
- Superscalar processors
- Out-of-order execution

---

# 14. Verification Checklist

The testbench shall verify:

- Reset clears Register B.
- Register B loads `read_data2` when `BWrite = 1`.
- Register B holds its value when `BWrite = 0`.
- Register B correctly supplies Operand B to the ALU.
- Register B correctly supplies `write_data` to the Unified Memory during Store instructions.
- Consecutive operand loads.
- Reset during processor operation.

---

# 15. Hardware Resources

| Resource | Quantity |
|----------|---------:|
| 32-bit Register | 1 |
| D Flip-Flops | 32 |

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `register_b.v` |
| Category | Datapath |
| Register Width | 32 bits |
| Trigger | Positive-edge clock |
| Reset | Active-low asynchronous |
| Enable | `BWrite` |
| Input | `read_data2` |
| Output | `B_out` |
