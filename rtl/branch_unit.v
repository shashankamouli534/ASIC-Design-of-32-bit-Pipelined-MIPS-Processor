module branch_unit (
  input  wire [31:0] rs_data,
  input  wire [31:0] rt_data,
  input  wire is_branch,
  output wire taken
);

assign taken = is_branch && (rs_data == rt_data);

endmodule
