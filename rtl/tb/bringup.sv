`timescale 1ns/1ps

module cpu_tb;

  logic clk;
  logic rst;

  // DUT
  cpu_top dut (
    .clk(clk),
    .rst(rst)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;

    // Hold reset
    #20;
    rst = 0;

    // Run
    repeat (50) @(posedge clk);

    $display("TB bring-up completed");
    $finish;
  end



endmodule
