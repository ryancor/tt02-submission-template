`default_nettype none

module cpu(
    input [4:0] INSTRUCTION,
    input       write_en,
    input       CLK, RESET,    
    output      PC
);

reg [4:0] accumulator;
reg [4:0] input_reg;

wire [5:0] sum;
	
reg isAdd;
wire [7:0] mux1out;
wire [7:0] minusVal;
reg [7:0] IN;
wire [7:0] OUT2;

assign sum = input_reg + accumulator;
assign PC = sum[5];

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin 
        input_reg <= 5'h00 ;
        accumulator <= 5'h00;
    end else begin
        accumulator <= sum[4:0];
	if (write_en) input_reg <= INSTRUCTION ;
    end
end

//multiplexer to choose between minus value and plus value
mux2_1 mymux1(OUT2, minusVal, isAdd, mux1out);
	
endmodule

module mux2_1(
        input [7:0] in0,
        input [7:0] in1,
        input se1,
        output [7:0] out
);

        reg out;

        always @(in0, in1, se1) begin
                if(se1 == 1'b1) begin
                        out = in0;
                end
                else begin
                        out = in1;
                end
        end
endmodule
