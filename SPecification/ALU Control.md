# Module 12 Specification

## ALU Control

**RTL File:** `alu_control.v`

**Category:** (B) Control Path Block

---

# 1. Purpose

The **ALU Control** module generates the specific operation to be performed by the **Arithmetic Logic Unit (ALU)**.

The Main Control FSM determines only the **type of ALU operation** required (for example, Arithmetic, Branch Comparison, Address Calculation, or Logical Operation) by generating the `ALUOp` control signal.

The ALU Control further decodes the instruction fields (`funct3` and `funct7`) together with `ALUOp` to generate the final control code that selects the required ALU operation.

This two-level decoding simplifies the design of the Main Control FSM and makes the processor easier to extend.

---

# 2. Function

The ALU Control performs the following functions:

- Receives the high-level ALU operation (`ALUOp`) from the Main Control FSM.
- Decodes the instruction function fields (`funct3` and `funct7`).
- Determines the exact ALU operation required.
- Generates the ALU control signal.
- Supports all arithmetic, logical, comparison, and shift operations defined by the RV32I Base Integer ISA.

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

| ALUOp | Meaning |
|-------:|---------|
| 00 | Address calculation (ADD) |
| 01 | Branch comparison (SUB) |
| 10 | Decode instruction using `funct3` and `funct7` |
| 11 | Reserved for future extensions |

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

This is used by

- Instruction Fetch (PC + 4)
- Load (`lw`)
- Store (`sw`)
- AUIPC

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

Used by

- BEQ
- BNE

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

Many instructions require identical ALU operations.

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
- Combinational logic
- Compatible with Module 9 (`alu.v`)

---

# 13. Future Scalability

This module can later support:

- RV64I
- M Extension (Multiply/Divide)
- Bit Manipulation Extension
- Custom ALU operations
- Floating-point ALU control

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
| Supported Operations | ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA |
