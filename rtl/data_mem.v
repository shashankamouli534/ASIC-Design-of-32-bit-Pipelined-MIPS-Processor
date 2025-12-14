module data_mem (
  input  wire clk,
  input  wire memread,
  input  wire memwrite,
  input  wire [31:0] addr,
  input  wire [31:0] write_data,
  output reg  [31:0] read_data
);

reg [31:0] mem [0:1023];

always @(posedge clk) begin
  if (memwrite)
    mem[addr[11:2]] <= write_data;

  if (memread)
    read_data <= mem[addr[11:2]];
end

endmodule
