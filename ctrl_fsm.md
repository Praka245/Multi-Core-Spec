Yes. This is actually the **master document** for implementing `control_fsm.v`. Below is the **complete FSM State Table** for our RV32I Multi-Cycle processor, consistent with the modules and architecture we have finalized.


# Complete FSM State Table


| State | State Name | Operation Performed | Control Signals Asserted | Next State |
|:-----:|-------------|---------------------|--------------------------|------------|
| S0 | Instruction Fetch | Fetch instruction from memory, Load IR, PC ← PC + 4 | `MemRead`, `IRWrite`, `PCWrite`, `ALUSrcA=0`, `ALUSrcB=01`, `ALUOp=00`, `IorD=0`, `PCSource=0` | S1 |
| S1 | Instruction Decode | Decode instruction, Read Register File, Load A & B Registers, Generate Immediate | `AWrite`, `BWrite` | Depends on Opcode |
| S2 | Execute (R-Type) | Perform Register-Register ALU Operation | `ALUSrcA=1`, `ALUSrcB=00`, `ALUOp=10`, `ALUOutWrite` | S7 |
| S3 | Execute (I-Type) | Perform Register-Immediate ALU Operation | `ALUSrcA=1`, `ALUSrcB=10`, `ALUOp=10`, `ALUOutWrite` | S7 |
| S4 | Address Calculation | Compute Effective Address for Load/Store | `ALUSrcA=1`, `ALUSrcB=10`, `ALUOp=00`, `ALUOutWrite` | S5 (Load) / S6 (Store) |
| S5 | Memory Read | Read Data Memory into MDR | `MemRead`, `IorD=1`, `MDRWrite` | S8 |
| S6 | Memory Write | Write Register B Data into Memory | `MemWrite`, `IorD=1` | S0 |
| S7 | Write Back (ALU) | Write ALU Result into Register File | `RegWrite`, `MemtoReg=0` | S0 |
| S8 | Write Back (Load) | Write MDR Data into Register File | `RegWrite`, `MemtoReg=1` | S0 |
| S9 | Branch | Compare Registers and Update PC if Branch is Taken | `ALUSrcA=1`, `ALUSrcB=00`, `ALUOp=01`, `PCWriteCond`, `PCSource=1` | S0 |
| S10 | Jump | Update PC with Jump Target and Write Return Address | `PCWrite`, `PCSource=1`, `RegWrite` | S0 |
| S11 | U-Type | Execute LUI / AUIPC and Write Result Back | `ALUSrcA`, `ALUSrcB`, `ALUOp`, `ALUOutWrite` | S7 |


----

### Opcode-Based State Transitions

This table defines how the FSM transitions from the **Decode** state based on the instruction opcode.


# Decode State Transition Table

| Opcode | Instruction Type | Next State |
|---------|------------------|------------|
| R-Type (`0110011`) | Register-Register ALU | S2 |
| I-Type (`0010011`) | Immediate ALU | S3 |
| Load (`0000011`) | Load | S4 |
| Store (`0100011`) | Store | S4 |
| Branch (`1100011`) | Conditional Branch | S9 |
| JAL (`1101111`) | Jump and Link | S10 |
| JALR (`1100111`) | Jump and Link Register | S10 |
| LUI (`0110111`) | Load Upper Immediate | S11 |
| AUIPC (`0010111`) | Add Upper Immediate to PC | S11 |

---

### Note

This is the **high-level FSM state table** and is ideal for documentation.

When we implement `control_fsm.v`, we will create a **detailed control signal table** for each state, showing the value (`0`, `1`, `00`, `01`, etc.) of **every control signal** (`PCWrite`, `IRWrite`, `MemRead`, `MemWrite`, `ALUSrcA`, `ALUSrcB`, `PCSource`, `MemtoReg`, `ALUOp`, `IorD`, etc.). That detailed table will serve as the direct blueprint for the RTL implementation.
