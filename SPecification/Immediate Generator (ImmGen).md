# Module 8 Specification

## Immediate Generator (ImmGen)

**RTL File:** `imm_gen.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Immediate Generator (ImmGen)** extracts the immediate field from the current instruction stored in the **Instruction Register (IR)** and generates a **32-bit immediate value** according to the RV32I instruction format.

The generated immediate is supplied to the **ALUSrcB MUX**, where it is selected as one of the ALU operands during instruction execution.

---

# 2. Function

The Immediate Generator performs the following functions:

- Decodes the instruction opcode.
- Determines the instruction format.
- Extracts the immediate field.
- Performs sign-extension or upper-immediate formatting.
- Generates a 32-bit immediate value.
- Supports all RV32I immediate formats:
  - I-Type
  - S-Type
  - B-Type
  - U-Type
  - J-Type

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `instruction` | 32 | Input | 32-bit instruction from the Instruction Register |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `imm_out` | 32 | Output | Generated 32-bit immediate value |

---

# 4. Supported Instruction Formats

| Format | Supported Instructions |
|---------|------------------------|
| I-Type | `addi`, `andi`, `ori`, `xori`, `slti`, `sltiu`, `slli`, `srli`, `srai`, `jalr`, `lw` |
| S-Type | `sw` |
| B-Type | `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu` |
| U-Type | `lui`, `auipc` |
| J-Type | `jal` |

> **Note**
>
> This Version-1 implementation supports only **32-bit word load (`lw`)** and **32-bit word store (`sw`)** instructions.
>
> Byte and halfword memory access instructions (`lb`, `lh`, `lbu`, `lhu`, `sb`, `sh`) will be supported in a future version by extending the Unified Memory module.

---

# 5. Immediate Formats

## I-Type Immediate

Instruction Format

```text
31                      20
+------------------------+
|      imm[11:0]         |
+------------------------+
```

Generated Immediate

```text
imm_out = SignExtend(instruction[31:20])
```

Width

```text
12 bits → 32 bits
```

---

## S-Type Immediate

Instruction Format

```text
31      25 24      20 19      15 14   12 11      7 6      0
+---------+----------+----------+-------+---------+--------+
| imm[11:5] |   rs2   |   rs1    | funct3| imm[4:0]| opcode |
+---------+----------+----------+-------+---------+--------+
```

Generated Immediate

```text
imm_out = SignExtend({instruction[31:25], instruction[11:7]})
```

Width

```text
12 bits → 32 bits
```

---

## B-Type Immediate

Instruction Format

```text
31   30:25   24:20   19:15 14:12 11:8 7    6:0
+--+--------+-------+------+-----+----+-------+
|12|10:5    | rs2   | rs1  |funct|4:1 |11|opcode|
+--+--------+-------+------+-----+----+-------+
```

Generated Immediate

```text
imm_out =
SignExtend(
{
instruction[31],
instruction[7],
instruction[30:25],
instruction[11:8],
1'b0
})
```

Notice

```text
Bit[0] is always zero
```

because branch targets are always aligned.

Width

```text
13 bits → 32 bits
```

---

## U-Type Immediate

Instruction Format

```text
31                     12
+-----------------------+
|      imm[31:12]       |
+-----------------------+
```

Generated Immediate

```text
imm_out =
{
instruction[31:12],
12'b000000000000
}
```

No sign extension is required.

The lower 12 bits are filled with zeros.

---

## J-Type Immediate

Instruction Format

```text
31 30:21 20 19:12
+--+------+--+--------+
|20|10:1  |11|19:12   |
+--+------+--+--------+
```

Generated Immediate

```text
imm_out =
SignExtend(
{
instruction[31],
instruction[19:12],
instruction[20],
instruction[30:21],
1'b0
})
```

Notice

```text
Bit[0] is always zero
```

Width

```text
21 bits → 32 bits
```

---

# 6. Functional Specification

The Immediate Generator continuously monitors the instruction.

According to the instruction opcode, it automatically generates the corresponding immediate.

```text
Instruction
      │
      ▼
Opcode Decoder
      │
      ▼
Immediate Extraction
      │
      ▼
Sign Extension
      │
      ▼
imm_out
```

No clock is required.

The Immediate Generator is a purely combinational module.

---

# 7. Timing Specification

| Item | Specification |
|------|---------------|
| Type | Combinational |
| Clock | Not Required |
| Reset | Not Required |

---

# 8. Interface Connections

<img width="748" height="389" alt="image" src="https://github.com/user-attachments/assets/509ab758-17af-4a90-ae79-09ff9ce01df3" />


---

# 9. Control Signals Used

None.

The Immediate Generator operates purely from the instruction bits.

---

# 10. Design Decisions

## Why is the Immediate Generator Required?

Many RV32I instructions contain immediate operands.

Examples

```assembly
addi x5, x6, 10

lw x8, 16(x2)

sw x9, 20(x3)

beq x1, x2, 24

jal x1, 40

lui x5, 0x12345
```

Each instruction stores its immediate field differently.

The Immediate Generator reconstructs the correct 32-bit immediate for the ALU.

---

## Why is Sign Extension Required?

Most RV32I immediates are signed values.

Example

```assembly
addi x5, x6, -4
```

Instruction stores

```text
111111111100
```

The Immediate Generator extends it to

```text
11111111111111111111111111111100
```

which represents **-4** in 32-bit two's complement.

---

## Why are B-Type and J-Type Immediate Bit[0] Always Zero?

Branch and jump targets are aligned.

Therefore,

```text
offset × 2
```

is implemented by appending

```text
1'b0
```

to the immediate.

---

# 11. Design Assumptions

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/fee30ecd-993c-470f-8860-26859dd1a4f4" />


---

- RV32I Base Integer ISA
- 32-bit instruction width
- 32-bit datapath
- Supports all RV32I immediate formats:
  - I-Type
  - S-Type
  - B-Type
  - U-Type
  - J-Type
- Version-1 processor supports:
  - R-Type instructions
  - I-Type arithmetic instructions
  - `lw`
  - `sw`
  - Branch instructions
  - `jal`
  - `jalr`
  - `lui`
  - `auipc`
- Byte and halfword memory access instructions (`lb`, `lh`, `lbu`, `lhu`, `sb`, `sh`) are reserved for future versions.
- Purely combinational logic

---

# 12. Future Scalability

This module can later support:

- RV64I
- Compressed Instructions (RVC)
- Custom ISA extensions
- Byte load instructions (`lb`, `lbu`)
- Halfword load instructions (`lh`, `lhu`)
- Byte store instruction (`sb`)
- Halfword store instruction (`sh`)
- Additional immediate generation for future ISA extensions

---

# 13. Verification Checklist

The testbench shall verify:

- Correct I-Type immediate generation.
- Correct S-Type immediate generation.
- Correct B-Type immediate generation.
- Correct U-Type immediate generation.
- Correct J-Type immediate generation.
- Positive immediate values.
- Negative immediate values.
- Sign extension correctness.
- Upper immediate generation.
- Invalid opcode handling.

---

# 14. Hardware Resources

| Resource | Quantity |
|----------|---------:|
| Combinational Logic | 1 |
| Registers | 0 |
| Clock | Not Required |

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `imm_gen.v` |
| Category | Datapath |
| Input Width | 32 bits |
| Output Width | 32 bits |
| Supported Formats | I, S, B, U, J |
| Type | Combinational |
| Clock | Not Required |
| Reset | Not Required |
| Output | `imm_out` |
