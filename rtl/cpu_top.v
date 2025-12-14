module cpu_top (
  input  wire clk,
  input  wire rst
);

  /* IF wires */
  wire [31:0] if_pc, if_pc4, if_instr, pc_next;
  wire        if_stall, if_flush;

  /* ID wires */
  wire [31:0] id_pc4, id_instr, id_imm;
  wire        id_branch_taken;
  wire [4:0]  id_rs, id_rt, id_rd;
  wire [31:0] rf_rs_data, rf_rt_data;

  /* Control */
  wire        ctrl_regwrite, ctrl_memread, ctrl_memwrite;
  wire        ctrl_memtoreg, ctrl_alusrc, ctrl_branch, ctrl_regdst;
  wire [3:0]  ctrl_aluop;

  /* EX */
  wire        ex_regwrite, ex_memread, ex_memwrite, ex_memtoreg;
  wire        ex_alusrc, ex_regdst;
  wire [3:0]  ex_aluop;
  wire [31:0] ex_rs_data, ex_rt_data, ex_imm;
  wire [4:0]  ex_rs, ex_rt, ex_rd;
  wire [1:0]  fwd_a, fwd_b;
  wire [31:0] alu_in1, alu_in2, alu_b_pre, alu_result;
  wire        alu_zero;
  wire [4:0]  write_reg_ex;

  /* MEM */
  wire        mem_regwrite, mem_memread, mem_memwrite, mem_memtoreg;
  wire [31:0] mem_alu_result, mem_rt_data, mem_read_data;
  wire [4:0]  mem_rd;

  wire [31:0] mem_forward_data =
    mem_memtoreg ? mem_read_data : mem_alu_result;

  /* WB */
  wire        wb_regwrite, wb_memtoreg;
  wire [31:0] wb_alu_result, wb_read_data, wb_data;
  wire [4:0]  wb_rd;

  /* PC logic */
  assign pc_next = id_branch_taken ? (id_pc4 + id_imm) : if_pc4;
  assign if_flush = id_branch_taken;

  /* IF */
  if_stage IF (
    .clk(clk), .rst(rst),
    .stall(if_stall),
    .flush(if_flush),
    .pc_next(pc_next),
    .pc(if_pc),
    .pc4(if_pc4),
    .instr(if_instr)
  );

  if_id_reg IF_ID (
    .clk(clk), .rst(rst),
    .stall(if_stall),
    .flush(if_flush),
    .i_pc4(if_pc4),
    .i_instr(if_instr),
    .o_pc4(id_pc4),
    .o_instr(id_instr)
  );

  /* Register file */
  regfile RF (
    .clk(clk),
    .rst(rst),
    .rs(id_rs),
    .rt(id_rt),
    .rd(wb_rd),
    .wd(wb_data),
    .we(wb_regwrite),
    .rs_data(rf_rs_data),
    .rt_data(rf_rt_data)
  );

  /* ID */
  id_stage ID (
    .instr(id_instr),
    .rs_data(rf_rs_data),
    .rt_data(rf_rt_data),
    .imm(id_imm),
    .branch_taken(id_branch_taken),
    .ctrl_regwrite(ctrl_regwrite),
    .ctrl_memread(ctrl_memread),
    .ctrl_memwrite(ctrl_memwrite),
    .ctrl_memtoreg(ctrl_memtoreg),
    .ctrl_alusrc(ctrl_alusrc),
    .ctrl_branch(ctrl_branch),
    .ctrl_regdst(ctrl_regdst),
    .ctrl_aluop(ctrl_aluop),
    .rs(id_rs),
    .rt(id_rt),
    .rd(id_rd)
  );

  hazard_unit HAZ (
    .id_ex_memread(ex_memread),
    .id_ex_rt(ex_rt),
    .if_id_rs(id_rs),
    .if_id_rt(id_rt),
    .stall(if_stall)
  );

  id_ex_reg ID_EX (
    .clk(clk), .rst(rst), .stall(if_stall),
    .ctrl_regwrite(ctrl_regwrite),
    .ctrl_memread(ctrl_memread),
    .ctrl_memwrite(ctrl_memwrite),
    .ctrl_memtoreg(ctrl_memtoreg),
    .ctrl_alusrc(ctrl_alusrc),
    .ctrl_regdst(ctrl_regdst),
    .ctrl_aluop(ctrl_aluop),
    .rs_data(rf_rs_data),
    .rt_data(rf_rt_data),
    .imm(id_imm),
    .rs(id_rs), .rt(id_rt), .rd(id_rd),
    .ex_regwrite(ex_regwrite),
    .ex_memread(ex_memread),
    .ex_memwrite(ex_memwrite),
    .ex_memtoreg(ex_memtoreg),
    .ex_alusrc(ex_alusrc),
    .ex_regdst(ex_regdst),
    .ex_aluop(ex_aluop),
    .ex_rs_data(ex_rs_data),
    .ex_rt_data(ex_rt_data),
    .ex_imm(ex_imm),
    .ex_rs(ex_rs),
    .ex_rt(ex_rt),
    .ex_rd(ex_rd)
  );

  forwarding_unit FU (
    .ex_mem_regwrite(mem_regwrite),
    .mem_wb_regwrite(wb_regwrite),
    .ex_mem_rd(mem_rd),
    .mem_wb_rd(wb_rd),
    .id_ex_rs(ex_rs),
    .id_ex_rt(ex_rt),
    .forward_a(fwd_a),
    .forward_b(fwd_b)
  );

  assign alu_in1 =
    (fwd_a == 2'b10) ? mem_forward_data :
    (fwd_a == 2'b01) ? wb_data :
                       ex_rs_data;

  assign alu_b_pre =
    (fwd_b == 2'b10) ? mem_forward_data :
    (fwd_b == 2'b01) ? wb_data :
                       ex_rt_data;

  assign alu_in2 = ex_alusrc ? ex_imm : alu_b_pre;

  alu ALU (
    .a(alu_in1),
    .b(alu_in2),
    .alu_ctrl(ex_aluop),
    .result(alu_result),
    .zero(alu_zero)
  );

  assign write_reg_ex = ex_regdst ? ex_rd : ex_rt;

  ex_mem_reg EX_MEM (
    .clk(clk), .rst(rst),
    .ex_regwrite(ex_regwrite),
    .ex_memread(ex_memread),
    .ex_memwrite(ex_memwrite),
    .ex_memtoreg(ex_memtoreg),
    .alu_result(alu_result),
    .rt_data(alu_b_pre), // FIX: correct store data
    .rd_in(write_reg_ex),
    .mem_regwrite(mem_regwrite),
    .mem_memread(mem_memread),
    .mem_memwrite(mem_memwrite),
    .mem_memtoreg(mem_memtoreg),
    .mem_alu_result(mem_alu_result),
    .mem_rt_data(mem_rt_data),
    .mem_rd(mem_rd)
  );

  data_mem DM (
    .clk(clk),
    .memread(mem_memread),
    .memwrite(mem_memwrite),
    .addr(mem_alu_result),
    .write_data(mem_rt_data),
    .read_data(mem_read_data)
  );

  mem_wb_reg MEM_WB (
    .clk(clk), .rst(rst),
    .mem_regwrite(mem_regwrite),
    .mem_memtoreg(mem_memtoreg),
    .mem_alu_result(mem_alu_result),
    .mem_read_data(mem_read_data),
    .mem_rd(mem_rd),
    .wb_regwrite(wb_regwrite),
    .wb_memtoreg(wb_memtoreg),
    .wb_alu_result(wb_alu_result),
    .wb_read_data(wb_read_data),
    .wb_rd(wb_rd)
  );

  wb_mux WB (
    .alu_result(wb_alu_result),
    .mem_data(wb_read_data),
    .memtoreg(wb_memtoreg),
    .wb_data(wb_data)
  );

endmodule
