`ifndef LAB_TOP_SVH
`define LAB_TOP_SVH

// change this when add devices
`define SEL_WIDTH 3

// Multiplexers (Enums)
// MMIO (Memory-Mapped I/O)
`define SEL_MEM          `SEL_WIDTH'd0
`define SEL_DEV1         `SEL_WIDTH'd1
`define SEL_DEV2         `SEL_WIDTH'd2
`define SEL_DEV3         `SEL_WIDTH'd3
`define SEL_INVALID_ADDR `SEL_WIDTH'd4

`endif  // `ifndef LAB_TOP_SVH
