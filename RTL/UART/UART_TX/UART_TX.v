module UART_TX (
    input clk , reset ,
    input [7:0] P_DATA ,
    input PAR_EN ,
    input Data_Valid ,
    input PAR_TYP ,
    output busy , TX_OUT
);


wire ser_done , ser_en , par_bit ,ser_data ;

wire [1:0] mux_sel ;

MUX41 MUX41_UNIT ( .sel(mux_sel) , .sel3(ser_data) , .sel4(par_bit),.selected(TX_OUT));

Parity_CAL Parity_CAL_UNIT (
        .clk(clk) ,
        .reset(reset),
        .P_DATA(P_DATA),
        .Data_Valid(Data_Valid),
        .Busy(busy),
        .PAR_TYP(PAR_TYP),
        .PAR_bit(par_bit)
);

serializer serializer_UNIT (
    .clk(clk) ,
    .reset(reset),
    .P_DATA(P_DATA),
    .Data_Valid(Data_Valid),
    .Busy(busy),
    .ser_en(ser_en),
    .ser_data(ser_data),
    .ser_done(ser_done)
);

TX_FSM TX_FSM_UNIT (
    .clk(clk) ,
    .reset(reset),
    .Data_Valid(Data_Valid),
    .PAR_EN(PAR_EN),
    .ser_done(ser_done),
    .ser_en(ser_en),
    .Busy(busy),
    .mux_sel(mux_sel)
);
    
endmodule