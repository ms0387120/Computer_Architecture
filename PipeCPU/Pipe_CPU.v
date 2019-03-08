`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/03
 * Design Name: 	Pipeline CPU
 * Module Name:		Pipe_CPU 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 
 * Please DO NOT change the module name, or your'll get ZERO point.
 * You should add your code here to complete the project 3.
 ******************************************************************/
module Pipe_CPU(
        clk_i,
		rst_i
		);
    
/****************************************
*            I/O ports                  *
****************************************/
input clk_i;
input rst_i;

/****************************************
*          Internal signal              *
****************************************/

/**** IF stage ****/
wire [31:0] pc_result;
wire [31:0] pc;
wire [31:0] pc_four=32'd4;
wire [31:0] pc_plus4;
wire [31:0] Instruction;



/**** ID stage ****/
wire [31:0] IF_ID_pc_plus4;
wire [31:0] IF_ID_Instruction;

wire [31:0] Reg_File_read1;
wire [31:0] Reg_File_read2;

wire ALUSrc;
wire [2:0]ALUOP;
wire RegDst;
wire branch;
wire MemWrite;
wire MemRead;
wire MemtoReg;
wire RegWrite;

wire [31:0] signimme;

/**** EX stage ****/
wire [4:0] mux_to_WriteReg;

wire ID_EX_ALUSrc;
wire [2:0] ID_EX_ALUOP;
wire ID_EX_RegDst;
wire ID_EX_branch;
wire ID_EX_MemWrite;
wire ID_EX_MemRead;
wire ID_EX_MemtoReg;
wire ID_EX_RegWrite;

wire [31:0] ID_EX_pc_plus4;
wire [31:0] ID_EX_Reg_read1;
wire [31:0] ID_EX_Reg_read2;
wire [5:0]  ID_EX_func;
wire [31:0] ID_EX_signimme;
wire [4:0]  ID_EX_RegisterRs;
wire [4:0]  ID_EX_RegisterRt;
wire [4:0]  ID_EX_RegisterRt_to_Forwarding; // extra
wire [4:0]  ID_EX_RegisterRd;

wire [31:0] Shift_Left_Two;
wire [31:0] pc_add_result;
wire [3:0]  ALUCtrl;

wire [1:0] ForwardA;
wire [1:0] ForwardB;

wire [31:0] EX_ALU01;
wire [31:0] EX_ALU02;
wire [31:0] EX_ALU03;
wire [31:0] ALU_result;
wire Zero;  

/**** MEM stage ****/
wire [4:0] EX_MEM_mux_to_WriteReg;
wire EX_MEM_MemtoReg;
wire EX_MEM_RegWrite;
wire EX_MEM_branch;
wire EX_MEM_MemWrite;
wire EX_MEM_MemRead;
wire [31:0] EX_MEM_pc_add_result;
wire EX_MEM_Zero;  
wire [31:0] EX_MEM_ALU_result;
wire [31:0] EX_MEM_ALU02;

wire [31:0] data_Mem_Readdata;

/**** WB stage ****/
wire [4:0] MEM_WB_mux_to_WriteReg;
wire [31:0] mux_to_Reg_File_Writedata;
wire MEM_WB_RegWrite;
wire MEM_WB_MemtoReg;
wire [31:0] MEM_WB_data_Mem_Readdata;
wire [31:0] MEM_WB_Addr;

/**** Data hazard ****/
//control signal...


/****************************************
*       Instantiate modules             *
****************************************/
//Instantiate the components in IF stage
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(pc_result) , 
	    .pc_out_o(pc)
        );

Instr_Memory IM(
        .pc_addr_i(pc), 
	    .instr_o(Instruction)
	    );
			
Adder Add_pc(
        .src1_i(pc),     
	    .src2_i(pc_four),      
	    .sum_o(pc_plus4)
		);

MUX_2to1 #(.size(32)) Mux1(
        .data0_i(pc_plus4),
        .data1_i(EX_MEM_pc_add_result),
        .select_i(EX_MEM_Zero&EX_MEM_branch),
        .data_o(pc_result)
        );
		
Pipe_Reg #(.size(32)) IF_ID_PC_PLUS4(       
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(pc_plus4),
		.data_o(IF_ID_pc_plus4)
		);
		
Pipe_Reg #(.size(32)) IF_ID_INSTR(       
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Instruction),
		.data_o(IF_ID_Instruction)
		);
//Instantiate the components in ID stage
Reg_File RF(
        .clk_i(clk_i),
	    .rst_i(rst_i),
        .RSaddr_i(Instruction[25:21]),
        .RTaddr_i(Instruction[20:16]),
        .RDaddr_i(MEM_WB_mux_to_WriteReg),
        .RDdata_i(mux_to_Reg_File_Writedata),
        .RegWrite_i(MEM_WB_RegWrite),
        .RSdata_o(Reg_File_read1),
        .RTdata_o(Reg_File_read2)
		);

Decoder Control(
        .instr_op_i(Instruction[31:26]), 
	    .RegWrite_o(RegWrite), 
	    .ALU_op_o(ALUOP),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),   
		.Branch_o(branch), 
		.MemWrite_o(MemWrite),
		.MemRead_o(MemRead),
		.MemtoReg_o(MemtoReg)
		);

Sign_Extend Sign_Extend(
        .data_i(Instruction[15:0]),
        .data_o(signimme)
		);	

Pipe_Reg #(.size(1)) ID_EX_ALUSRC( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(ALUSrc),
		.data_o(ID_EX_ALUSrc)
		);
		
Pipe_Reg #(.size(3)) ID_EX_ALUOp( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(ALUOP),
		.data_o(ID_EX_ALUOP)
		);
		
Pipe_Reg #(.size(1)) ID_EX_REGDST( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(RegDst),
		.data_o(ID_EX_RegDst)
		);
		
Pipe_Reg #(.size(1)) ID_EX_BRANCH( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(branch),
		.data_o(ID_EX_branch)
		);
		
Pipe_Reg #(.size(1)) ID_EX_MEMWRITE( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(MemWrite),
		.data_o(ID_EX_MemWrite)
		);

Pipe_Reg #(.size(1)) ID_EX_MEMREAD( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(MemRead),
		.data_o(ID_EX_MemRead)
		);

Pipe_Reg #(.size(1)) ID_EX_MEMTOREG( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(MemtoReg),
		.data_o(ID_EX_MemtoReg)
		);
		
Pipe_Reg #(.size(1)) ID_EX_REGWRITE( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(RegWrite),
		.data_o(ID_EX_RegWrite)
		);
		
Pipe_Reg #(.size(32)) ID_EX_PC_PLUS4( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(IF_ID_pc_plus4),
		.data_o(ID_EX_pc_plus4)
		);
		
Pipe_Reg #(.size(32)) ID_EX_REG_READ1( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Reg_File_read1),
		.data_o(ID_EX_Reg_read1)
		);
		
Pipe_Reg #(.size(32)) ID_EX_REG_READ2( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Reg_File_read2),
		.data_o(ID_EX_Reg_read2)
		);

Pipe_Reg #(.size(32)) ID_EX_SIGNIMME( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(signimme),
		.data_o(ID_EX_signimme)
		);
		
Pipe_Reg #(.size(6)) ID_EX_FUNCTION( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Instruction[5:0]),
		.data_o(ID_EX_func)
		);
		
Pipe_Reg #(.size(5)) ID_EX_REGISTERRS( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Instruction[25:21]),
		.data_o(ID_EX_RegisterRs)
		);
		
Pipe_Reg #(.size(5)) ID_EX_REGISTERRT( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Instruction[20:16]),
		.data_o(ID_EX_RegisterRt)
		);

Pipe_Reg #(.size(5)) ID_EX_REGISTERRT_TO_FORWARD( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Instruction[20:16]),
		.data_o(ID_EX_RegisterRt_to_Forwarding)
		);
		
Pipe_Reg #(.size(5)) ID_EX_REGISTERRD( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Instruction[15:11]),
		.data_o(ID_EX_RegisterRd)
		);
		
//Instantiate the components in EX stage
MUX_2to1 #(.size(5)) Mux2(
        .data0_i(ID_EX_RegisterRt),
        .data1_i(ID_EX_RegisterRd),
        .select_i(ID_EX_RegDst),
        .data_o(mux_to_WriteReg)
        );

ForwardinUnit Forwarding( 
        .EX_MEMRegWrite(EX_MEM_RegWrite),
        .MEM_WBRegWrite(MEM_WB_RegWrite),
        .EX_MEMRegisterRd(EX_MEM_mux_to_WriteReg),
        .MEM_WBRegisterRd(MEM_WB_mux_to_WriteReg),
        .ID_EXRegisterRs(ID_EX_RegisterRs),
        .ID_EXRegisterRt(ID_EX_RegisterRt_to_Forwarding),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
   );
		
MUX_3to1 #(.size(32)) Mux3(
        .data0_i(ID_EX_Reg_read1),
        .data1_i(mux_to_Reg_File_Writedata),
	    .data2_i(EX_MEM_ALU_result),
        .select_i(ForwardA),
        .data_o(EX_ALU01)
        );

MUX_3to1 #(.size(32)) Mux4(
        .data0_i(ID_EX_Reg_read2),
        .data1_i(mux_to_Reg_File_Writedata),
	    .data2_i(EX_MEM_ALU_result),
        .select_i(ForwardB),
        .data_o(EX_ALU02)
        );

MUX_2to1 #(.size(32)) Mux5(
        .data0_i(EX_ALU02),
        .data1_i(ID_EX_signimme),
        .select_i(ID_EX_ALUSrc),
        .data_o(EX_ALU03)
        );
		
ALU_Ctrl ALU_Control(
        .funct_i(ID_EX_func),   
        .ALUOp_i(ID_EX_ALUOP),   
        .ALUCtrl_o(ALUCtrl)
		);

ALU ALU(
        .src1_i(EX_ALU01),
	    .src2_i(EX_ALU03),
	    .ctrl_i(ALUCtrl),
	    .result_o(ALU_result),
		.zero_o(Zero)
		);
		
Shift_Left_Two_32 Shifter(
        .data_i(ID_EX_signimme),
        .data_o(Shift_Left_Two)
        );
	
Adder Adder2(
        .src1_i(ID_EX_pc_plus4),    
	    .src2_i(Shift_Left_Two),     
	    .sum_o(pc_add_result)      
	    );

Pipe_Reg #(.size(1)) EX_MEM_BRANCH( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(ID_EX_branch),
		.data_o(EX_MEM_branch)
		);
		
Pipe_Reg #(.size(1)) EX_MEM_MEMWRITE( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(ID_EX_MemWrite),
		.data_o(EX_MEM_MemWrite)
		);

Pipe_Reg #(.size(1)) EX_MEM_MEMREAD( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(ID_EX_MemRead),
		.data_o(EX_MEM_MemRead)
		);

Pipe_Reg #(.size(1)) EX_MEM_MEMTOREG( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(ID_EX_MemtoReg),
		.data_o(EX_MEM_MemtoReg)
		);
		
Pipe_Reg #(.size(1)) EX_MEM_REGWRITE( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(ID_EX_RegWrite),
		.data_o(EX_MEM_RegWrite)
		);
Pipe_Reg #(.size(1)) EX_MEM_ZERO( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(Zero),
		.data_o(EX_MEM_Zero)
		);

Pipe_Reg #(.size(32)) EX_MEM_ALU_RESULT( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(ALU_result),
		.data_o(EX_MEM_ALU_result)
		);		

Pipe_Reg #(.size(32)) EX_MEM_ALU( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(EX_ALU02),
		.data_o(EX_MEM_ALU02)
		);

Pipe_Reg #(.size(5)) EX_MEM_MUX_TO_WritReg( 
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(mux_to_WriteReg),
		.data_o(EX_MEM_mux_to_WriteReg)
		);


//Instantiate the components in MEM stage
Data_Memory DM(
        .clk_i(clk_i),
		.rst_i(rst_i),
		.addr_i(EX_MEM_ALU_result),
		.data_i(EX_MEM_ALU02),
		.MemRead_i(EX_MEM_MemRead),
		.MemWrite_i(EX_MEM_MemWrite),
		.data_o(data_Mem_Readdata)
	    );
		
Pipe_Reg #(.size(1)) MEM_WB_REGWRITE(
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(EX_MEM_RegWrite),
		.data_o(MEM_WB_RegWrite)
		);
		
Pipe_Reg #(.size(1)) MEM_WB_MEMTOREG(
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(EX_MEM_MemtoReg),
		.data_o(MEM_WB_MemtoReg)
		);

Pipe_Reg #(.size(32)) MEM_WB_READDATA(
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(data_Mem_Readdata),
		.data_o(MEM_WB_data_Mem_Readdata)
		);
		
Pipe_Reg #(.size(32)) MEM_WB_ALU_RESULT(
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(EX_MEM_ALU_result),
		.data_o(MEM_WB_Addr)
		);

Pipe_Reg #(.size(5)) MEM_WB_MUX_TO_WritReg(
        .rst_i(rst_i),
		.clk_i(clk_i),   
		.data_i(EX_MEM_mux_to_WriteReg),
		.data_o(MEM_WB_mux_to_WriteReg)
		);
		
//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux6(
        .data0_i(MEM_WB_Addr),
        .data1_i(MEM_WB_data_Mem_Readdata),
        .select_i(MEM_WB_MemtoReg),
        .data_o(mux_to_Reg_File_Writedata)
        );
		


/****************************************
*         Signal assignment             *
****************************************/
	
endmodule

