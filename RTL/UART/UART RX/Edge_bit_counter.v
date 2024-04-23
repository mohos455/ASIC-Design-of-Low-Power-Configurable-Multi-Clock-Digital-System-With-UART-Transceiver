module EdgeBitCounter #(
) (
    input clk , reset , enable,
    input [5:0] Prescale ,
    output reg [5:0] edge_cnt ,
    output reg [3:0] bit_cnt
);

    always @(posedge clk , negedge reset) begin
        if(~reset) begin
            edge_cnt <=0 ;
            bit_cnt  <=0 ;
        end
        else if(enable) begin
            edge_cnt <= edge_cnt+1 ;
            if(edge_cnt == (Prescale-1))  begin
                edge_cnt <= 0 ;
                bit_cnt <= bit_cnt +1 ;

            end
        end
        else begin
            edge_cnt <=0 ;
            bit_cnt  <=0 ;
        end
    end

endmodule