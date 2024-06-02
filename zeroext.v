module zeroext(in1,out1);
input [15:0] in1;
output [31:0] out1;
assign 	 out1 = {16'h0, in1};
endmodule
