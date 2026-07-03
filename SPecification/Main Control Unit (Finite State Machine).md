# Module 11 Specification

## Main Control Unit (Finite State Machine)

**RTL File:** `control_fsm.v`

**Category:** (B) Control Path Block

---

# 1. Purpose

The **Main Control Unit** is implemented as a **Finite State Machine (FSM)**.

Its primary responsibility is to control the execution of every RV32I instruction by generating the appropriate control signals for each stage of execution.

Unlike a Single-Cycle processor where all control signals are generated simultaneously, the Multi-Cycle processor generates different control signals during different clock cycles.

---

The Main Control FSM performs the following functions:

- Controls instruction fetch.
- Controls instruction decode.
- Controls register operand loading.
- Controls ALU operations.
- Controls memory address calculation.
- Controls memory read and write operations.
- Controls register write-back.
- Controls Program Counter updates.
- Generates all datapath control signals.
- Determines the next execution state based on the current state and instruction opcode.
- Supports execution of all instructions implemented in the RV32I Version-1 processor.

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `opcode` | 7 | Input | Instruction opcode from the Instruction Register |
| `funct3` | 3 | Input | Function field used for branch instruction decoding |
| `zero` | 1 | Input | Zero flag from the ALU (used by `beq` and `bne`) |

``` This reflects how the current Version-1 processor uses funct3.```

---

## Outputs

<img width="1073" height="426" alt="image" src="https://github.com/user-attachments/assets/07e3646f-25a7-47e3-aa15-f0d59dd45550" />

<0>

| Signal | Width | Description |
|--------|------:|-------------|
| `PCWrite` | 1 | Enables Program Counter update |
| `IRWrite` | 1 | Enables Instruction Register |
| `MemRead` | 1 | Enables memory read |
| `MemWrite` | 1 | Enables memory write |
| `RegWrite` | 1 | Enables Register File write |
| `AWrite` | 1 | Enables Register A |
| `BWrite` | 1 | Enables Register B |
| `MDRWrite` | 1 | Enables Memory Data Register |
| `ALUOutWrite` | 1 | Enables ALUOut Register |
| `IorD` | 1 | Selects memory address source |
| `MemtoReg` | 1 | Selects Register File write-back source |
| `ALUSrcA` | 1 | Selects ALU Operand A |
| `ALUSrcB` | 2 | Selects ALU Operand B |
| `PCSource` | 2 | Selects next PC source |
| `ALUOp` | 2 | High-level ALU operation control |

---

# 4. FSM Specification

The processor executes every instruction by moving through a sequence of states.

```text
Instruction Fetch
        │
        ▼
Instruction Decode
        │
        ▼
Execute
        │
        ▼
Memory Access
        │
        ▼
Write Back
```

Different instruction types visit different states.

---


# 5. FSM States

| State | Name | Purpose |
|------:|------|---------|
| S0 | Instruction Fetch | Fetch instruction and increment Program Counter |
| S1 | Instruction Decode | Decode instruction, read Register File and generate immediate |
| S2 | Execute (R-Type) | Execute R-Type ALU instruction |
| S3 | Execute (I-Type ALU) | Execute I-Type arithmetic/logical instruction |
| S4 | Address Calculation | Calculate effective memory address for `lw` and `sw` |
| S5 | Memory Read | Read data memory (`lw`) |
| S6 | Memory Write | Write data memory (`sw`) |
| S7 | Register Write-Back | Write ALU result to Register File |
| S8 | Load Write-Back | Write loaded data (MDR) to Register File |
| S9 | Branch | Evaluate branch condition and update Program Counter if taken |
| S10 | Jump | Execute `jal` and `jalr` instructions |
| S11 | U-Type Execute | Execute `lui` and `auipc` instructions |

These state numbers are recommendations and may be modified during implementation.

---

# 6. State Operations

## S0 — Instruction Fetch

Operations performed

```text
Memory Address = PC

Read Instruction

IR ← Memory

PC ← PC + 4
```

Control Signals


```text
PCWrite      = 1
IRWrite      = 1
MemRead      = 1
IorD         = 0
ALUSrcA      = 0
ALUSrcB      = 01
PCSource     = 00
ALUOp        = ADD
ALUOutWrite  = 0
```

---

## S1 — Instruction Decode

Operations

```text
Read Register File

A ← rs1

B ← rs2

Generate Immediate
```

Control Signals

```text
AWrite = 1

BWrite = 1
```

---

## S2 — Execute (R-Type)

Operations

```text
ALU(A,B)

ALUOut ← Result
```

---

## S3 — Execute (I-Type)

Operations

```text
ALU(A, Immediate)

ALUOut ← Result
```

---

## S4 — Address Calculation

Operations

```text
Effective Address

=

Base Register

+

Immediate
```

Result

```text
ALUOut ← Address
```

---

## S5 — Memory Read

Operations

```text
Memory

↓

MDR
```

---

## S6 — Memory Write

Operations

```text
Memory[ALUOut]

←

Register B
```

---

## S7 — Write Back (ALU)

Operations

```text
Register File

←

ALUOut
```

---

## S8 — Write Back (Load)

Operations

```text
Register File

←

MDR
```

---

## S9 — Branch

Operations

```text
Compare

A

and

B

If branch true

PC ← Branch Target
```

---

## S10 — Jump

Operations

```

PC ← Jump Target

rd ← PC + 4

```

For:
```
- `jal`
- `jalr`
```

---

## S11 — U-Type

Operations

```text
LUI

↓

Write Immediate to Register

AUIPC

↓

ALU computes PC + Immediate

↓

Write Result to Register
```

---

# 7. State Transition Diagram

```text
                    +------+
                    | S0   |
                    |Fetch |
                    +------+
                        │
                        ▼
                    +------+
                    | S1   |
                    |Decode|
                    +------+
       ┌─────────────┼──────────────┬─────────────┬─────────────┬─────────────┐
       ▼             ▼              ▼             ▼             ▼             ▼
   +------+      +------+       +------+      +------+      +------+      +------+
   | S2   |      | S3   |       | S4   |      | S9   |      | S10  |      | S11  |
   |R-Type|      |I-Type|       |Addr  |      |Branch|      | Jump |      |U-Type|
   +------+      +------+       +------+      +------+      +------+      +------+
       │             │           ┌──┴──┐           │             │             │
       ▼             ▼           ▼     ▼           ▼             ▼             ▼
   +------+      +------+    +------+ +------+  +------+     +------+     +------+
   | S7   |      | S7   |    | S5   | | S6   |  | S0   |     | S7   |     | S7   |
   |WB ALU|      |WB ALU|    |Mem Rd| |Mem Wr|  |Fetch |     |WB Jmp|     |WB U  |
   +------+      +------+    +------+ +------+  +------+     +------+     +------+
                                  │                                   │
                                  ▼                                   ▼
                              +------+
                              | S8   |
                              |WB LW |
                              +------+
                                  │
                                  ▼
                              +------+
                              | S0   |
                              |Fetch |
                              +------+
```

| Instruction Type                                    | Path                        |
| --------------------------------------------------- | --------------------------- |
| R-Type                                              | S0 → S1 → S2 → S7 → S0      |
| I-Type (ALU Immediate)                              | S0 → S1 → S3 → S7 → S0      |
| Load (`lw`)                                         | S0 → S1 → S4 → S5 → S8 → S0 |
| Store (`sw`)                                        | S0 → S1 → S4 → S6 → S0      |
| Branch (`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`) | S0 → S1 → S9 → S0           |
| Jump (`jal`, `jalr`)                                | S0 → S1 → S10 → S7 → S0     |
| U-Type (`lui`, `auipc`)                             | S0 → S1 → S11 → S7 → S0     |


---

# 8. Timing Specification

| Item | Specification |
|------|---------------|
| Type | Sequential FSM |
| Trigger | Positive-edge clock |
| Reset | Active-low asynchronous |

---

# 9. Design Decisions

## Why Use an FSM?

Each RV32I instruction requires several sequential operations.

Instead of implementing dedicated hardware for every instruction stage, a single datapath is reused across multiple clock cycles.

The FSM orchestrates this reuse.

---

## Why Multiple States?

Different instruction classes require different numbers of clock cycles.

Example

```text
ADD

Fetch

↓

Decode

↓

Execute

↓

Write Back
```

whereas

```text
LW

Fetch

↓

Decode

↓

Address Calculation

↓

Memory Read

↓

Write Back
```

---

# 10. Design Assumptions

# 10. Design Assumptions

- RV32I Base Integer ISA
- 32-bit datapath
- Multi-Cycle architecture
- Von Neumann Architecture
- One instruction is executed at a time
- Positive-edge-triggered Moore FSM
- Supports the following instruction groups:
  - R-Type
  - I-Type Arithmetic
  - `lw`
  - `sw`
  - Branch (`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`)
  - `jal`
  - `jalr`
  - `lui`
  - `auipc`

---


# 11. Future Scalability

This module can later support:

- RV64I
- RV128I
- Integer Multiplication and Division (`M` Extension)
- CSR Instructions (`Zicsr`)
- Interrupt Handling
- Exception Handling
- Pipeline Control
- Branch Prediction
- Speculative Execution

---

# 12. Verification Checklist

The testbench shall verify:

- Reset enters the Instruction Fetch state.
- Correct state transitions.
- Correct control signal generation for each state.
- R-Type instruction execution.
- I-Type arithmetic instruction execution.
- `lw` execution.
- `sw` execution.
- Branch instruction execution (`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`).
- `jal` execution.
- `jalr` execution.
- `lui` execution.
- `auipc` execution.
- Illegal opcode handling.
- Consecutive instruction execution.

---

# 13. Hardware Resources

| Resource | Quantity |
|----------|---------:|
| FSM State Register | 1 |
| Next-State Logic | 1 |
| Output Decode Logic | 1 |

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `control_fsm.v` |
| Category | Control Path |
| Type | Moore FSM |
| Number of States | 12 |
| Clock | Positive-edge |
| Reset | Active-low asynchronous |
| Inputs | `clk`, `reset`, `opcode`, `funct3`, `zero` |
| Outputs | All processor control signals |
| Supported RV32I Instructions | R-Type, I-Type Arithmetic, `lw`, `sw`, `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`, `jal`, `jalr`, `lui`, `auipc` |
