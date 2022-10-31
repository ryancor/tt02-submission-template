module cpu(
        output [31:0] PC,
        input [31:0] INSTRUCTION,
        input CLK,
        input RESET
);

        reg [31:0] PC;
        wire [31:0] PCRESULT;

        reg writeEnable;
        reg isAdd;
        reg isImediate;
        reg [2:0] aluOp;
        reg [2:0] regRead1Address;
        reg [2:0] regRead2Address;
        reg [2:0] writeRegAddress;
        reg [7:0] immediateVal;
        wire [7:0] mux1out;
        wire [7:0] mux2out;
        wire [7:0] ALURESULT;
        wire [7:0] minusVal;

        reg [7:0] IN;
        wire [7:0] OUT1;
        wire [7:0] OUT2;

        reg [7:0] OPCODE;
        reg [2:0] DESTINATION;
        reg [2:0] SOURCE1;
        reg [2:0] SOURCE2;

        always @(RESET) begin
                if(RESET == 1) begin
                        PC =- 4;
								end
        end

        // adder to update pc from 4
        adder myadder(PC, PCRESULT);
        always @(posedge CLK) begin
                PC = PCRESULT;
        end

        always @(INSTRUCTION) begin
                OPCODE = INSTRUCTION[31:24];
                case (OPCODE)
                        8'b00000000: begin
                                writeEnable = 1'b1;
                                aluOp = 3'b000;
                                isAdd = 1'b1;
                                isImediate = 1'b1;
                        end
                        8'b00000001: begin
                                writeEnable = 1'b1;
                                aluOp = 3'b000;
                                isAdd = 1'b1;
                                isImediate = 1'b0;
                        end
                        8'b00000010: begin
                                writeEnable = 1'b1;
                                aluOp = 3'b001;
                                isAdd = 1'b1;
                                isImediate = 1'b0;
                        end
                endcase
        end

        // Add reg


        always @(INSTRUCTION) begin
                DESTINATION = INSTRUCTION[18:16];
                SOURCE1   = INSTRUCTION[10:8];
                SOURCE2 = INSTRUCTION[2:0];
                immediateVal = INSTRUCTION[7:0];
        end

        // add compliment


        //multiplexer to choose between minus value and plus value
        mux2_1 mymux1(OUT2, minusVal, isAdd, mux1out);

        //multiplexer to chose between immediate value and mux1 output
        mux2_1 mymux2(immediateVal, mux1out, isImediate, mux2out);

        // Add ALU


        always @(ALURESULT) begin
                IN = ALURESULT;
        end

endmodule

module adder(
        input [31:0] PCINPUT,
        output [31:0] RESULT
);

        reg RESULT;

        always @(PCINPUT) begin
                RESULT = PCINPUT + 4;
        end
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
