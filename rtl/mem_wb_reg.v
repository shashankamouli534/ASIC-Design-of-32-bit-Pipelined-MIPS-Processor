module mem_wb_reg (
  input  wire clk,
  input  wire rst,

  input  wire mem_regwrite,
  input  wire mem_memtoreg,
  input  wire [31:0] mem_alu_result,
  input  wire [31:0] mem_read_data,
  input  wire [4:0]  mem_rd,

  output reg  wb_regwrite,
  output reg  wb_memtoreg,
  output reg  [31:0] wb_alu_result,
  output reg  [31:0] wb_read_data,
  output reg  [4:0]  wb_rd
);

always @(posedge clk or posedge rst) begin
  if (rst) begin
    wb_regwrite   <= 0;
    wb_memtoreg   <= 0;
    wb_alu_result <= 0;
    wb_read_data  <= 0;
    wb_rd         <= 0;
  end else begin
    wb_regwrite   <= mem_regwrite;
    wb_memtoreg   <= mem_memtoreg;
    wb_alu_result <= mem_alu_result;
    wb_read_data  <= mem_read_data;
    wb_rd         <= mem_rd;
  end
end

endmodule
