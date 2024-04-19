module PulseGen (
    input clk , reset ,
    input Q ,
    output PulseGen_out
);

reg Q_reg ;
always @(posedge clk , negedge reset) begin
    if(~reset) begin
        Q_reg<= 0 ;
    end
    else begin
        Q_reg <= Q;
    end
end

assign PulseGen_out = (~Q_reg) & Q;
    
endmodule