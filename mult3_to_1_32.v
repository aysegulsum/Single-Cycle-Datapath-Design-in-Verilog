module mult3_to_1_32(out, i0,i1,i2,s0,s1);
output reg [31:0] out;
input [31:0] i0,i1,i2;
input s0,s1;
always @* begin
    if(s1 == 1 && s0 == 0) 
        out = i2;
    else if(s1 == 0 && s0 == 1) 
        out = i1;
    else if(s0 == 0) 
        out = i0;
end
endmodule