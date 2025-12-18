`timescale 1ns/1ps
module cpu_tb;

  logic clk;
  logic rst;
logic [31:0] pc_prev;

  cpu_top dut (
    .clk(clk),
    .rst(rst)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;
    #500 $finish;
  end


always @(posedge clk) begin
  if (!rst)
    assert (dut.if_pc[1:0] == 2'b00)
      else $error("ASSERTION FAIL: PC not word-aligned");
end

always @(posedge clk) begin
  if (!rst)
    assert (dut.RF.regs[0] == 32'd0)
      else $error("ASSERTION FAIL: Register x0 modified");
end

always @(posedge clk) begin
  if (!rst)
    assert (!(dut.mem_memread && dut.mem_memwrite))
      else $error("ASSERTION FAIL: memread & memwrite both high");
end

always @(posedge clk) begin
  if (!rst && dut.ex_memread &&
     ((dut.ex_rt == dut.id_rs) || (dut.ex_rt == dut.id_rt)))
    assert (dut.if_stall)
      else $error("ASSERTION FAIL: Load-use hazard without stall");
end

always @(posedge clk) begin
  if (!rst && dut.if_stall)
    assert (dut.if_pc == pc_prev || dut.if_pc == pc_prev + 32'd4)
      else $error("ASSERTION FAIL: PC advanced incorrectly during stall");
  pc_prev <= dut.if_pc;
end


always @(posedge clk) begin
  if (!rst)
    assert (!((dut.fwd_a != 2'b00 && dut.ex_rs == 0) ||
              (dut.fwd_b != 2'b00 && dut.ex_rt == 0)))
      else $error("ASSERTION FAIL: Forwarding from x0");
end

always @(posedge clk) begin
  if (!rst)
    assert (dut.RF.regs[0] == 32'd0)
      else $error("ASSERTION FAIL: x0 register corrupted");
end


endmodule
