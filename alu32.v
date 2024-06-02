module alu32(sum,a,b,clk,zout,gin,flag);//ALU operation according to the ALU control line values
output [31:0] sum;
input [31:0] a,b; 
input [2:0] gin;//ALU control line
input clk;
reg [31:0] sum;
reg [31:0] less;
output zout;
output flag; //EXTRA
reg overflow;
reg [2:0] flag; //0 zero, 1 negative, 2 overflow //EXTRA
reg zout;
always @(a or b or gin)
begin
	case(gin)
	3'b010: begin sum=a+b;  //ALU control line=010, ADD
			if ((a[31] && b[31] && ~sum[31]) || (~a[31] && ~b[31] && sum[31])) overflow = 1'b1; //EXTRA
			else overflow = 1'b0;
		end
	3'b110: begin sum=a+1+(~b);	//ALU control line=110, SUB
			if ((~a[31] && b[31] && sum[31]) || (a[31] && ~b[31] && ~sum[31])) overflow = 1'b1; //EXTRA
			else overflow = 1'b0;
		end
	3'b111: begin less=a+1+(~b);	//ALU control line=111, set on less than
			if (less[31]) sum=1;	
			else sum=0;
		  end
	3'b000: sum=a & b;	//ALU control line=000, AND
	3'b001: sum=a|b;		//ALU control line=001, OR
	3'b011: sum=a;         //ALU control line=011, balrv,bgezal and jsp//EXTRA
	3'b100: sum=~(a & b);  //ALU control line =100, nandi //EXTRA
	3'b101: sum=a^b;         //ALU control line =101, jmxor //EXTRA
	default: sum=32'bx;	
	endcase
zout=~(|sum);
end
always @(posedge clk) //EXTRA
begin
	if (sum == 1'd0) flag[0] = 1'b1;
	else flag[0] = 1'b0;
	if (sum[31]) flag[1] = 1'b1;
	else flag[1] = 1'b0;
	if (overflow == 1'b1) flag[2] = 1'b1;
	else flag[2] = 1'b0;
end
endmodule
