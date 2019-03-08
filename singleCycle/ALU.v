//Subject:     Architecture project 2 - ALU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
//I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;

//Internal signals
reg    [32-1:0]  result_o;
reg             zero_o;

//Parameter

//Main function
always@(src1_i or src2_i or ctrl_i) begin
  
  if(ctrl_i==4'b0000)begin //AND
     result_o = src1_i & src2_i;
	 if(result_o==32'h0000)begin
	    zero_o = 1'b1;
	 end 
	 else begin
	    zero_o = 1'b0;
	 end
  end

  if(ctrl_i==4'b0001)begin //OR
     result_o = src1_i | src2_i;
	 if(result_o==32'h0000)begin
	    zero_o = 1'b1;
	 end 
	 else begin
	    zero_o = 1'b0;
	 end
  end
  
  if(ctrl_i==4'b0010)begin //ADD
     result_o = src1_i + src2_i;
	 if(result_o==32'h0000)begin
	    zero_o = 1'b1;
	 end 
	 else begin
	    zero_o = 1'b0;
	 end
  end
  
  if(ctrl_i==4'b0110)begin //SUB
     result_o = src1_i - src2_i;
	 if(result_o==32'h0000)begin
	    zero_o = 1'b1;
	 end 
	 else begin
	    zero_o = 1'b0;
	 end
  end
  
  if(ctrl_i==4'b0111)begin //SLT
     if(src1_i[31] != src2_i[31])begin //+- -+
	    if(src1_i[31] > src2_i[31])begin
		   result_o = 1;
		end
		else begin
		   result_o = 0;
		end 
	 end
	 else begin //++ --
	    if(src1_i < src2_i)begin 
		   result_o = 1;
		end 
		else begin 
		   result_o = 0;
		end 
	 end 
	 
	 
	 if(result_o==32'h0000)begin
	    zero_o = 1'b1;
	 end 
	 else begin
	    zero_o = 1'b0;
	 end
  end
  
end 
endmodule