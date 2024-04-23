module SYS_TOP #(
    parameter BUS_WIDTH = 8 , Reg_Addr = 4 , ALU_FUN = 4 
) (
 input                             RST_N,
 input                             UART_CLK,
 input                             REF_CLK,
 input                             UART_RX_IN,
 output                            UART_TX_O,
 output                            parity_error,
 output                            framing_error
);

    wire FIFO_FULL , ER_INC , EN , Rd_D_Valid , WrEn , RdEn , Gate_EN ;
    wire [5:0] Prescale ;
    wire SYNC_RST1 , SYNC_RST2 ;
    wire RX_CLK , TX_CLK ;
    wire F_EMPTY , BUSY , RD_INC ;
    wire      [BUS_WIDTH-1:0]          Operand_A,
                                       Operand_B,
									   UART_Config,
									   DIV_RATIO;
   wire [BUS_WIDTH-1:0]  UART_RX_OUT ;
   wire UART_RX_VALID , WR_INC;
   wire [BUS_WIDTH : 0] DATA_sync_out ;

   wire [BUS_WIDTH-1:0]  UART_TX_IN , WR_Data_FIFO,Wr_D ,DIV_RATIO_RX;
   wire UART_TX_VALID; 
   wire [Reg_Addr-1 : 0 ] Address ;
   wire [BUS_WIDTH-1:0]  Rd_D , RD_FIFO; 

   wire [ALU_FUN-1 : 0] FUN ;
   wire ALU_OUT_VALID ;
   wire [2*BUS_WIDTH -1:0] ALU_OUT;
   wire ALU_CLK , CLKDIV_EN;


   SYS_CONTROL #(.BUS_WIDTH(BUS_WIDTH) , .Reg_Addr(Reg_Addr),.ALU_FUN(ALU_FUN)) SYS_control (

    .REF_CLK(REF_CLK) , .SYNC_RST(SYNC_RST1) , .DATA_sync_out(DATA_sync_out) ,
    .Rd_D(Rd_D), .Rd_D_Valid(Rd_D_Valid) ,
    .ALU_OUT(ALU_OUT) , .ALU_OUT_valid(ALU_OUT_VALID) , .FIFO_FULL(FIFO_FULL),
    .WrEn(WrEn) , .RdEn(RdEn) , .WR_INC(WR_INC),
    .Addr(Address), .Wr_D(Wr_D), .WR_Data_FIFO(WR_Data_FIFO),
    .Gate_EN(Gate_EN), .EN(EN) , .FUN(FUN) , .CLKDIV_EN(CLKDIV_EN)

   );

   DATA_SYNC #(.NUM_STAGES(2), .BUS_WIDTH(8)) DATA_SYNC0 (

    .clk(REF_CLK) , .reset(SYNC_RST1) , .Unsync_bus(UART_RX_OUT) ,
    .bus_enable(UART_RX_VALID) , .sync_bus(DATA_sync_out[BUS_WIDTH-1:0]),
    .enable_pulse(DATA_sync_out[BUS_WIDTH])
    
   );

   RegFile U0_RegFile (
    .CLK(REF_CLK),
    .RST(SYNC_RST1),
    .WrEn(WrEn),
    .RdEn(RdEn),
    .Address(Address),
    .WrData(Wr_D),
    .RdData(Rd_D),
    .RdData_VLD(Rd_D_Valid),
    .REG0(Operand_A),
    .REG1(Operand_B),
    .REG2(UART_Config),
    .REG3(DIV_RATIO)
    );


    ALU U0_ALU (
    .CLK(ALU_CLK),
    .RST(SYNC_RST1),  
    .A(Operand_A), 
    .B(Operand_B),
    .EN(EN),
    .ALU_FUN(FUN),
    .ALU_OUT(ALU_OUT),
    .OUT_VALID(ALU_OUT_VALID)
    );

    CLK_GATE U0_CLK_GATE (
    .CLK_EN(Gate_EN),
    .CLK(REF_CLK),
    .GATED_CLK(ALU_CLK)
    );

    RSTSYNC RSTSYNC1(
    .clk(REF_CLK) ,
    .reset(RST_N),
    .SYNC_RST(SYNC_RST1)
    );

    RSTSYNC RSTSYNC2(
        .clk(UART_CLK) ,
        .reset(RST_N),
        .SYNC_RST(SYNC_RST2)
        );





    ASYC_FIFO ASYC_FIFO0(
        .R_CLK(TX_CLK) ,
        .R_RST(SYNC_RST2),
        .R_INC(RD_INC) ,
        .W_CLK(REF_CLK) , .W_RST(SYNC_RST1) , .W_INC(WR_INC),
        .WR_DATA(WR_Data_FIFO),.RD_DATA(RD_FIFO) ,
        .FULL(FIFO_FULL) , .EMPTY(F_EMPTY)
    );

/*
Async_fifo #(.D_SIZE(BUS_WIDTH) , .F_DEPTH(BUS_WIDTH), .P_SIZE(Reg_Addr) ) U0_UART_FIFO (
.i_w_clk(REF_CLK),
.i_w_rstn(SYNC_RST1),  
.i_w_inc(WR_INC),
.i_w_data(WR_Data_FIFO),             
.i_r_clk(TX_CLK),              
.i_r_rstn(SYNC_RST2),              
.i_r_inc(RD_INC),              
.o_r_data(RD_FIFO),             
.o_full(FIFO_FULL),               
.o_empty(F_EMPTY)               
);



*/




    ClkDiv U0_ClkDiv (
    .i_ref_clk(UART_CLK),             
    .i_rst(SYNC_RST2),                 
    .i_clk_en(CLKDIV_EN),               
    .i_div_ratio(DIV_RATIO),           
    .o_div_clk(TX_CLK)             
    );


    CLKDIV_MUX U0_CLKDIV_MUX (
    .IN(UART_Config[7:2]),
    .OUT(DIV_RATIO_RX)
    );

    ClkDiv U1_ClkDiv (
    .i_ref_clk(UART_CLK),             
    .i_rst(SYNC_RST2),                 
    .i_clk_en(CLKDIV_EN),               
    .i_div_ratio(DIV_RATIO_RX),           
    .o_div_clk(RX_CLK)             
    );

    UART  U0_UART (
    .RST(SYNC_RST2),
    .CLK_TX(TX_CLK),
    .CLK_RX(RX_CLK),
    .PAR_EN(UART_Config[0]),
    .PAR_TYP(UART_Config[1]),
    .Prescale(UART_Config[7:2]),
    .RX_IN(UART_RX_IN),
    .RX_OUT(UART_RX_OUT),                      
    .RX_VALID(UART_RX_VALID),                      
    .TX_IN_DATA(RD_FIFO), 
    .TX_DATA_VALID(!F_EMPTY), 
    .TX_OUT(UART_TX_O),
    .TX_BUSY(BUSY),
    .parity_error(parity_error),
    .framing_error(framing_error)                  
    );

    PulseGen PulseGen0(
        .clk(TX_CLK) , .reset(SYNC_RST2),
        .Q(BUSY), .PulseGen_out(RD_INC)
    );
    
endmodule
