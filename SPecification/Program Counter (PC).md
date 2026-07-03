# Module 1 Specification

## Program Counter (PC)

**RTL File:** `pc.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Program Counter (PC)** is a **32-bit register** that stores the **byte address of the current instruction** being executed.

It provides the address to the **Unified Memory** during the **Instruction Fetch (IF)** cycle and is updated with the address of the next instruction at the end of the cycle.

---

# 2. Function

The Program Counter performs the following functions:

- Stores the current instruction address.
- Supplies the address to the Unified Memory.
- Updates its value on every clock cycle when enabled.
- Supports sequential execution (`PC + 4`).
- Supports branch target addresses.
- Supports jump target addresses.
- Supports JALR target addresses.

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `pc_write` | 1 | Input | Enables updating the PC |
| `pc_next` | 32 | Input | Next PC value selected by the PCSource MUX |

### Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `pc` | 32 | Output | Current Program Counter value |

---

# 4. Register Specification

| Register | Width | Description |
|----------|------:|-------------|
| PC Register | 32 bits | Stores the current instruction address |

Only **one internal register** is required.

---

# 5. Data Width

| Item | Value |
|------|-------|
| Register Width | 32 bits |
| Address Width | 32 bits |

---

# 6. Functional Specification

## Reset

When

```text
reset = 0
```

then

```text
PC ← 0x00000000
```

---

## Normal Operation

On every positive edge of the clock,

If

```text
pc_write = 1
```

then

```text
pc ← pc_next
```

Otherwise,

```text
PC retains its previous value.
```

---

# 7. Timing Specification

| Item | Specification |
|------|---------------|
| Trigger | Positive edge of clock |
| Reset | Asynchronous Active-Low |
| Output Type | Registered |

---

# 8. Reset Behavior

When reset is asserted

```text
PC = 0x00000000
```

This ensures execution always starts from address zero after reset.

---

# 9. Interface Connections

```text
                 +----------------+
                 |  PCSource MUX  |
                 +----------------+
                         │
                         │ pc_next
                         ▼
                  +-------------+
                  | Program     |
                  | Counter     |
                  +-------------+
                         │
                         │ pc
                         ▼
                 Unified Memory
```

---

# 10. Control Signals Used

| Signal | Source |
|--------|--------|
| `clk` | System Clock |
| `reset` | System Reset |
| `pc_write` | Control FSM |
| `pc_next` | PCSource MUX |

---

# 11. Design Decisions

## Why 32 bits?

RV32I uses a **32-bit address space**; therefore, the Program Counter is implemented as a **32-bit register**.

---

## Why include `pc_write`?

In a **Multi-Cycle Processor**, the Program Counter **must not** change every clock cycle.

For example:

```text
Cycle 1 : Fetch
Cycle 2 : Decode
Cycle 3 : Execute
Cycle 4 : Memory
Cycle 5 : Write Back
```

The same instruction executes over multiple clock cycles.

If the PC were updated every clock edge, the processor would begin fetching the next instruction before the current instruction had completed execution.

Therefore, the **Control FSM** enables the Program Counter only during the appropriate states by asserting the `pc_write` signal.

---

# 12. Design Assumptions

- RV32I Base ISA
- Byte-addressable memory
- Von Neumann Architecture
- Single Clock Domain
- Positive-edge-triggered design
- Active-low asynchronous reset

---

# 13. Future Scalability

This Program Counter module can be reused for:

- RV64I (by increasing the register width)
- Pipelined Processor
- Cached Processor
- Harvard Architecture
- Five-stage Pipeline

No functional modification is required.

---

# 14. Verification Checklist

The testbench shall verify:

- Reset initializes the PC to `0x00000000`.
- PC updates correctly when `pc_write = 1`.
- PC holds its value when `pc_write = 0`.
- PC accepts sequential addresses (`PC + 4`).
- PC accepts branch target addresses.
- PC accepts jump target addresses.
- PC accepts JALR target addresses.
- Multiple consecutive updates occur correctly.
- Reset during operation correctly returns the PC to zero.

---

# 15. Hardware Resources

| Resource | Quantity |
|----------|---------:|
| 32-bit Register | 1 |
| D Flip-Flops | 32 |
| Combinational Logic | None (inside this module) |

---

# Final Specification Summary

| Item | Value |
|------|-------|
| Module | `pc.v` |
| Category | Datapath |
| Width | 32 bits |
| Type | Register |
| Trigger | Positive-edge clock |
| Reset | Active-low asynchronous |
| Enable | `pc_write` |
| Output | `pc` |
| Inputs | `clk`, `reset`, `pc_write`, `pc_next` |
