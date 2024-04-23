module DataSample (
    input clk , reset ,data_samp_en ,
    input [5:0] edge_cnt ,
    input [5:0]  Prescale,
    input RX_IN ,
    output reg sampled_bit 
);

wire [5:0] half_bit , half_neg1 , half_plus1 ;
reg [2:0] samples ;
assign half_bit   = (Prescale >> 1) - 1 ;
assign half_neg1  = half_bit - 1 ;
assign half_plus1 = half_bit + 1 ;

always @(posedge clk , negedge reset) begin
    if(~reset)
        samples <= 0;
    else if(data_samp_en) begin 
        if(edge_cnt == half_neg1 )
            samples[0] <= RX_IN;
        else if(edge_cnt == half_bit) begin
            samples[1] <= RX_IN;
        end
        else if(edge_cnt == half_plus1) begin
            samples[2] <= RX_IN;
        end
    end
    else begin
        samples <= 0;
    end
end

always @(posedge clk , negedge reset) begin
    if(~reset)
        sampled_bit <= 0;
    else if(data_samp_en)
        sampled_bit <= ((samples[0] & samples[1]) | (samples[0] & samples[2]) | (samples[2] & samples[1]) );
    else begin
        sampled_bit <= 0;
    end
end

    
endmodule
