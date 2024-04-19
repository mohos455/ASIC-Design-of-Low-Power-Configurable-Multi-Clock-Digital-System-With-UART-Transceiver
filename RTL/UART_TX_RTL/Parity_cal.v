module Parity_CAL (
    input clk ,reset ,
    input [7:0] P_DATA ,
    input Data_Valid ,
    input PAR_TYP ,
    output reg PAR_bit
);



reg PAR_out_reg ;
always @(posedge clk , negedge reset) begin
    if(~reset) begin
        PAR_bit <= 0 ;
    end
    else if(Data_Valid) begin
        if(PAR_TYP)
            begin
                if(^P_DATA)
                    PAR_bit <= 0 ;
                else 
                    PAR_bit <= 1 ;
            end
        else 
            begin
                if(^P_DATA)
                    PAR_bit <= 1 ;
                else 
                    PAR_bit <= 0 ;
            end
    end
    
end


endmodule