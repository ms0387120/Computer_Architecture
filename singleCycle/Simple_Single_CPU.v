`timescale 1ns / 1ps
//Subject:     Architecture project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: Structure for R-type
//--------------------------------------------------------------------------------

module Simple_Single_CPU(
    clk_i,
	rst_i
);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signals
wire [31:0] pc;
wire [31:0] pc_four = 32'd4;

wire [31:0] pc_plus4;

wire [31:0] Instruction;

wire RegDst;
wire branch;
wire MemRead;
wire MemtoReg;
wire [2:0]ALUOp;
wire MemWrite;
wire ALUSrc;
wire ctrl_register_write_w;

wire [4:0]Reg_File_WriteReg;
wire [31:0]Reg_File_read1;
wire [31:0]Reg_File_read2;
wire [31:0]Reg_File_WriteData;

wire [31:0]signimme;

wire [31:0]Mux_to_ALU;

wire [3:0]ALUCtrl;
wire [31:0]ALU_Result;
wire Zero;

wire [31:0]Shift_Left_Two;
wire [31:0]ALU_Result_to_Mux;

wire [31:0]Data_Mem_ReadData;
wire [32-1:0] mux_dataMem_result_w;

wire [31:0]pc_result;
	    

//Create components
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(pc_result) , 
	    .pc_out_o(pc)
	    );
	
Adder Adder1(
        .src1_i(pc),     
	    .src2_i(pc_four),      
	    .sum_o(pc_plus4)      
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc), 
	    .instr_o(Instruction)    
	    );

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(Instruction[20:16]),
        .data1_i(Instruction[15:11]),
        .select_i(RegDst),
        .data_o(Reg_File_WriteReg)
        );	

//DO NOT MODIFY	.RDdata_i && .RegWrite_i
Reg_File RF(
        .clk_i(clk_i),
		.rst_i(rst_i),
		.RSaddr_i(Instruction[25:21]) ,
		.RTaddr_i(Instruction[20:16]) ,
		.RDaddr_i(Reg_File_WriteReg) ,
		.RDdata_i(mux_dataMem_result_w[31:0]),
		.RegWrite_i(ctrl_register_write_w),
		.RSdata_o(Reg_File_read1) ,
		.RTdata_o(Reg_File_read2)
        );
	
//DO NOT MODIFY	.RegWrite_o
Decoder Decoder(
        .instr_op_i(Instruction[31:26]), 
	    .RegWrite_o(ctrl_register_write_w), 
	    .ALU_op_o(ALUOp),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),   
		.Branch_o(branch), 
		.MemWrite_o(MemWrite),
		.MemRead_o(MemRead),
		.MemtoReg_o(MemtoReg)
	    );

ALU_Ctrl AC(
        .funct_i(Instruction[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALUCtrl_o(ALUCtrl) 
        );
	
Sign_Extend SE(
        .data_i(Instruction[15:0]),
        .data_o(signimme)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(Reg_File_read2),
        .data1_i(signimme),
        .select_i(ALUSrc),
        .data_o(Mux_to_ALU)
        );	
		
ALU ALU(
        .src1_i(Reg_File_read1),
	    .src2_i(Mux_to_ALU),
	    .ctrl_i(ALUCtrl),
	    .result_o(ALU_Result),
		.zero_o(Zero)
	    );

		
Shift_Left_Two_32 Shifter(
        .data_i(signimme),
        .data_o(Shift_Left_Two)
        );
				
Adder Adder2(
        .src1_i(pc_plus4),    
	    .src2_i(Shift_Left_Two),     
	    .sum_o(ALU_Result_to_Mux)      
	    );
		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(pc_plus4), 
        .data1_i(ALU_Result_to_Mux),
        .select_i(branch&Zero),
        .data_o(pc_result) 
        );	
		
Data_Memory DataMemory(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.addr_i(ALU_Result),
		.data_i(Reg_File_read2),
		.MemRead_i(MemRead),
		.MemWrite_i(MemWrite),
		.data_o(Data_Mem_ReadData)
		);

//DO NOT MODIFY	.data_o
 MUX_2to1 #(.size(32)) Mux_DataMem_Read(
        .data0_i(ALU_Result),
        .data1_i(Data_Mem_ReadData),
        .select_i(MemtoReg),
        .data_o(mux_dataMem_result_w)
		);

endmodule