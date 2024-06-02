module alucont(aluop1,aluop0,f3,f2,f1,f0,gout);//Figure 4.12 
input aluop1,aluop0,f3,f2,f1,f0;
output [2:0] gout;
reg [2:0] gout;
always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
if(~(aluop1|aluop0))  gout=3'b010;
if(aluop0)gout=3'b110;
if(aluop1)//R-type
begin
	if (~(f3|f2|f1|f0))gout=3'b010; 	 //function code=0000,ALU control=010 (add)
	if (f0&f1&f2&f3)gout=3'b111;		 //function code=1111,ALU control=111 (set on less than)
	if (~(f3) & ~(f2) & ~(f1) & f0)gout=3'b110;	//function code=0001,ALU control=110 (sub)
	if (~(f3) & f2 & ~(f1) & f0)gout=3'b001;	 //function code=0101,ALU control=001 (or)
	if (~(f3) & (f2) & ~(f1) & ~(f0))gout=3'b000;	//function code=0100,ALU control=000 (and)
	if (~(f3) & f2 & f1 & ~(f0))gout=3'b011; //function code=0110,ALU control=011 (balrv) //EXTRA	
	if (~(f3) & ~(f2) & f1 & ~(f0)) gout=3'b101;  //function code=0010,ALU control=101 (jmxor) //EXTRA	
end
end
endmodule