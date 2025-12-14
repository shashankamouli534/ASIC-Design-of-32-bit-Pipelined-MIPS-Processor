module hazard_unit (
  input  wire       id_ex_memread,
  input  wire [4:0] id_ex_rt,
  input  wire [4:0] if_id_rs,
  input  wire [4:0] if_id_rt,
  output reg        stall
);

always @(*) begin
  stall = id_ex_memread &&
          (id_ex_rt != 0) &&
          ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt));
end

endmodule
