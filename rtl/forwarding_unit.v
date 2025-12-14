module forwarding_unit (
  input  wire       ex_mem_regwrite,
  input  wire       mem_wb_regwrite,
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

  if (ex_mem_regwrite && ex_mem_rd && ex_mem_rd == id_ex_rs)
    forward_a = 2'b10;
  else if (mem_wb_regwrite && mem_wb_rd && mem_wb_rd == id_ex_rs)
    forward_a = 2'b01;

  if (ex_mem_regwrite && ex_mem_rd && ex_mem_rd == id_ex_rt)
    forward_b = 2'b10;
  else if (mem_wb_regwrite && mem_wb_rd && mem_wb_rd == id_ex_rt)
    forward_b = 2'b01;
end

endmodule
