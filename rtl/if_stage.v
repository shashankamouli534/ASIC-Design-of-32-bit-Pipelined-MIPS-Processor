module if_stage (
  input  wire        clk,
  input  wire        rst,
  input  wire        stall,
  input  wire        flush,
  input  wire [31:0] pc_next,
  output wire [31:0] pc,
  output wire [31:0] pc4,
  output wire [31:0] instr
);

  pc PC (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pc_next(pc_next),
    .pc(pc)
  );

  assign pc4 = pc + 32'd4;

  instr_mem IMEM (
    .clk(clk),
    .addr(pc),
    .instr(instr)
  );

endmodule
