module FIFO_WR #(
    parameter  ADDRESS_WIDTH = 3
) (
    input W_CLK , W_RST , W_INC,
    input  [ADDRESS_WIDTH : 0] R_PTR ,
    output [ADDRESS_WIDTH-1:0] W_ADDR ,
    output reg [ADDRESS_WIDTH : 0] W_PTR ,
    output FULL 

);

reg [ADDRESS_WIDTH : 0] Counter ;

always @(posedge W_CLK , negedge W_RST ) begin
    if(~W_RST) begin
        Counter <= 0 ;
    end
    else if (W_INC && !FULL) begin
        Counter <= Counter + 1 ;
    end
end

// Gray Code 
always @(posedge W_CLK , negedge W_RST ) begin
    if(~W_RST) begin
        W_PTR <= 0 ;
    end
    else begin
        W_PTR <= Counter ^ (Counter >>1);
    end
end

    assign FULL = ((R_PTR[ADDRESS_WIDTH:2] != W_PTR[ADDRESS_WIDTH:2]) && (R_PTR[1:0] == W_PTR[1:0]));
    assign W_ADDR = Counter[ADDRESS_WIDTH-1:0];
    
endmodule
