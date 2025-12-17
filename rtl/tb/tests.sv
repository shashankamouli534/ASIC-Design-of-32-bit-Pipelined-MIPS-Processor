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

    // Run for some cycles
    repeat (50) @(posedge clk);

    $display("TB bring-up completed");
    $finish;
  end

initial begin
  wait (rst == 0);
  repeat (25) @(posedge clk);

  if (dut.RF.regs[1] !== 32'd5)
    $error("STAGE 2.2 FAIL: r1 = %0d (expected 5)", dut.RF.regs[1]);

  if (dut.RF.regs[2] !== 32'd10)
    $error("STAGE 2.2 FAIL: r2 = %0d (expected 10)", dut.RF.regs[2]);

  if (dut.RF.regs[3] !== 32'd15)
    $error("STAGE 2.2 FAIL: r3 = %0d (expected 15)", dut.RF.regs[3]);

  else
    $display("STAGE 2.2 PASS: ADD / ADDI working");

end

endmodule
