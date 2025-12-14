module if_id_reg (
  input  wire        clk,
  input  wire        rst,
  input  wire        stall,
  input  wire        flush,
  input  wire [31:0] i_pc4,
  input  wire [31:0] i_instr,
  output reg  [31:0] o_pc4,
  output reg  [31:0] o_instr
);

always @(posedge clk or posedge rst) begin
  if (rst) begin
    o_pc4   <= 32'd0;
    o_instr <= 32'd0;
  end
  else if (!stall) begin
    o_pc4   <= i_pc4;
    o_instr <= flush ? 32'd0 : i_instr;
  end
end

endmodule
