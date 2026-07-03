At this point, there are **no more individual RTL modules** left according to the architecture we've finalized.

The next and final RTL module is:

# Module 18 Specification

## Multi-Cycle Core (Top Module)

**RTL File:** `multicycle_core.v`

**Category:** (D) Top-Level Integration

---

This module will:

* Instantiate **all datapath modules**.
* Instantiate **all control modules**.
* Instantiate **all multiplexers**.
* Connect every module together exactly as shown in the Patterson & Hennessy Multi-Cycle datapath.
* Route all control signals from the FSM to the datapath.
* Route all data signals between the datapath components.
* Form the complete RV32I Multi-Cycle processor.

---

## The final hierarchy of the project is now:

```text
multicycle_core.v
│
├── pc.v
├── unified_memory.v
├── instruction_register.v
├── memory_data_register.v
├── register_file.v
├── register_a.v
├── register_b.v
├── imm_gen.v
├── alu.v
├── alu_out.v
│
├── control_fsm.v
├── alu_control.v
│
├── iord_mux.v
├── alusrca_mux.v
├── alusrcb_mux.v
├── pcsource_mux.v
└── memtoreg_mux.v
```
---
# Top Module Interface

## Inputs

| Signal | Width | Description |
|--------|------:|-------------|
| `clk` | 1 | System Clock |
| `reset` | 1 | Active-Low Asynchronous Reset |

---

## Outputs (Recommended for Debugging)

| Signal | Width | Description |
|--------|------:|-------------|
| `pc_out` | 32 | Current Program Counter |
| `instruction` | 32 | Current Instruction (IR Output) |
| `alu_result` | 32 | Current ALU Result |
| `mem_data` | 32 | Data Read from Memory (MDR Output) |

---


# We need to do these 🔥


1. RTL Coding
2. Individual Module Testbenches
3. Top-Level Integration
4. Top-Level Testbench
5. RV32I Program Execution
6. Waveform Verification
7. FPGA Implementation (ZedBoard)

---

``` 
BE CONFIDENT WE CAN DO THIS GUYS...🔥
```
