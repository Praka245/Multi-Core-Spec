
<div align="center">

# 🚀 RV32I Multi-Cycle Processor
### *Designing from Scratch using Verilog HDL*

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=24&pause=1000&color=00BFFF&center=true&vCenter=true&width=800&lines=Fetch+%E2%86%92+Decode+%E2%86%92+Execute+%E2%86%92+Memory+%E2%86%92+WriteBack;RV32I+Multi-Cycle+Processor;Designed+Using+Finite+State+Machine;One+zInstruction+-+Multiple+Cycles!" />

</div>

---

# 🔥 Multi-Core-Spec

- In this repo the specification for all the individual modules are available in the `SPECIFICATION DIRECTORY`


---


<img width="1157" height="844" alt="Screenshot 2026-07-01 161035" src="https://github.com/user-attachments/assets/4d614715-041c-43fe-be1f-adfb87e19d8c" />

---

```
rtl/
│
├── datapath/
│   ├── pc.v
│   ├── unified_memory.v
│   ├── instruction_register.v
│   ├── memory_data_register.v
│   ├── register_file.v
│   ├── register_a.v
│   ├── register_b.v
│   ├── imm_gen.v
│   ├── alu.v                
│   └── alu_out.v
│
├── control/
│   ├── control_fsm.v
│   └── alu_control.v
│
├── mux/
│   ├── iord_mux.v
│   ├── alusrca_mux.v
│   ├── alusrcb_mux.v
│   ├── pcsource_mux.v
│   └── memtoreg_mux.v
│
├── top/
    └── multicycle_core.v


```

--- 

