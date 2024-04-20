module Parity_CAL (
    input clk ,reset ,
    input [7:0] P_DATA ,
    input Data_Valid ,Busy,
    input PAR_TYP ,
    output reg PAR_bit
);



reg PAR_out_reg ;
reg [7:0] DATA_reg ;
always @(posedge clk or negedge reset) begin
    if (~reset) begin
        DATA_reg<= 0 ;
    end
    else if (Data_Valid && ~Busy) begin
        DATA_reg <= P_DATA ;
    end
end 

always @(posedge clk , negedge reset) begin
    if(~reset) begin
        PAR_bit <= 0 ;
    end
    else if(Data_Valid) begin
        if(PAR_TYP)
            begin
                if(^DATA_reg)
                    PAR_bit <= 0 ;
                else 
                    PAR_bit <= 1 ;
            end
        else 
            begin
                if(^DATA_reg)
                    PAR_bit <= 1 ;
                else 
                    PAR_bit <= 0 ;
            end
    end
    
end


endmodule