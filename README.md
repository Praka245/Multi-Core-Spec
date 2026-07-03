# 🔥 Multi-Core-Spec

- In this repo the specification for all the individual modules are available in the `Specification folder`

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
│   └── multicycle_core.v
│
└── tb/
    └── multicycle_core_tb.v

```
