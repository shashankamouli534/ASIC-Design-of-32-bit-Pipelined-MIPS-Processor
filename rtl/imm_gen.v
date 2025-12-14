module imm_gen (
  input  wire [31:0] instr,
  output reg  [31:0] imm
);

wire [5:0] opcode = instr[31:26];

always @(*) begin
  case (opcode)
    6'b001000,
    6'b100011,
    6'b101011:
      imm = {{16{instr[15]}}, instr[15:0]};

    6'b000100:
      imm = {{14{instr[15]}}, instr[15:0], 2'b00};

    default:
      imm = 32'd0;
  endcase
end

endmodule
