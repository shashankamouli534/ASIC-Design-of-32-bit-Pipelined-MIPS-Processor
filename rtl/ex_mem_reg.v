module ex_mem_reg (
  input  wire        clk,
  input  wire        rst,

  input  wire        ex_regwrite,
  input  wire        ex_memread,
  input  wire        ex_memwrite,
  input  wire        ex_memtoreg,

  input  wire [31:0] alu_result,
  input  wire [31:0] rt_data,
  input  wire [4:0]  rd_in,

  output reg         mem_regwrite,
  output reg         mem_memread,
  output reg         mem_memwrite,
  output reg         mem_memtoreg,
  output reg  [31:0] mem_alu_result,
  output reg  [31:0] mem_rt_data,
  output reg  [4:0]  mem_rd
);

always @(posedge clk or posedge rst) begin
  if (rst) begin
    mem_regwrite   <= 0;
    mem_memread    <= 0;
    mem_memwrite   <= 0;
    mem_memtoreg   <= 0;
    mem_alu_result <= 0;
    mem_rt_data    <= 0;
    mem_rd         <= 0;
  end
  else begin
    mem_regwrite   <= ex_regwrite;
    mem_memread    <= ex_memread;
    mem_memwrite   <= ex_memwrite;
    mem_memtoreg   <= ex_memtoreg;
    mem_alu_result <= alu_result;
    mem_rt_data    <= rt_data;
    mem_rd         <= rd_in;
  end
end

endmodule
