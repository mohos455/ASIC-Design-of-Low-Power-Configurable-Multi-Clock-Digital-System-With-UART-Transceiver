module ASYC_FIFO #(
    parameter  DATA_WIDTH =  8 , FIFO_DIPTH = 8 , ADDRESS_WIDTH = 3
) (
    input  R_CLK , R_RST , R_INC , 
    input W_CLK , W_RST , W_INC,
    input [DATA_WIDTH-1 : 0 ] WR_DATA ,
    output [DATA_WIDTH-1 : 0] RD_DATA ,
    output FULL , EMPTY

);


wire [ADDRESS_WIDTH-1:0] W_ADDR , R_ADDR ;
wire [ADDRESS_WIDTH: 0] W_PTR ,R_PTR ,W_PTR_sync , R_PTR_sync ;
wire W_INC_EN ;
assign W_INC_EN = (W_INC && (~FULL));

FIFO_MEM_CNTRL #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DIPTH(FIFO_DIPTH) , .ADDRESS_WIDTH(ADDRESS_WIDTH)) FIFO_mem (

    .W_CLK(W_CLK) , .W_INC(W_INC_EN) , 
    .W_ADDR(W_ADDR) , .R_ADDR(R_ADDR) ,
    .WR_DATA(WR_DATA) , .RD_DATA(RD_DATA)
);

FIFO_RD #( .ADDRESS_WIDTH(ADDRESS_WIDTH)) FIFO_RD_UT (
    .R_CLK(R_CLK) , .R_RST(R_RST) , .R_INC(R_INC) ,
    .W_PTR(W_PTR_sync), .R_ADDR(R_ADDR),.R_PTR(R_PTR),
    .EMPTY(EMPTY)
);

BitSYNC #(.DATA_WIDTH(ADDRESS_WIDTH+1)) RD_sync (
    .clk(R_CLK) , .reset(R_RST) , .ASYNC(W_PTR) , .SYNC(W_PTR_sync)
);

BitSYNC #( .DATA_WIDTH(ADDRESS_WIDTH+1)) WR_sync (
    .clk(W_CLK) , .reset(W_RST) , .ASYNC(R_PTR) , .SYNC(R_PTR_sync)
);

FIFO_WR #( .ADDRESS_WIDTH(ADDRESS_WIDTH)) FIFO_WR_UT (

    .W_CLK(W_CLK) , .W_RST(W_RST) , .W_INC(W_INC) ,
    .R_PTR(R_PTR_sync) , .W_ADDR(W_ADDR) , .W_PTR(W_PTR) , .FULL(FULL)
);

endmodule
