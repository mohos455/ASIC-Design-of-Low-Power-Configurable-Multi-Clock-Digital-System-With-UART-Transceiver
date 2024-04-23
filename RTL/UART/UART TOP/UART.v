module UART (
    input CLK_TX , CLK_RX , RST ,
    input [7:0] TX_IN_DATA ,
    input PAR_EN , TX_DATA_VALID , PAR_TYP ,RX_IN ,
    input [5:0] Prescale ,
    output TX_BUSY , TX_OUT , RX_VALID,
    output [7:0] RX_OUT ,
    output           parity_error,
    output           framing_error

);


UART_TX UART_TX0(
    .clk(CLK_TX) , .reset(RST),
    .P_DATA(TX_IN_DATA), .PAR_TYP(PAR_TYP) , .PAR_EN(PAR_EN) , .Data_Valid(TX_DATA_VALID) , .busy(TX_BUSY) , .TX_OUT(TX_OUT)
);

UART_RX UART_RX0 (
    .clk(CLK_RX) , .reset(RST),
    .RX_IN(RX_IN), .Prescale(Prescale), .PAR_TYP(PAR_TYP) , .PAR_EN(PAR_EN) , .data_valid(RX_VALID) , .P_DATA(RX_OUT), .parity_error(parity_error),
    .framing_error(framing_error)

);
    
endmodule
