module StartCheck (
    input clk , reset ,
    input sampled_bit , strt_ch_en ,
    output reg strt_glitch
);
    always @(posedge clk , negedge reset) begin
        if(~reset) begin
            strt_glitch <= 0;
        end
        else if (strt_ch_en) begin
            strt_glitch <= sampled_bit ;
        end
    end
endmodule