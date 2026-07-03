# Module 3 Specification

## Instruction Register (IR)

**RTL File:** `instruction_register.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Instruction Register (IR)** is a **32-bit register** that stores the instruction fetched from the Unified Memory during the **Instruction Fetch (IF)** stage.

The IR holds the instruction constant throughout the Decode, Execute, Memory, and Write-Back stages, ensuring that the processor continues to execute the same instruction even though the Unified Memory may later be used for data accesses.

---

# 2. Function

The Instruction Register performs the following functions:

- Receives the instruction from the Unified Memory.
- Stores one 32-bit instruction.
- Loads a new instruction only when `IRWrite = 1`.
- Holds the current instruction until the instruction execution is completed.
- Supplies the instruction to the Immediate Generator, Register File, Main Control FSM, and ALU Control Unit.

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `IRWrite` | 1 | Input | Enables loading of a new instruction |
| `instruction_in` | 32 | Input | Instruction fetched from Unified Memory |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `instruction_out` | 32 | Output | Current instruction stored in the IR |

---

# 4. Register Specification

| Register | Width | Description |
|----------|------:|-------------|
| Instruction Register | 32 bits | Stores one RV32I instruction |

Only one internal register is required.

---

# 5. Data Width

| Item | Value |
|------|-------|
| Register Width | 32 bits |
| Instruction Width | 32 bits |

---

# 6. Functional Specification

## Reset

When

```text
reset = 0
```

the Instruction Register is cleared.

```text
IR ← 0x00000000
```

---

## Instruction Load

During the Instruction Fetch stage,

```text
IRWrite = 1
```

The IR loads the instruction from Unified Memory.

```text
IR ← instruction_in
```

---

## Hold Operation

During the Decode, Execute, Memory, and Write-Back stages,

```text
IRWrite = 0
```

The IR retains the previously fetched instruction.

```text
IR ← IR
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

the Instruction Register is cleared.

```text
instruction_out = 32'h00000000
```

---

# 9. Interface Connections


<img width="277" height="366" alt="image" src="https://github.com/user-attachments/assets/a39a6b97-c95e-4c75-9fd7-32c6391424f1" />


---

# 10. Control Signals Used

| Signal | Source |
|--------|--------|
| `IRWrite` | Control FSM |
| `clk` | System Clock |
| `reset` | System Reset |

---

# 11. Design Decisions

## Why is the Instruction Register Required?

The Unified Memory is shared between instructions and data.

After the Instruction Fetch stage, the Unified Memory may be used for:

- Load (`lw`)
- Store (`sw`)

Without the Instruction Register, the fetched instruction would be lost when the memory output changes.

Therefore, the IR stores the instruction until execution is complete.

---

## Why Use `IRWrite`?

The IR should load a new instruction only during the Instruction Fetch stage.

```text
IRWrite = 1  → Load new instruction
IRWrite = 0  → Hold current instruction
```

This prevents accidental overwriting of the current instruction during later execution stages.

---

# 12. Design Assumptions

- RV32I Base ISA
- Instruction width is 32 bits
- One instruction is executed at a time
- Positive-edge-triggered register
- Active-low asynchronous reset

---

# 13. Future Scalability

This module can later support:

- RV64I processors
- Compressed instruction support (RVC)
- Pipeline registers in pipelined processors
- Instruction buffering

---

# 14. Verification Checklist

The testbench shall verify:

- Reset clears the IR.
- IR loads a new instruction when `IRWrite = 1`.
- IR retains the current instruction when `IRWrite = 0`.
- Consecutive instruction fetches.
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
| Module | `instruction_register.v` |
| Category | Datapath |
| Register Width | 32 bits |
| Trigger | Positive-edge clock |
| Reset | Active-low asynchronous |
| Enable | `IRWrite` |
| Input | `instruction_in` |
| Output | `instruction_out` |
