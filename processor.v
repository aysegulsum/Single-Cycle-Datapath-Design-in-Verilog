module processor;
reg [31:0] pc,pcStore; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [25:0] jumpReg; //
wire [27:0] jumpExt; //EXTRA
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
out5,           //Output for mux with PC+4 memtoReg //EXTRA
out6,		//EXTRA
out8,
out9,
jumpOut,
jumpAddress,
sum,		//ALU result//
extad,	//Output of sign-extend unit
zextad,  //Output of zero-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad;	//Output of shift left 2 unit

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1,out2;		//Write data input of Register File EXTRA out2

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout,out7;	//Output of ALU control unit

wire [2:0] flag;     //Output for Z N V flags // EXTRA

wire zout,	//Zero output of ALU

pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
jmxor,  
//Control signals
nandi,baln, balnAndNeg, bgezal,bgezalAndNeg,jsp,//EXTRA signals 
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

//jump
assign jumpReg = instruc[25:0];
assign jmxor= (instruc[5:0] == 6'b100010) ? 1'b1 : 1'b0;

integer i;
// datamemory connections
always @(posedge clk)
//write data to memory
if (memwrite)
begin //
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];


// registers

assign dataa=jsp ? registerfile[5'b11101] : registerfile[inst25_21];//Read register 1
assign datab=jsp ? registerfile[5'b00000] : registerfile[inst20_16];//Read register 2
always @(posedge clk)
 registerfile[out2]= regwrite ? out5:registerfile[out2];//Write data to register

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};
//
//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);
//mux for baln write reg 31
mult3_to_1_5 mult2(out2, out1, 5'b11111, 5'b11001, baln || jmxor,bgezal);

//mux with ALUSrc control
//mux zeroext EXTRA
mult3_to_1_32 mult4(out8, datab,extad,zextad,alusrc,nandi);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult7(out4, pcStore,adder2out,pcsrc);

//mux with jsp out3 readed data from memory EXTRA

mult2_to_1_32 mult6(jumpOut,out4,jumpAddress,balnAndNeg);
mult3_to_1_32 mult9(out9, jumpOut,sum,dpack,flag[2] || jsp, jmxor); //EXTRA

// mux with memData PC+4
mult2_to_1_32 mult5(out5, out3, pcStore,flag[2] || baln || bgezal || jmxor);  //EXTRA !!!

//mux with aluop and nandi EXTRA
mult3_to_1_32 mult8(out7, gout, 3'b100, 3'b011, nandi, jsp || bgezal);  //EXTRA
 
//baln and operation
assign balnAndNeg = baln && flag[1];
//bgezal and operation
assign bgezalAndNeg = bgezal && (~flag[1]);

always @(posedge clk)
pcStore = adder1out;
// load pc
always @(negedge clk)begin
//pcStore = pc;
pc=out9;
end
// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out8,clk,zout,out7,flag);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(pcStore,sextad,adder2out);


//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,nandi,baln,bgezal,jsp);

//Sign extend unit
signext sext(instruc[15:0],extad);

//Zero extend unit EXTRA
zeroext zext(instruc[15:0],zextad);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout);

//Shift-left 2 unit
shift shift2(sextad,extad);

//Shift-left 2 unit for jump EXTRA
shift shiftJump(jumpExt,jumpReg);

//jump address EXTRA
assign jumpAddress[31:28] = pcStore[31:28];
assign jumpAddress[27:0] = jumpExt[27:0];

//OR gate for branches EXTRA updated
assign pcsrc=(branch && zout) || balnAndNeg || bgezalAndNeg; 

//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=1;
#400 $finish;
	
end
initial
begin
clk=0;
//#40 time unit for each cycle
#8000  clk=~clk;
#8000  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule

