module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,nandi,baln,bgezal,jsp);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,nandi,baln,bgezal,jsp;
wire rformat,lw,sw,beq;
assign rformat=~|in; //000000
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];//100011
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];   //101011
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);//000100
assign regdest=rformat;
assign alusrc=lw|sw;
assign memtoreg=lw;
assign regwrite=rformat|lw|nandi|baln|bgezal;
assign memread=lw|rformat;
assign memwrite=sw;
assign branch=beq;
assign aluop1=rformat;
assign aluop2=beq;
assign nandi=(~in[5])& in[4]&(~in[3])&(~in[2])&(~in[1])&(~in[0]);//010000
assign baln=(~in[5])& in[4]&in[3]&(~in[2])& in[1]&in[0];//011011
assign bgezal=in[5]& (~in[4])&(~in[3])&(~in[2])& in[1]&in[0];//100011
assign jsp=(~in[5])& in[4]&(~in[3])&(~in[2])& in[1]&(~in[0]);//010010
endmodule
