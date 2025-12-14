module id_stage (
  input  wire clk,
  input  wire rst,
  input  wire [31:0] instr,
  input  wire [31:0] pc4,

  output wire [31:0] rs_data,
  output wire [31:0] rt_data,
  output wire [31:0] imm,
  output wire branch_taken,

  output wire ctrl_regwrite,
  output wire ctrl_memread,
  output wire ctrl_memwrite,
  output wire ctrl_memtoreg,
  output wire ctrl_alusrc,
  output wire ctrl_branch,
  output wire ctrl_regdst,
  output wire [3:0] ctrl_aluop,

  output wire [4:0] rs,
  output wire [4:0] rt,
  output wire [4:0] rd
);

assign rs = instr[25:21];
assign rt = instr[20:16];
assign rd = instr[15:11];

regfile RF (
  .clk(clk),
  .rst(rst),
  .rs(rs),
  .rt(rt),
  .rd(5'd0),     // writeback handled in cpu_top
  .wd(32'd0),
  .we(1'b0),
  .rs_data(rs_data),
  .rt_data(rt_data)
);

control_unit CU (
  .opcode(instr[31:26]),
  .ctrl_regwrite(ctrl_regwrite),
  .ctrl_memread(ctrl_memread),
  .ctrl_memwrite(ctrl_memwrite),
  .ctrl_memtoreg(ctrl_memtoreg),
  .ctrl_alusrc(ctrl_alusrc),
  .ctrl_branch(ctrl_branch),
  .ctrl_regdst(ctrl_regdst),
  .ctrl_aluop(ctrl_aluop)
);

imm_gen IMM (.instr(instr), .imm(imm));

branch_unit BU (
  .rs_data(rs_data),
  .rt_data(rt_data),
  .is_branch(ctrl_branch),
  .taken(branch_taken)
);

endmodule
