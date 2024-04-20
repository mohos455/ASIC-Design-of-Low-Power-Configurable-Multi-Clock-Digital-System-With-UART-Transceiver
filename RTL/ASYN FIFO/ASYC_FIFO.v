module ASYC_FIFO #(
    parameter NUM_STAGES = 2 , DATA_WIDTH =  8 , FIFO_DIPTH = 8
) (
    input  R_CLK , R_RST , R_INC , 
    input W_CLK , W_RST , W_INC,
    input [DATA_WIDTH-1 : 0 ] WR_DATA ,
    output [DATA_WIDTH-1 : 0] RD_DATA ,
    output FULL , EMPTY

);


wire [$clog2(FIFO_DIPTH)-1:0] W_ADDR , R_ADDR ;
wire [$clog2(FIFO_DIPTH) : 0] W_PTR ,R_PTR ,W_PTR_sync , R_PTR_sync ;
wire W_INC_EN ;
assign W_INC_EN = (W_INC && (~FULL));

FIFO_MEM_CNTRL #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DIPTH(FIFO_DIPTH)) FIFO_mem (

    .W_CLK(W_CLK) , .W_INC(W_INC_EN) , 
    .W_ADDR(W_ADDR) , .R_ADDR(R_ADDR) ,
    .WR_DATA(WR_DATA) , .RD_DATA(RD_DATA)
);

FIFO_RD #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DIPTH(FIFO_DIPTH)) FIFO_RD_UT (
    .R_CLK(R_CLK) , .R_RST(R_RST) , .R_INC(R_INC) ,
    .W_PTR(W_PTR_sync), .R_ADDR(R_ADDR),.R_PTR(R_PTR),
    .EMPTY(EMPTY)
);

BitSYNC #(.NUM_STAGES(NUM_STAGES), .BUS_WIDTH($clog2(FIFO_DIPTH)+1)) RD_sync (
    .clk(R_CLK) , .reset(R_RST) , .ASYNC(W_PTR) , .SYNC(W_PTR_sync)
);

BitSYNC #(.NUM_STAGES(NUM_STAGES), .BUS_WIDTH($clog2(FIFO_DIPTH)+1)) WR_sync (
    .clk(W_CLK) , .reset(W_RST) , .ASYNC(R_PTR) , .SYNC(R_PTR_sync)
);

FIFO_WR #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DIPTH(FIFO_DIPTH)) FIFO_WR_UT (

    .W_CLK(W_CLK) , .W_RST(W_RST) , .W_INC(W_INC) ,
    .R_PTR(R_PTR_sync) , .W_ADDR(W_ADDR) , .W_PTR(W_PTR) , .FULL(FULL)
);

endmodule