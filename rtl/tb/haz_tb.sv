`timescale 1ns/1ps

module cpu_tb;

  logic clk;
  logic rst;

  // DUT
  cpu_top dut (
    .clk(clk),
    .rst(rst)
  );

  //10 ns
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;


    #20;
    rst = 0;


  end

initial begin
  wait (rst == 0);
  repeat (30) @(posedge clk);

  if (dut.RF.regs[2] !== 32'd14)
    $error("STAGE 2.4 FAIL: r2 = %0d (expected 14)", dut.RF.regs[2]);
  else
    $display("STAGE 2.4 PASS: Load-use hazard handled with stall");
end




endmodule
