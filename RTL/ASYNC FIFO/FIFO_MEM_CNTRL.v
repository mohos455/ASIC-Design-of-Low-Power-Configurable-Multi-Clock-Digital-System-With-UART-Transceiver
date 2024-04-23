module FIFO_MEM_CNTRL  #(
    parameter DATA_WIDTH = 8 , ADDRESS_WIDTH = 3 , FIFO_DIPTH = 8
) (
    input W_CLK , W_INC ,
    input [ADDRESS_WIDTH-1:0] W_ADDR , R_ADDR ,
    input [DATA_WIDTH-1 : 0 ] WR_DATA ,
    output [DATA_WIDTH-1 : 0] RD_DATA 
);

 reg [DATA_WIDTH-1 : 0 ] FIFO_MEM [FIFO_DIPTH:0] ;

 // Write Data 

 always @(posedge W_CLK ) begin
        if(W_INC) begin
            FIFO_MEM[W_ADDR] <= WR_DATA ;
        end
 end
    // Read Data

  assign  RD_DATA = FIFO_MEM[R_ADDR] ;
endmodule