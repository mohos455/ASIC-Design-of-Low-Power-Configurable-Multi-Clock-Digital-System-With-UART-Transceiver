module StoptCheck (
    input clk , reset ,
    input sampled_bit , stp_ch_en ,
    output reg stp_err
);
    always @(posedge clk , negedge reset) begin
        if(~reset) begin
            stp_err <= 0;
        end
        else if (stp_ch_en) begin
            stp_err <= ~sampled_bit ;
        end
    end
endmodule