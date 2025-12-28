`timescale 1ns/1ps

module cpu_tb;

  // Power rails FOR SKY130
  supply1 VPWR;
  supply1 VPB;
  supply0 VGND;
  supply0 VNB;

  reg clk;
  reg rst;

  // Debug wires from DUT
  wire [31:0] dbg_pc;
  wire [31:0] dbg_instr;
  wire [31:0] dbg_alu;
  wire [31:0] dbg_wb;
  wire [31:0] dbg_mem_addr;

  wire dbg_memread;
  wire dbg_memwrite;
  wire dbg_wb_we;

  // DUT
  cpu_top dut (
    .VGND(VGND),
    .VPWR(VPWR),
    .clk(clk),
    .rst(rst),

    .dbg_pc(dbg_pc),
    .dbg_instr(dbg_instr),
    .dbg_alu(dbg_alu),
    .dbg_wb(dbg_wb),
    .dbg_mem_addr(dbg_mem_addr),

    .dbg_memread(dbg_memread),
    .dbg_memwrite(dbg_memwrite),
    .dbg_wb_we(dbg_wb_we)
  );

  // Clock
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;

    #20;
    rst = 0;
    $display("RESET RELEASED");

    repeat (300) @(posedge clk);
    $display("SIM DONE");
    $finish;
  end

  // VCD dump
  initial begin
    $dumpfile("gls.vcd");
    $dumpvars(0,cpu_tb);
  end

endmodule
