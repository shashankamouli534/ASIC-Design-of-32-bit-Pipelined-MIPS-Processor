module wb_mux (
  input  wire [31:0] alu_result,
  input  wire [31:0] mem_data,
  input  wire memtoreg,
  output wire [31:0] wb_data
);

assign wb_data = memtoreg ? mem_data : alu_result;

endmodule
