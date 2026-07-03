# Module 12 Specification

## ALU Control

**RTL File:** `alu_control.v`

**Category:** (B) Control Path Block

---

# 1. Purpose

The **ALU Control** module generates the specific operation to be performed by the **Arithmetic Logic Unit (ALU)**.

The Main Control FSM generates the high-level control signal `ALUOp`, which specifies the general class of ALU operation required (for example, address calculation, branch comparison, or instruction decoding).

The ALU Control module combines `ALUOp` with the instruction fields (`funct3` and `funct7`) to generate the final control code that selects the required ALU operation.

This two-level decoding simplifies the design of the Main Control FSM and makes the processor easier to extend.

---

# 2. Function

The ALU Control performs the following functions:

- Receives the high-level ALU operation (`ALUOp`) from the Main Control FSM.
- Decodes the instruction function fields (`funct3` and `funct7`).
- Determines the exact ALU operation required.
- Generates the ALU control signal.
- Supports all ALU operations required by the RV32I Base Integer ISA, including:
  - Arithmetic operations
  - Logical operations
  - Shift operations
  - Comparison operations
  - Address calculation operations

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `ALUOp` | 2 | Input | High-level ALU operation from the Main Control FSM |
| `funct3` | 3 | Input | Function field from the Instruction Register |
| `funct7` | 7 | Input | Function field from the Instruction Register |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `alu_control` | 4 | Output | Operation select code for the ALU |

---

# 4. ALU Operation Groups

The Main Control FSM provides one of the following ALU operation groups.

| ALUOp | Meaning | Used By |
|-------:|---------|---------|
| 00 | Address Calculation (ADD) | `lw`, `sw`, `jal`, `jalr`, `auipc`, `PC + 4` |
| 01 | Branch Comparison (SUB) | `beq`, `bne` |
| 10 | Decode using `funct3` and `funct7` | R-Type and I-Type Arithmetic/Logical Instructions |
| 11 | Reserved for Future Extensions | RV64I / ISA Extensions |
---

# 5. ALU Control Encoding

The ALU Control generates the following output codes.

| `alu_control` | Operation |
|--------------:|-----------|
| 0000 | ADD |
| 0001 | SUB |
| 0010 | AND |
| 0011 | OR |
| 0100 | XOR |
| 0101 | SLT |
| 0110 | SLTU |
| 0111 | SLL |
| 1000 | SRL |
| 1001 | SRA |

> **Note:** These encodings match the ALU specification defined in **Module 9 (`alu.v`)**.

---

# 6. Functional Specification

## Case 1 — Address Calculation

When

```text
ALUOp = 00
```

The ALU always performs

```text
ADD
```

Used for:

- Instruction Fetch (`PC + 4`)
- Load (`lw`)
- Store (`sw`)
- Jump (`jal`)
- Jump Register (`jalr`)
- `auipc`
- Memory address calculation
- Branch target address calculation

Output

```text
alu_control = ADD
```

---

## Case 2 — Branch Comparison

When

```text
ALUOp = 01
```

The ALU always performs

```text
SUB
```

The subtraction result is used to generate the Zero flag for branch decisions.

Used by:

- `beq`
- `bne`

The ALU performs subtraction.

The generated **Zero** flag is used by the Branch Logic or Main Control FSM to determine whether the branch should be taken.
Output

```text
alu_control = SUB
```

---

## Case 3 — R-Type / I-Type Decode

When

```text
ALUOp = 10
```

The ALU Control decodes `funct3` and `funct7`.

Examples

| Instruction | `funct7` | `funct3` | ALU Operation |
|-------------|----------|----------|---------------|
| ADD | 0000000 | 000 | ADD |
| SUB | 0100000 | 000 | SUB |
| AND | 0000000 | 111 | AND |
| OR | 0000000 | 110 | OR |
| XOR | 0000000 | 100 | XOR |
| SLT | 0000000 | 010 | SLT |
| SLTU | 0000000 | 011 | SLTU |
| SLL | 0000000 | 001 | SLL |
| SRL | 0000000 | 101 | SRL |
| SRA | 0100000 | 101 | SRA |

The same decoding is used for the corresponding I-Type instructions (`ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `SLTIU`, `SLLI`, `SRLI`, `SRAI`).

The ALU Control also supports:

| Instruction | ALU Operation |
|-------------|---------------|
| ADDI | ADD |
| ANDI | AND |
| ORI | OR |
| XORI | XOR |
| SLTI | SLT |
| SLTIU | SLTU |
| SLLI | SLL |
| SRLI | SRL |
| SRAI | SRA |

---

# 7. Decoding Flow

```text
             Main Control FSM
                    │
                 ALUOp
                    │
                    ▼
           +-----------------+
           |   ALU Control   |
           +-----------------+
             ▲           ▲
             │           │
          funct3      funct7
                    │
                    ▼
             alu_control
                    │
                    ▼
                  ALU
```

---

# 8. Timing Specification

| Item | Specification |
|------|---------------|
| Type | Combinational |
| Clock | Not Required |
| Reset | Not Required |

---

# 9. Interface Connections

<img width="1015" height="819" alt="image" src="https://github.com/user-attachments/assets/55a73d70-f8b9-41a1-bd90-dd07ad5314e0" />


```text
                 Instruction Register
                   │             │
                funct3       funct7
                   │             │
                   ▼             ▼
               +----------------------+
               |     ALU Control      |
               +----------------------+
                        ▲
                        │
                    ALUOp
                        │
                Main Control FSM
                        │
                        ▼
                 alu_control
                        │
                        ▼
                       ALU
```

---

# 10. Control Signals Used

| Signal | Source |
|--------|--------|
| `ALUOp` | Main Control FSM |
| `funct3` | Instruction Register |
| `funct7` | Instruction Register |

---

# 11. Design Decisions

## Why Separate the ALU Control from the Main Control FSM?

The Main Control FSM only determines the class of operation required.

The ALU Control determines the exact ALU operation.

This reduces the complexity of the Main Control FSM and allows the ALU operation decoding to be centralized in a dedicated module.

---

## Why Use `ALUOp`?

Many RV32I instructions require the same ALU operation.

For example,

- `lw`
- `sw`
- `jal`
- `jalr`
- `auipc`
- `PC + 4`

all require an ADD operation.

Instead of decoding every instruction individually, the Main Control FSM simply generates

```text
ALUOp = 00
```

The ALU Control then generates the corresponding ADD control signal.

This significantly simplifies the Main Control FSM.

For example,

```text
lw
sw
PC + 4
AUIPC
```

all require only an addition.

Instead of decoding every instruction individually, the Main Control FSM simply sets

```text
ALUOp = 00
```

and the ALU Control generates the ADD operation.

This simplifies the overall control logic.

---


# 12. Design Assumptions

- RV32I Base Integer ISA
- 32-bit datapath
- 4-bit ALU control output
- Supports all RV32I arithmetic, logical, comparison, and shift operations
- Purely combinational logic
- Compatible with Module 9 (`alu.v`)

---

# 13. Future Scalability

This module can later support:

- RV64I
- RV128I
- Integer Multiplication (`M` Extension)
- Integer Division (`M` Extension)
- Bit Manipulation (`B` Extension)
- Floating-Point Extensions (`F` and `D`)
- Custom ALU operations

---

# 14. Verification Checklist

The testbench shall verify:

- `ALUOp = 00` always generates ADD.
- `ALUOp = 01` always generates SUB.
- Correct decoding of all R-Type instructions.
- Correct decoding of all I-Type arithmetic instructions.
- Correct decoding of shift instructions.
- Correct differentiation between SRL and SRA.
- Illegal or unsupported function code handling.
- Output stability for all valid inputs.

---

# 15. Hardware Resources

| Resource | Quantity |
|----------|---------:|
| Combinational Decoder | 1 |
| Registers | 0 |
| Clock | Not Required |

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `alu_control.v` |
| Category | Control Path |
| Inputs | `ALUOp`, `funct3`, `funct7` |
| Output | `alu_control` |
| Output Width | 4 bits |
| Type | Combinational |
| Clock | Not Required |
| Reset | Not Required |
Supported Operations | ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA (All RV32I ALU Operations)
