# Module 10 Specification

## ALUOut Register

**RTL File:** `alu_out.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **ALUOut Register** is a **32-bit temporary register** that stores the output produced by the ALU.

Since the ALU is reused during multiple stages of instruction execution, its result must be preserved after the Execute stage so that it can be used during later stages such as Memory Access and Write-Back.

The ALUOut Register provides this temporary storage.

---

# 2. Function

The ALUOut Register performs the following functions:

- Receives the ALU result.
- Stores one 32-bit value.
- Holds the value until it is no longer required.
- Supplies the stored value to:
  - Unified Memory (effective address)
  - MemtoReg MUX
  - PCSource MUX
  - Other datapath blocks as required

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `ALUOutWrite` | 1 | Input | Enables loading of the ALUOut Register |
| `alu_result` | 32 | Input | Output from the ALU |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `alu_out` | 32 | Output | Stored ALU result |

---

# 4. Register Specification

| Register | Width | Description |
|----------|------:|-------------|
| ALUOut Register | 32 bits | Stores ALU computation result |

Only one internal register is required.

---

# 5. Data Width

| Item | Value |
|------|-------|
| Register Width | 32 bits |
| Input Width | 32 bits |
| Output Width | 32 bits |

---

# 6. Functional Specification

## Reset

When

```text
reset = 0
```

the register is cleared.

```text
ALUOut ← 0x00000000
```

---

## Result Load

Whenever the Control FSM asserts

```text
ALUOutWrite = 1
```

the ALU result is stored.

```text
ALUOut ← alu_result
```

---

## Hold Operation

When

```text
ALUOutWrite = 0
```

the register retains its previous value.

```text
ALUOut ← ALUOut
```

---

# 7. Typical Uses

The ALUOut Register stores different values depending on the instruction being executed.

### Arithmetic Instructions

Example

```assembly
add x5, x2, x3
```

Execute Stage

```text
ALU Result = x2 + x3

↓

ALUOut ← x2 + x3
```

Write-Back Stage

```text
Register File[x5] ← ALUOut
```

---

### Load Instruction

Example

```assembly
lw x8, 12(x5)
```

Execute Stage

```text
ALU Result = x5 + 12
```

```text
ALUOut ← Effective Address
```

Memory Stage

```text
Memory Address = ALUOut
```

---

### Store Instruction

Example

```assembly
sw x10, 8(x6)
```

Execute Stage

```text
ALU Result = x6 + 8
```

```text
ALUOut ← Effective Address
```

Memory Stage

```text
Memory[ALUOut] ← Register B
```

---

### Branch Instruction

Example

```assembly
beq x1, x2, 16
```

Execute Stage

```text
ALU Result = PC + 16
```

```text
ALUOut ← Branch Target Address
```

If the branch condition is true,

```text
PC ← ALUOut
```

---

# 8. Timing Specification

| Item | Specification |
|------|---------------|
| Trigger | Positive-edge clock |
| Reset | Asynchronous Active-Low |
| Output Type | Registered |

---

# 9. Reset Behavior

When

```text
reset = 0
```

```text
alu_out = 32'h00000000
```

---

# 10. Interface Connections

<img width="388" height="454" alt="image" src="https://github.com/user-attachments/assets/faa610ca-d9ab-4311-bb5c-a041d69ef137" />



---

# 11. Control Signals Used

| Signal | Source |
|--------|--------|
| `ALUOutWrite` | Control FSM |
| `clk` | System Clock |
| `reset` | System Reset |

---

# 12. Design Decisions

## Why is the ALUOut Register Required?

The ALU is shared among all instruction types in a Multi-Cycle processor.

After producing a result, the ALU is immediately reused in the next clock cycle for another operation.

Without the ALUOut Register, the previous ALU result would be lost before it could be used.

Therefore, the ALUOut Register temporarily stores the ALU output until it is consumed by the next stage.

---

## Why Use `ALUOutWrite`?

The ALU produces outputs during several stages of execution.

Only the required results should be stored.

```text
ALUOutWrite = 1

↓

Load new ALU result
```

```text
ALUOutWrite = 0

↓

Hold previous value
```

This provides explicit control over when the ALU result is captured.

---

# 13. Design Assumptions

- RV32I Base ISA
- 32-bit datapath
- Positive-edge-triggered register
- Active-low asynchronous reset
- ALU result captured only when enabled

---

# 14. Future Scalability

This module can later support:

- RV64I (64-bit datapath)
- Pipelined processors
- Debug interfaces
- Performance monitoring

---

# 15. Verification Checklist

The testbench shall verify:

- Reset clears the ALUOut Register.
- ALU result is captured when `ALUOutWrite = 1`.
- Register holds its value when `ALUOutWrite = 0`.
- Arithmetic result storage.
- Effective address storage for `lw`.
- Effective address storage for `sw`.
- Branch target address storage.
- Consecutive ALU operations.
- Reset during processor execution.

---

# 16. Hardware Resources

| Resource | Quantity |
|----------|---------:|
| 32-bit Register | 1 |
| D Flip-Flops | 32 |

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `alu_out.v` |
| Category | Datapath |
| Register Width | 32 bits |
| Trigger | Positive-edge clock |
| Reset | Active-low asynchronous |
| Enable | `ALUOutWrite` |
| Input | `alu_result` |
| Output | `alu_out` |
