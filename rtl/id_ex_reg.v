module id_ex_reg (
  input  wire        clk,
  input  wire        rst,
  input  wire        stall,

  input  wire        ctrl_regwrite,
  input  wire        ctrl_memread,
  input  wire        ctrl_memwrite,
  input  wire        ctrl_memtoreg,
  input  wire        ctrl_alusrc,
  input  wire        ctrl_regdst,
  input  wire [3:0]  ctrl_aluop,

  input  wire [31:0] rs_data,
  input  wire [31:0] rt_data,
  input  wire [31:0] imm,
  input  wire [4:0]  rs,
  input  wire [4:0]  rt,
  input  wire [4:0]  rd,

  output reg         ex_regwrite,
  output reg         ex_memread,
  output reg         ex_memwrite,
  output reg         ex_memtoreg,
  output reg         ex_alusrc,
  output reg         ex_regdst,
  output reg  [3:0]  ex_aluop,

  output reg  [31:0] ex_rs_data,
  output reg  [31:0] ex_rt_data,
  output reg  [31:0] ex_imm,
  output reg  [4:0]  ex_rs,
  output reg  [4:0]  ex_rt,
  output reg  [4:0]  ex_rd
);

always @(posedge clk or posedge rst) begin
  if (rst) begin
    ex_regwrite <= 0;
    ex_memread  <= 0;
    ex_memwrite <= 0;
    ex_memtoreg <= 0;
    ex_alusrc   <= 0;
    ex_regdst   <= 0;
    ex_aluop    <= 0;
    ex_rs_data  <= 0;
    ex_rt_data  <= 0;
    ex_imm      <= 0;
    ex_rs       <= 0;
    ex_rt       <= 0;
    ex_rd       <= 0;
  end
  else if (stall) begin
    ex_regwrite <= 0;
    ex_memread  <= 0;
    ex_memwrite <= 0;
    ex_memtoreg <= 0;
    ex_alusrc   <= 0;
    ex_regdst   <= 0;
    ex_aluop    <= 4'b0000;
  end
  else begin
    ex_regwrite <= ctrl_regwrite;
    ex_memread  <= ctrl_memread;
    ex_memwrite <= ctrl_memwrite;
    ex_memtoreg <= ctrl_memtoreg;
    ex_alusrc   <= ctrl_alusrc;
    ex_regdst   <= ctrl_regdst;
    ex_aluop    <= ctrl_aluop;
    ex_rs_data  <= rs_data;
    ex_rt_data  <= rt_data;
    ex_imm      <= imm;
    ex_rs       <= rs;
    ex_rt       <= rt;
    ex_rd       <= rd;
  end
end

endmodule
