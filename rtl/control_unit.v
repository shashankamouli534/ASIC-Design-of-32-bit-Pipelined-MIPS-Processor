module control_unit (
  input  wire [5:0] opcode,

  output reg ctrl_regwrite,
  output reg ctrl_memread,
  output reg ctrl_memwrite,
  output reg ctrl_memtoreg,
  output reg ctrl_alusrc,
  output reg ctrl_branch,
  output reg ctrl_regdst,
  output reg [3:0] ctrl_aluop
);

localparam OP_RTYPE = 6'b000000;
localparam OP_LW    = 6'b100011;
localparam OP_SW    = 6'b101011;
localparam OP_BEQ   = 6'b000100;
localparam OP_ADDI  = 6'b001000;

always @(*) begin
  ctrl_regwrite = 0;
  ctrl_memread  = 0;
  ctrl_memwrite = 0;
  ctrl_memtoreg = 0;
  ctrl_alusrc   = 0;
  ctrl_branch   = 0;
  ctrl_regdst   = 0;
  ctrl_aluop    = 4'b0000;

  case (opcode)
    OP_RTYPE: begin
      ctrl_regwrite = 1;
      ctrl_regdst   = 1;     // rd
      ctrl_aluop    = 4'b0010;
    end

    OP_LW: begin
      ctrl_regwrite = 1;
      ctrl_memread  = 1;
      ctrl_memtoreg = 1;
      ctrl_alusrc   = 1;
    end

    OP_SW: begin
      ctrl_memwrite = 1;
      ctrl_alusrc   = 1;
    end

    OP_BEQ: begin
      ctrl_branch = 1;
      ctrl_aluop  = 4'b0001;
    end

    OP_ADDI: begin
      ctrl_regwrite = 1;
      ctrl_alusrc   = 1;
    end
  endcase
end

endmodule
