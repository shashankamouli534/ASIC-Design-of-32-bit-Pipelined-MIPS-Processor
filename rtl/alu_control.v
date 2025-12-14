module alu_control (
  input  wire [3:0] alu_op,
  input  wire [5:0] funct,
  output reg  [3:0] alu_ctrl
);

always @(*) begin
  alu_ctrl = 4'b0000;

  case (alu_op)
    4'b0000: alu_ctrl = 4'b0000; // ADD (lw/sw/addi)
    4'b0001: alu_ctrl = 4'b0001; // SUB (beq)
    4'b0010: begin               // R-type
      case (funct)
        6'b100000: alu_ctrl = 4'b0000; // add
        6'b100010: alu_ctrl = 4'b0001; // sub
        6'b100100: alu_ctrl = 4'b0010; // and
        6'b100101: alu_ctrl = 4'b0011; // or
        6'b101010: alu_ctrl = 4'b0100; // slt
        default:   alu_ctrl = 4'b0000;
      endcase
    end
    default: alu_ctrl = 4'b0000;
  endcase
end

endmodule
