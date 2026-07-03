# Module 6 Specification

## Register A

**RTL File:** `register_a.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Register A** is a **32-bit temporary register** that stores the value read from the **first read port (`read_data1`)** of the Register File during the **Instruction Decode (ID)** stage.

It holds this operand constant throughout the Execute, Memory, and Write-Back stages of the current instruction.

---

# 2. Function

The Register A performs the following functions:

- Receives data from the Register File (`read_data1`).
- Stores one 32-bit operand.
- Holds the operand until the instruction execution is completed.
- Supplies Operand A to the ALU through the **ALUSrcA MUX**.

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `AWrite` | 1 | Input | Enables loading of Register A |
| `read_data1` | 32 | Input | Operand read from Register File (`rs1`) |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `A_out` | 32 | Output | Stored operand supplied to the ALU |

---

# 4. Register Specification

| Register | Width | Description |
|----------|------:|-------------|
| Register A | 32 bits | Stores the first source operand |

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
A ← 0x00000000
```

---

## Operand Load

During the Instruction Decode stage,

```text
AWrite = 1
```

The register loads the value read from the Register File.

```text
A ← read_data1
```

---

## Hold Operation

During the Execute, Memory, and Write-Back stages,

```text
AWrite = 0
```

The register retains its previous value.

```text
A ← A
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
A_out = 32'h00000000
```

---

# 9. Interface Connections

<img width="450" height="584" alt="image" src="https://github.com/user-attachments/assets/04db737c-7208-450e-a3b2-a676abfa249e" />


---

# 10. Control Signals Used

| Signal | Source |
|--------|--------|
| `AWrite` | Control FSM |
| `clk` | System Clock |
| `reset` | System Reset |

---

# 11. Design Decisions

## Why is Register A Required?

In a Multi-Cycle processor, the Register File is used only during the Decode stage.

The source operand must be preserved for subsequent stages while the Register File becomes available for future instructions.

Register A stores the first source operand until it is required by the ALU.

---

## Why Use `AWrite`?

The operand should only be captured during the Decode stage.

```text
AWrite = 1  → Load operand

AWrite = 0  → Hold operand
```

This prevents the register from unintentionally capturing new data during later execution stages.

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

- Reset clears Register A.
- Register A loads `read_data1` when `AWrite = 1`.
- Register A holds its value when `AWrite = 0`.
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
| Module | `register_a.v` |
| Category | Datapath |
| Register Width | 32 bits |
| Trigger | Positive-edge clock |
| Reset | Active-low asynchronous |
| Enable | `AWrite` |
| Input | `read_data1` |
| Output | `A_out` |
