module instr_mem (
  input  wire clk,
  input  wire [31:0] addr,
  output reg  [31:0] instr
);

reg [31:0] mem [0:1023];

always @(posedge clk)
  instr <= mem[addr[11:2]];  // word aligned

endmodule
