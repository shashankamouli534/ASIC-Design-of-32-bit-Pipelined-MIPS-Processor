`timescale 1ns/1ps

module cpu_tb;

  logic clk;
  logic rst;

  // DUT
  cpu_top dut (
    .clk(clk),
    .rst(rst)
  );

  // Clock: 10 ns period
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;

    // Hold reset
    #20;
    rst = 0;


  end

initial begin
  wait (rst == 0);
  repeat (20) @(posedge clk);

  if (dut.RF.regs[2] !== 32'd10)
    $error("STAGE 2.3 FAIL: r2 = %0d (expected 10)", dut.RF.regs[2]);
  else
    $display("STAGE 2.3 PASS: Forwarding works (no stall)");
end



endmodule
