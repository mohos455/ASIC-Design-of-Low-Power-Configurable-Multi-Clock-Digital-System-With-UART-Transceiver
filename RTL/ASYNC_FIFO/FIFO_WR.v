module FIFO_WR #(
    parameter DATA_WIDTH = 8 , FIFO_DIPTH = 8
) (
    input W_CLK , W_RST , W_INC,
    input  [$clog2(FIFO_DIPTH) : 0] R_PTR ,
    output [$clog2(FIFO_DIPTH)-1:0] W_ADDR ,
    output reg [$clog2(FIFO_DIPTH) : 0] W_PTR ,
    output FULL 

);

reg [$clog2(FIFO_DIPTH) : 0] Counter ;

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
        W_PTR = Counter ^ (Counter >>1);
    end
end

    assign FULL = ((R_PTR[$clog2(FIFO_DIPTH):2] != W_PTR[$clog2(FIFO_DIPTH):2]) && (R_PTR[1:0] == W_PTR[1:0]));
    assign W_ADDR = Counter[$clog2(FIFO_DIPTH)-1:0];
    
endmodule