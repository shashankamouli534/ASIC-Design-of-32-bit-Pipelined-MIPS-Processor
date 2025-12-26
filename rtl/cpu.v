`timescale 1ns/1ps
module cpu_top (
  input wire clk,
  input wire rst
);

  /* IF */
  wire [31:0] if_pc, if_pc4, if_instr, pc_next;
  wire if_stall, if_flush;
// Register specifiers
wire [4:0] id_rs;
wire [4:0] id_rt;
wire [4:0] id_rd;
// ID stage data
wire [31:0] id_rs_data;
wire [31:0] id_rt_data;
wire [31:0] id_imm;
// Register file read data
wire [31:0] rf_rs_data;
wire [31:0] rf_rt_data;

  /* ID */
  wire [31:0] id_pc4, id_instr;
  wire id_branch_taken;

  wire ctrl_regwrite, ctrl_memread, ctrl_memwrite;
  wire ctrl_memtoreg, ctrl_alusrc, ctrl_branch, ctrl_regdst;
  wire [3:0] ctrl_aluop;

  /* EX */
  wire ex_regwrite, ex_memread, ex_memwrite, ex_memtoreg;
  wire ex_alusrc, ex_regdst;
  wire [3:0] ex_aluop;
  wire [31:0] ex_rs_data, ex_rt_data, ex_imm;
  wire [4:0] ex_rs, ex_rt, ex_rd;

  wire [1:0] fwd_a, fwd_b;
  wire [31:0] alu_in1, alu_in2, alu_b_pre;
  wire [31:0] alu_result;
  wire alu_zero;
  wire [4:0] write_reg_ex;

  /* MEM */
  wire mem_regwrite, mem_memread, mem_memwrite, mem_memtoreg;
  wire [31:0] mem_alu_result, mem_rt_data, mem_read_data;
  wire [4:0] mem_rd;
  // Correct forwarding data from MEM stage
  wire [31:0] mem_forward_data;
  assign mem_forward_data =
      mem_memtoreg ? mem_read_data : mem_alu_result;

  /* WB */
  wire wb_regwrite, wb_memtoreg;
  wire [31:0] wb_alu_result, wb_read_data, wb_data;
  wire [4:0] wb_rd;

  /* PC logic */
  assign pc_next = id_branch_taken ? (id_pc4 + id_imm) : if_pc4;
  assign if_flush = id_branch_taken;
assign id_rs_data = rf_rs_data;
assign id_rt_data = rf_rt_data;

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
  .rs_data(id_rs_data),
  .rt_data(id_rt_data),
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
  .id_ex_regwrite(ex_regwrite),  // ✅
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
    .rs_data(id_rs_data),
    .rt_data(id_rt_data),
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

  /* Forwarding */
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
wire [31:0] store_data;
  assign alu_b_pre =
    (fwd_b == 2'b10) ? mem_forward_data :
    (fwd_b == 2'b01) ? wb_data :
                       ex_rt_data;


  assign alu_in2 = ex_alusrc ? ex_imm : alu_b_pre;

  alu ALU (.a(alu_in1), .b(alu_in2), .alu_ctrl(ex_aluop),
              .result(alu_result), .zero(alu_zero));

  assign write_reg_ex = ex_regdst ? ex_rd : ex_rt;

  ex_mem_reg EX_MEM (
    .clk(clk), .rst(rst),
    .ex_regwrite(ex_regwrite),
    .ex_memread(ex_memread),
    .ex_memwrite(ex_memwrite),
    .ex_memtoreg(ex_memtoreg),
    .alu_result(alu_result),
.rt_data(store_data),
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
module data_mem (
  input  wire clk,
  input  wire memread,
  input  wire memwrite,
  input  wire [31:0] addr,
  input  wire [31:0] write_data,
  output reg  [31:0] read_data
);

reg [31:0] mem [0:1023];

// WRITE : synchronous
always @(posedge clk) begin
  if (memwrite)
    mem[addr[11:2]] <= write_data;
end

// READ : combinational
always @(*) begin
  if (memread)
    read_data = mem[addr[11:2]];
  else
    read_data = 32'd0;
end
initial begin
  mem[0] = 32'd7;   // memory[0] = 7
end

endmodule

module ex_mem_reg (
  input  wire clk,
  input  wire rst,

  input  wire ex_regwrite,
  input  wire ex_memread,
  input  wire ex_memwrite,
  input  wire ex_memtoreg,

  input  wire [31:0] alu_result,
  input  wire [31:0] rt_data,
  input  wire [4:0]  rd_in,

  output reg  mem_regwrite,
  output reg  mem_memread,
  output reg  mem_memwrite,
  output reg  mem_memtoreg,
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
  end else begin
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
module forwarding_unit (
  input  wire ex_mem_regwrite,
  input  wire mem_wb_regwrite,
  input  wire [4:0] ex_mem_rd,
  input  wire [4:0] mem_wb_rd,
  input  wire [4:0] id_ex_rs,
  input  wire [4:0] id_ex_rt,
  output reg  [1:0] forward_a,
  output reg  [1:0] forward_b
);

always @(*) begin
  forward_a = 2'b00;
  forward_b = 2'b00;

  /* EX hazard */
  if (ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs))
    forward_a = 2'b10;

  if (ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rt))
    forward_b = 2'b10;

  /* MEM hazard */
  if (mem_wb_regwrite && (mem_wb_rd != 0) &&
     !(ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs)) &&
      (mem_wb_rd == id_ex_rs))
    forward_a = 2'b01;

  if (mem_wb_regwrite && (mem_wb_rd != 0) &&
     !(ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rt)) &&
      (mem_wb_rd == id_ex_rt))
    forward_b = 2'b01;
end

endmodule
module hazard_unit (
  input  wire id_ex_memread,
  input  wire id_ex_regwrite,   // from ID/EX
  input  wire [4:0] id_ex_rt,
  input  wire [4:0] if_id_rs,
  input  wire [4:0] if_id_rt,
  output reg  stall
);

always @(*) begin
  stall = 0;

  if (
      id_ex_memread &&
      (id_ex_rt != 0) &&
      ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt))
     )
    stall = 1;
end

endmodule
module id_ex_reg (
  input wire clk,
  input wire rst,
  input wire stall,

  input wire ctrl_regwrite,
  input wire ctrl_memread,
  input wire ctrl_memwrite,
  input wire ctrl_memtoreg,
  input wire ctrl_alusrc,
  input wire ctrl_regdst,
  input wire [3:0] ctrl_aluop,

  input wire [31:0] rs_data,
  input wire [31:0] rt_data,
  input wire [31:0] imm,
  input wire [4:0] rs,
  input wire [4:0] rt,
  input wire [4:0] rd,

  output reg ex_regwrite,
  output reg ex_memread,
  output reg ex_memwrite,
  output reg ex_memtoreg,
  output reg ex_alusrc,
  output reg ex_regdst,
  output reg [3:0] ex_aluop,

  output reg [31:0] ex_rs_data,
  output reg [31:0] ex_rt_data,
  output reg [31:0] ex_imm,
  output reg [4:0] ex_rs,
  output reg [4:0] ex_rt,
  output reg [4:0] ex_rd
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
  end else if (stall) begin
  ex_regwrite <= 0;
  ex_memread  <= 0;
  ex_memwrite <= 0;
  ex_memtoreg <= 0;
  ex_alusrc   <= 0;
  ex_regdst   <= 0;
  ex_aluop    <= 4'b0000;

  end else begin
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
module id_stage (
  input  wire [31:0] instr,
  input  wire [31:0] rs_data,
  input  wire [31:0] rt_data,

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

wire [5:0] opcode = instr[31:26];
wire [5:0] funct  = instr[5:0];

control_unit CU (
  .opcode(opcode),
  .funct(funct),
  .ctrl_regwrite(ctrl_regwrite),
  .ctrl_memread(ctrl_memread),
  .ctrl_memwrite(ctrl_memwrite),
  .ctrl_memtoreg(ctrl_memtoreg),
  .ctrl_alusrc(ctrl_alusrc),
  .ctrl_branch(ctrl_branch),
  .ctrl_regdst(ctrl_regdst),
  .ctrl_aluop(ctrl_aluop)
);

imm_gen IMM (
  .instr(instr),
  .imm(imm)
);

branch_unit BU (
  .rs_data(rs_data),
  .rt_data(rt_data),
  .is_branch(ctrl_branch),
  .taken(branch_taken)
);

endmodule
module if_id_reg (
  input  wire clk,
  input  wire rst,
  input  wire stall,
  input  wire flush,
  input  wire [31:0] i_pc4,
  input  wire [31:0] i_instr,
  output reg  [31:0] o_pc4,
  output reg  [31:0] o_instr
);

always @(posedge clk or posedge rst) begin
  if (rst) begin
    o_pc4   <= 32'd0;
    o_instr <= 32'd0;
  end else if (!stall) begin
    o_pc4   <= i_pc4;
    o_instr <= flush ? 32'd0 : i_instr;
  end
end

endmodule
module if_stage (
  input  wire clk,
  input  wire rst,
  input  wire stall,
  input  wire flush,
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
module imm_gen (
  input  wire [31:0] instr,
  output reg  [31:0] imm
);

wire [5:0] opcode = instr[31:26];

always @(*) begin
  case (opcode)
    6'b001000,
    6'b100011,
    6'b101011:
      imm = {{16{instr[15]}}, instr[15:0]};

    6'b000100:
      imm = {{14{instr[15]}}, instr[15:0], 2'b00};

    default:
      imm = 32'd0;
  endcase
end

endmodule
module instr_mem (
  input  wire clk,
  input  wire [31:0] addr,
  output reg  [31:0] instr
);

reg [31:0] mem [0:1023];
initial begin
  // ===== STAGE 2.4 : LOAD-USE HAZARD =====
  // Assume data memory at address 0 contains 7

  // lw  r1, 0(r0)
  mem[0] = 32'b100011_00000_00001_0000000000000000;

  // add r2, r1, r1   ; must STALL
  mem[1] = 32'b000000_00001_00001_00010_00000_100000;

  // nop
  mem[2] = 32'b000000_00000_00000_00000_00000_000000;
end

always @(posedge clk)
  instr <= mem[addr[11:2]];  // word aligned

endmodule
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
module mux2 #(
  parameter WIDTH = 32
)(
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  input  wire sel,
  output wire [WIDTH-1:0] y
);

assign y = sel ? b : a;

endmodule
module mux3 #(
  parameter WIDTH = 32
)(
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  input  wire [WIDTH-1:0] c,
  input  wire [1:0] sel,
  output wire [WIDTH-1:0] y
);

assign y = (sel == 2'b00) ? a :
           (sel == 2'b01) ? b :
           (sel == 2'b10) ? c : a;

endmodule
module pc (
  input  wire clk,
  input  wire rst,
  input  wire stall,
  input  wire [31:0] pc_next,
  output reg  [31:0] pc
);

always @(posedge clk or posedge rst) begin
  if (rst)
    pc <= 32'd0;
  else if (!stall)
    pc <= pc_next;
end

endmodule
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
module control_unit (
  input  wire [5:0] opcode,
  input  wire [5:0] funct,

  output reg ctrl_regwrite,
  output reg ctrl_memread,
  output reg ctrl_memwrite,
  output reg ctrl_memtoreg,
  output reg ctrl_alusrc,
  output reg ctrl_branch,
  output reg ctrl_regdst,
  output reg [3:0] ctrl_aluop
);

localparam OP_RTYPE = 6'b000000;
localparam OP_LW    = 6'b100011;
localparam OP_SW    = 6'b101011;
localparam OP_BEQ   = 6'b000100;
localparam OP_ADDI  = 6'b001000;

always @(*) begin
  ctrl_regwrite = 0;
  ctrl_memread  = 0;
  ctrl_memwrite = 0;
  ctrl_memtoreg = 0;
  ctrl_alusrc   = 0;
  ctrl_branch   = 0;
  ctrl_regdst   = 0;
  ctrl_aluop    = 4'b0000;

  case (opcode)
    OP_RTYPE: begin
      ctrl_regwrite = 1;
      ctrl_regdst   = 1;
      case (funct)
        6'b100000: ctrl_aluop = 4'b0000; // ADD
        6'b100010: ctrl_aluop = 4'b0001; // SUB
        6'b100100: ctrl_aluop = 4'b0010; // AND
        6'b100101: ctrl_aluop = 4'b0011; // OR
        6'b101010: ctrl_aluop = 4'b0100; // SLT
        default:   ctrl_aluop = 4'b0000;
      endcase
    end

    OP_LW: begin
      ctrl_regwrite = 1;
      ctrl_memread  = 1;
      ctrl_memtoreg = 1;
      ctrl_alusrc   = 1;
    end

    OP_SW: begin
      ctrl_memwrite = 1;
      ctrl_alusrc   = 1;
    end

    OP_BEQ: begin
      ctrl_branch = 1;
      ctrl_aluop  = 4'b0001;
    end

    OP_ADDI: begin
      ctrl_regwrite = 1;
      ctrl_alusrc   = 1;
      ctrl_aluop    = 4'b0000;
    end
  endcase
end

endmodule
module branch_unit (
  input  wire [31:0] rs_data,
  input  wire [31:0] rt_data,
  input  wire is_branch,
  output wire taken
);

assign taken = is_branch && (rs_data == rt_data);

endmodule
module alu (
  input  wire [31:0] a,
  input  wire [31:0] b,
  input  wire [3:0]  alu_ctrl,
  output reg  [31:0] result,
  output wire zero
);

assign zero = (result == 32'd0);

always @(*) begin
  result = 32'd0;
  case (alu_ctrl)
    4'b0000: result = a + b;               // ADD
    4'b0001: result = a - b;               // SUB
    4'b0010: result = a & b;               // AND
    4'b0011: result = a | b;               // OR
    4'b0100: result = (a < b) ? 32'd1 : 0; // SLT
    default: result = 32'd0;
  endcase
end

endmodule
module wb_mux (
  input  wire [31:0] alu_result,
  input  wire [31:0] mem_data,
  input  wire memtoreg,
  output wire [31:0] wb_data
);

assign wb_data = memtoreg ? mem_data : alu_result;

endmodule
