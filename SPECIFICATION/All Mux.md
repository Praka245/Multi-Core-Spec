
# Module 13 Specification

## IorD Multiplexer

**RTL File:** `iord_mux.v`

**Category:** (C) Multiplexer

---

## Purpose

Selects the address supplied to the Unified Memory.

---

## Function

- During Instruction Fetch, selects the Program Counter (PC).
- During Load/Store instructions, selects the ALUOut register.

---

## Interface Specification

### Inputs

| Signal | Width | Description |
|--------|------:|-------------|
| `pc` | 32 | Program Counter |
| `alu_out` | 32 | Address computed by the ALU |
| `IorD` | 1 | Select signal from Control FSM |

### Output

| Signal | Width | Description |
|--------|------:|-------------|
| `address` | 32 | Address supplied to Unified Memory |

---

## Selection Table

| IorD | Output |
|------|--------|
| 0 | PC |
| 1 | ALUOut |

---

## Logic

```verilog
assign address = (IorD) ? alu_out : pc;
```

---

## Type

- 2-to-1 Multiplexer
- 32-bit Wide
- Combinational Logic

---

# Module 14 Specification

## ALUSrcA Multiplexer

**RTL File:** `alusrca_mux.v`

**Category:** (C) Multiplexer

---

## Purpose

Selects the first operand for the ALU.

---

## Function

- Selects either the Program Counter or Register A.

---

## Interface Specification

### Inputs

| Signal | Width | Description |
|--------|------:|-------------|
| `pc` | 32 | Program Counter |
| `A_out` | 32 | Register A Output |
| `ALUSrcA` | 1 | Select signal from Control FSM |

### Output

| Signal | Width | Description |
|--------|------:|-------------|
| `alu_src_a` | 32 | First ALU Operand |

---

## Selection Table

| ALUSrcA | Output |
|---------|--------|
| 0 | PC |
| 1 | Register A |

---

## Logic

```verilog
assign alu_src_a = (ALUSrcA) ? reg_a : pc;
```

---

## Type

- 2-to-1 Multiplexer
- 32-bit Wide
- Combinational Logic

---

# Module 15 Specification

## ALUSrcB Multiplexer

**RTL File:** `alusrcb_mux.v`

**Category:** (C) Multiplexer

---

## Purpose

Selects the second operand for the ALU.

---

## Function

Selects one of four ALU operands.

---

## Interface Specification

### Inputs

| Signal | Width | Description |
|--------|------:|-------------|
| `B_out` | 32 | Register B Output |
| `constant_4` | 32 | Constant value 4 |
| `ImmExt` | 32 | Immediate Generator Output |
| `ALUSrcB` | 2 | Select signal from Control FSM |

### Output

| Signal | Width | Description |
|--------|------:|-------------|
| `alu_src_b` | 32 | Second ALU Operand |

---

## Selection Table

| ALUSrcB | Output |
|----------|--------|
| 00 | Register B |
| 01 | Constant 4 |
| 10 | Immediate |
| 11 | Branch Offset |

---

## Logic

```verilog
case(ALUSrcB)
2'b00 : alu_src_b = reg_b;
2'b01 : alu_src_b = 32'd4;
2'b10 : alu_src_b = imm;
2'b11 : alu_src_b = branch_offset;
endcase
```

---

## Type

- 4-to-1 Multiplexer
- 32-bit Wide
- Combinational Logic


---

# Module 16 Specification

## PCSource Multiplexer

**RTL File:** `pcsource_mux.v`

**Category:** (C) Multiplexer

---

## Purpose

Selects the next value to be loaded into the Program Counter.

---

## Function

Chooses the source of the next Program Counter value.

---

## Interface Specification

### Inputs

| Signal | Width | Description |
|--------|------:|-------------|
| `alu_result` | 32 | ALU Output |
| `alu_out` | 32 | ALUOut Register |
| `PCSource` | 1 | Select signal from Control FSM |

### Output

| Signal | Width | Description |
|--------|------:|-------------|
| `pc_next` | 32 | Next Program Counter Value |

---

## Selection Table

| PCSource | Output |
|-----------|--------|
| 0 | ALU Result |
| 1 | ALUOut Register |

---

## Logic

```verilog
assign pc_next = (PCSource) ? alu_out : alu_result;
```

---

## Type

- 2-to-1 Multiplexer
- 32-bit Wide
- Combinational Logic

---

# Module 17 Specification

## MemtoReg Multiplexer

**RTL File:** `memtoreg_mux.v`

**Category:** (C) Multiplexer

---

## Purpose

Selects the data written back into the Register File.

---

## Function

Selects either the ALUOut register or the Memory Data Register.

---

## Interface Specification

### Inputs

| Signal | Width | Description |
|--------|------:|-------------|
| `alu_out` | 32 | ALUOut Register |
| `mdr` | 32 | Memory Data Register |
| `MemtoReg` | 1 | Select signal from Control FSM |

### Output

| Signal | Width | Description |
|--------|------:|-------------|
| `write_data` | 32 | Data written into Register File |

---

## Selection Table

| MemtoReg | Output |
|-----------|--------|
| 0 | ALUOut |
| 1 | MDR |

---

## Logic

```verilog
assign write_data = (MemtoReg) ? mdr : alu_out;
```

---

## Type

- 2-to-1 Multiplexer
- 32-bit Wide
- Combinational Logic

### Summary

| Module           | MUX Type |  Width |     Select |
| ---------------- | -------- | -----: | ---------- |
| `iord_mux.v`     | 2:1      | 32-bit |     `IorD` |
| `alusrca_mux.v`  | 2:1      | 32-bit |  `ALUSrcA` |
| `alusrcb_mux.v`  | 4:1      | 32-bit |  `ALUSrcB` |
| `pcsource_mux.v` | 2:1      | 32-bit | `PCSource` |
| `memtoreg_mux.v` | 2:1      | 32-bit | `MemtoReg` |

