module FIFO_RD #(
    parameter DATA_WIDTH = 8 , FIFO_DIPTH = 8
) (
    input  R_CLK , R_RST ,
    input  R_INC , 
    input  [$clog2(FIFO_DIPTH) : 0] W_PTR ,
    output [$clog2(FIFO_DIPTH)-1:0] R_ADDR ,
    output reg [$clog2(FIFO_DIPTH) : 0] R_PTR ,
    output EMPTY
) ;
    reg [$clog2(FIFO_DIPTH) : 0] Counter ;

    
    always @(posedge R_CLK , negedge R_RST ) begin
        if(~R_RST) begin
            Counter <= 0 ;
        end
        else if (R_INC && !EMPTY) begin
            Counter <= Counter + 1 ;
        end
    end

    // Gray Code 
    always @(posedge R_CLK , negedge R_RST ) begin
        if(~R_RST) begin
            R_PTR <= 0 ;
        end
        else begin
            R_PTR = Counter ^ (Counter >>1);
        end
    end

    assign EMPTY = (W_PTR == R_PTR);
    assign R_ADDR = Counter[$clog2(FIFO_DIPTH)-1:0];
    
endmodule