module Deserializer (
    input clk , reset ,
    input sampled_bit,deser_en,
    output reg [7:0] P_DATA
);


always @(posedge clk , negedge reset) begin
    if(~reset) begin
        P_DATA <= 0 ;
    end
    else if((deser_en)) begin
        P_DATA <= {sampled_bit ,P_DATA[7:1]} ;
    end
end
    
endmodule