# Module 4 Specification

## Memory Data Register (MDR)

**RTL File:** `memory_data_register.v`

**Category:** (A) Datapath Block

---

# 1. Purpose

The **Memory Data Register (MDR)** is a **32-bit register** that temporarily stores the data read from the **Unified Memory** during **Load (`lw`)** instructions.

The MDR holds the memory data until it is written back to the Register File during the Write-Back (WB) stage.

---

# 2. Function

The Memory Data Register performs the following functions:

- Receives data from the Unified Memory.
- Stores one 32-bit data word.
- Holds the data until the Write-Back stage.
- Supplies the stored data to the MemtoReg MUX.

Unlike the Instruction Register (IR), the MDR does **not** require a separate write-enable signal because it is only written during the Memory Access stage.

---

# 3. Interface Specification

## Inputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `reset` | 1 | Input | Active-low asynchronous reset |
| `read_data` | 32 | Input | Data read from Unified Memory |

---

## Outputs

| Signal | Width | Direction | Description |
|--------|------:|-----------|-------------|
| `mdr_out` | 32 | Output | Data stored in the Memory Data Register |

---

# 4. Register Specification

| Register | Width | Description |
|----------|------:|-------------|
| Memory Data Register (MDR) | 32 bits | Stores data read from Unified Memory |

Only one internal register is required.

---

# 5. Data Width

| Item | Value |
|------|-------|
| Register Width | 32 bits |
| Data Width | 32 bits |

---

# 6. Functional Specification

## Reset

When

```text
reset = 0
```

the Memory Data Register is cleared.

```text
MDR ← 0x00000000
```

---

## Memory Read

During the Memory Access stage of a Load (`lw`) instruction,

```text
MDR ← read_data
```

The data received from the Unified Memory is stored in the MDR.

---

## Hold Operation

After loading the data, the MDR retains its value until the Write-Back stage.

```text
MDR ← MDR
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

the Memory Data Register is cleared.

```text
mdr_out = 32'h00000000
```

---

# 9. Interface Connections

<img width="604" height="592" alt="image" src="https://github.com/user-attachments/assets/66472083-71e5-496a-9c2d-a34bdecf6176" />


---

# 10. Control Signals Used

| Signal | Source |
|--------|--------|
| `clk` | System Clock |
| `reset` | System Reset |

> **Note:** The MDR does not require a dedicated write-enable signal. Since it is updated only during the Memory Access stage, the Control FSM naturally controls when valid memory data is available.

---

# 11. Design Decisions

## Why is the MDR Required?

The Unified Memory is used for both instruction and data accesses.

During a Load (`lw`) instruction, the memory output must be preserved until the Write-Back stage.

The MDR stores the memory data so that it remains available even after the memory is used for other operations.

---

## Why Doesn't the MDR Need a Write Enable?

The MDR is only used during the Memory Access stage of Load instructions.

At that stage, the Unified Memory provides valid data, and the MDR captures it on the clock edge.

No additional enable signal is required.

---

# 12. Design Assumptions

- RV32I Base ISA
- 32-bit data path
- Positive-edge-triggered register
- Active-low asynchronous reset
- Used only for Load (`lw`) instructions

---

# 13. Future Scalability

This module can later support:

- RV64I (64-bit data)
- Cached memory systems
- External memory interfaces
- Pipeline memory stages

---

# 14. Verification Checklist

The testbench shall verify:

- Reset clears the MDR.
- MDR correctly captures memory data.
- MDR retains its value after loading.
- Consecutive Load operations.
- Reset during processor execution.

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
| Module | `memory_data_register.v` |
| Category | Datapath |
| Register Width | 32 bits |
| Trigger | Positive-edge clock |
| Reset | Active-low asynchronous |
| Input | `read_data` |
| Output | `mdr_out` |
