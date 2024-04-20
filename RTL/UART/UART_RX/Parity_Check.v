module ParityCheck (
    input clk , reset ,
    input sampled_bit , par_chk_en ,PAR_TYP,
    input [7:0] P_DATA ,
    output reg par_err
);

    reg par_reg ;
    always @(posedge clk , negedge reset) begin
        if(~reset) begin
            par_reg <= 0;
            par_err <= 0;
        end 
        else if(par_chk_en) begin
            par_err <= ~(par_reg == sampled_bit);
        end
    end

    always @(*) begin
        if(par_chk_en) begin
            if(PAR_TYP)
            begin
                if(^P_DATA)
                    par_reg = 0 ;
                else 
                    par_reg = 1 ;
            end
        else 
            begin
                if(^P_DATA)
                    par_reg = 1 ;
                else 
                    par_reg = 0 ;
            end
        end
    
    end
    
endmodule