module serializer (
    input clk , reset ,
    input [7:0] P_DATA ,
    //input Data_Valid ,
    input ser_en ,
    output reg ser_data , ser_done
);


reg [2:0] counter ;

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
 			ser_data <= P_DATA[counter] ;
 			ser_done <= 1'd0            ;
  		end
  		else begin
  			counter  <= 3'd0      ;
  			ser_data <= P_DATA[7] ;
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
/*
    reg [7:0] MyData ;
    reg bit_out ;
    reg [2:0] counter_reg , counter_next ;

    always @(posedge clk or negedge reset) begin
        if(~reset) begin
            MyData <=0 ;
            counter_reg <=0;
            counter_next <= 0;
            ser_data <=0 ;
            bit_out <=0;
            ser_done <=0 ;
        end
        else if(Data_Valid && !ser_en) begin
            MyData <= P_DATA ;
        end
        else if (ser_en && counter_reg != 7) begin
            counter_reg <= counter_reg + 1 ;
            ser_data <= MyData[counter_reg] ;
        end
        else if (counter_reg == 7) begin
            ser_done <= 1 ;
        end
    end

    
endmodule */

