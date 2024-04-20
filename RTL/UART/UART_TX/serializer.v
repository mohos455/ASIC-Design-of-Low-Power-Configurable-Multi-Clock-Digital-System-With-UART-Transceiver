module serializer (
    input clk , reset ,
    input [7:0] P_DATA ,
    input   Data_Valid, Busy,
    input ser_en ,
    output reg ser_data , ser_done
);


reg [2:0] counter ;
reg [7:0] DATA_reg ;

always @(posedge clk or negedge reset) begin
    if (~reset) begin
        DATA_reg<= 0 ;
    end
    else if (Data_Valid && ~Busy) begin
        DATA_reg <= P_DATA ;
    end
end 


always @(posedge clk or negedge reset)
 begin
 	if (!reset) begin
 		counter  <= 3'd0 ;
 		ser_data <= 1'd0 ;
 		ser_done <= 1'd0 ;
 	end
 	else if (ser_en == 1'd1) begin
 		if (counter != 3'd7) begin
 			counter  <= counter + 3'd1  ;
 			ser_data <= DATA_reg[counter] ;
 			ser_done <= 1'd0            ;
  		end
  		else begin
  			counter  <= 3'd0      ;
  			ser_data <= DATA_reg[7] ;
  			ser_done <= 1'd1      ;
  		end
 	end
 	else begin
 		counter  <= 3'd0 ;
 		ser_data <= 1'd0 ;
 		ser_done <= 1'd0 ;
 	end
 end

endmodule
