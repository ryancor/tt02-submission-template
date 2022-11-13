module alu(
	input [1:0] A,
	input [1:0] B,
	input [3:0] ALU_Sel,
	output [6:0] ALU_Out,
	output CarryOut
);

	reg [6:0] ALU_Result;
	wire [7:0] tmp;
	assign ALU_Out = ALU_Result;
	assign tmp = {1'b0, A} + {1'b0, B};
	assign CarryOut = tmp[7];

	always @(*) begin
		case(ALU_Sel)
			4'b0000:
				ALU_Result = A + B;
			4'b0001:
				ALU_Result = A - B;
			4'b0010:
				ALU_Result = A * B;
			4'b0011: // Division
				ALU_Result = A/B;
			4'b0100: // Logical shift left
				ALU_Result = A<<1;
			4'b0101: // Logical shift right
				ALU_Result = A>>1;
			4'b0110: // Rotate left
				ALU_Result = {A[1:0],A[1]};
			4'b0111: // Rotate right
				ALU_Result = {A[0],A[1:0]};
			4'b1000: //  Logical and
				ALU_Result = A & B;
			4'b1001: //  Logical or
				ALU_Result = A | B;
			4'b1010: //  Logical xor
				ALU_Result = A ^ B;
			4'b1011: //  Logical nor
				ALU_Result = ~(A | B);
			4'b1100: // Logical nand
				ALU_Result = ~(A & B);
			4'b1101: // Logical xnor
				ALU_Result = ~(A ^ B);
			4'b1110: // Greater comparison
				ALU_Result = (A>B)?1'b1:1'b0 ;
			4'b1111: // Equal comparison
				ALU_Result = (A==B)?1'b1:1'b0 ;
			default: ALU_Result = A + B;
		endcase
	end
endmodule
