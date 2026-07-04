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

Operations

```text
Memory Address = PC

Instruction ← Memory[PC]

IR ← Instruction

PC ← PC + 4
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 1 |
| PCWriteCond | 0 |
| MemRead | 1 |
| MemWrite | 0 |
| IRWrite | 1 |
| RegWrite | 0 |
| IorD | 0 |
| MemtoReg | X |
| ALUSrcA | 0 |
| ALUSrcB | 01 |
| ALUOp | 00 |
| PCSource | 00 |

---

## S1 — Instruction Decode / Register Fetch

Operations

```text
Read Register File

A ← Register[rs1]

B ← Register[rs2]

Generate Immediate

ALUOut ← PC + Immediate
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 0 |
| MemRead | 0 |
| MemWrite | 0 |
| IRWrite | 0 |
| RegWrite | 0 |
| IorD | X |
| MemtoReg | X |
| ALUSrcA | 0 |
| ALUSrcB | 10 |
| ALUOp | 00 |
| PCSource | XX |

---

## S2 — Execute (R-Type)

Operations

```text
ALUOut ← A op B
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 0 |
| MemRead | 0 |
| MemWrite | 0 |
| IRWrite | 0 |
| RegWrite | 0 |
| IorD | X |
| MemtoReg | X |
| ALUSrcA | 1 |
| ALUSrcB | 00 |
| ALUOp | 10 |
| PCSource | XX |

---

## S3 — Execute (I-Type)

Operations

```text
ALUOut ← A op Immediate
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 0 |
| MemRead | 0 |
| MemWrite | 0 |
| IRWrite | 0 |
| RegWrite | 0 |
| IorD | X |
| MemtoReg | X |
| ALUSrcA | 1 |
| ALUSrcB | 10 |
| ALUOp | 10 |
| PCSource | XX |

---

## S4 — Address Calculation

Operations

```text
ALUOut ← A + Immediate
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 0 |
| MemRead | 0 |
| MemWrite | 0 |
| IRWrite | 0 |
| RegWrite | 0 |
| IorD | X |
| MemtoReg | X |
| ALUSrcA | 1 |
| ALUSrcB | 10 |
| ALUOp | 00 |
| PCSource | XX |

---

## S5 — Memory Read

Operations

```text
MDR ← Memory[ALUOut]
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 0 |
| MemRead | 1 |
| MemWrite | 0 |
| IRWrite | 0 |
| RegWrite | 0 |
| IorD | 1 |
| MemtoReg | X |
| ALUSrcA | X |
| ALUSrcB | XX |
| ALUOp | XX |
| PCSource | XX |

---

## S6 — Memory Write

Operations

```text
Memory[ALUOut] ← B
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 0 |
| MemRead | 0 |
| MemWrite | 1 |
| IRWrite | 0 |
| RegWrite | 0 |
| IorD | 1 |
| MemtoReg | X |
| ALUSrcA | X |
| ALUSrcB | XX |
| ALUOp | XX |
| PCSource | XX |

---

## S7 — Register Write Back

Operations

```text
Register[rd] ← ALUOut
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 0 |
| MemRead | 0 |
| MemWrite | 0 |
| IRWrite | 0 |
| RegWrite | 1 |
| IorD | X |
| MemtoReg | 0 |
| ALUSrcA | X |
| ALUSrcB | XX |
| ALUOp | XX |
| PCSource | XX |

---

## S8 — Load Write Back

Operations

```text
Register[rd] ← MDR
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 0 |
| MemRead | 0 |
| MemWrite | 0 |
| IRWrite | 0 |
| RegWrite | 1 |
| IorD | X |
| MemtoReg | 1 |
| ALUSrcA | X |
| ALUSrcB | XX |
| ALUOp | XX |
| PCSource | XX |

---

## S9 — Branch

Operations

```text
Compare A and B

If branch condition is TRUE

PC ← ALUOut
```

Control Signals

| Signal | Value |
|---------|:-----:|
| PCWrite | 0 |
| PCWriteCond | 1 |
| MemRead | 0 |
| MemWrite | 0 |
| IRWrite | 0 |
| RegWrite | 0 |
| IorD | X |
| MemtoReg | X |
| ALUSrcA | 1 |
| ALUSrcB | 00 |
| ALUOp | 01 |
| PCSource | 01 |

---

## S10 — Jump

Operations

```text
PC ← Jump Target

Register[rd] ← PC + 4
```

Control Signals

Depends on the final implementation of the jump datapath.

---

## S11 — U-Type

Operations

```text
LUI:
Register[rd] ← Immediate

AUIPC:
Register[rd] ← PC + Immediate
```

Control Signals

Depends on the final implementation of the U-Type datapath.

---

# 7. State Transition Diagram

<img width="784" height="881" alt="image" src="https://github.com/user-attachments/assets/ffcb6b0f-333c-4531-bf3e-66731766a65a" />

---

>

## ALUControl Encoding 

| ALUControl | Operation    |
| ---------- | ------------ |
| 0000       | ADD          |
| 0001       | SUB          |
| 0010       | AND          |
| 0011       | OR           |
| 0100       | XOR          |
| 0101       | SLL          |
| 0110       | SRL          |
| 0111       | SRA          |
| 1000       | SLT          |
| 1001       | SLTU         |
| 1010       | PASS B (LUI) |
| 1111       | INVALID      |

ALU ctrl table:

| ALUOp | Opcode  | funct3 | funct7  | ALUControl | Instruction |
| ----- | ------- | ------ | ------- | ---------- | ----------- |
| 00    | 0000011 | XXX    | XXXXXXX | ADD        | LB/LH/LW    |
| 00    | 0100011 | XXX    | XXXXXXX | ADD        | SB/SH/SW    |
| 00    | 0010111 | XXX    | XXXXXXX | ADD        | AUIPC       |
| 00    | 1101111 | XXX    | XXXXXXX | ADD        | JAL         |
| 00    | 1100111 | 000    | XXXXXXX | ADD        | JALR        |
| 01    | 1100011 | 000    | XXXXXXX | SUB        | BEQ         |
| 01    | 1100011 | 001    | XXXXXXX | SUB        | BNE         |
| 01    | 1100011 | 100    | XXXXXXX | SLT        | BLT         |
| 01    | 1100011 | 101    | XXXXXXX | SLT        | BGE         |
| 01    | 1100011 | 110    | XXXXXXX | SLTU       | BLTU        |
| 01    | 1100011 | 111    | XXXXXXX | SLTU       | BGEU        |
| 10    | 0110011 | 000    | 0000000 | ADD        | ADD         |
| 10    | 0110011 | 000    | 0100000 | SUB        | SUB         |
| 10    | 0110011 | 111    | XXXXXXX | AND        | AND         |
| 10    | 0110011 | 110    | XXXXXXX | OR         | OR          |
| 10    | 0110011 | 100    | XXXXXXX | XOR        | XOR         |
| 10    | 0110011 | 001    | XXXXXXX | SLL        | SLL         |
| 10    | 0110011 | 101    | 0000000 | SRL        | SRL         |
| 10    | 0110011 | 101    | 0100000 | SRA        | SRA         |
| 10    | 0110011 | 010    | XXXXXXX | SLT        | SLT         |
| 10    | 0110011 | 011    | XXXXXXX | SLTU       | SLTU        |
| 10    | 0010011 | 000    | XXXXXXX | ADD        | ADDI        |
| 10    | 0010011 | 111    | XXXXXXX | AND        | ANDI        |
| 10    | 0010011 | 110    | XXXXXXX | OR         | ORI         |
| 10    | 0010011 | 100    | XXXXXXX | XOR        | XORI        |
| 10    | 0010011 | 001    | 0000000 | SLL        | SLLI        |
| 10    | 0010011 | 101    | 0000000 | SRL        | SRLI        |
| 10    | 0010011 | 101    | 0100000 | SRA        | SRAI        |
| 10    | 0010011 | 010    | XXXXXXX | SLT        | SLTI        |
| 10    | 0010011 | 011    | XXXXXXX | SLTU       | SLTIU       |
| 11    | 0110111 | XXX    | XXXXXXX | PASS B     | LUI         |

>
<img width="711" height="776" alt="image" src="https://github.com/user-attachments/assets/57cbd152-b279-48a4-868f-c9b763dd78a4" />


>

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
