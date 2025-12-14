
module cpu_tb;

  logic clk = 0;
  logic rst;

  cpu_top DUT (.clk(clk), .rst(rst));

  always #5 clk = ~clk;

  initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0, DUT);

    rst = 1;
    #20 rst = 0;

    // === Instruction Memory Init ===
    DUT.IF.IMEM.mem[0] = 32'h20010005; // addi r1,r0,5
    DUT.IF.IMEM.mem[1] = 32'h20020007; // addi r2,r0,7
    DUT.IF.IMEM.mem[2] = 32'h00221820; // add r3,r1,r2

    // Run CPU
    repeat (20) @(posedge clk);

    // === Check Result ===
    if (DUT.RF.regs[3] == 32'd12)
      $display("✅ PASS: r3 = %0d", DUT.RF.regs[3]);
    else
      $display("❌ FAIL: r3 = %0d", DUT.RF.regs[3]);

    $finish;
  end

endmodule
