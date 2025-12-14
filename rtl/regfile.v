module regfile (
  input  wire clk,
  input  wire rst,
  input  wire [4:0] rs,
  input  wire [4:0] rt,
  input  wire [4:0] rd,
  input  wire [31:0] wd,
  input  wire we,
  output reg  [31:0] rs_data,
  output reg  [31:0] rt_data
);

reg [31:0] regs [0:31];
integer i;

always @(*) begin
  rs_data = (rs != 0) ? regs[rs] : 32'd0;
  rt_data = (rt != 0) ? regs[rt] : 32'd0;
end

always @(posedge clk) begin
  if (rst)
    for (i=0;i<32;i=i+1) regs[i] <= 32'd0;
  else if (we && rd != 0)
    regs[rd] <= wd;
end

endmodule
