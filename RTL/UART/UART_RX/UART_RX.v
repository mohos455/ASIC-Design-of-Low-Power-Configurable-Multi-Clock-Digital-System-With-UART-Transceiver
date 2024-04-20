module UART_RX (
    input clk , reset ,
    input RX_IN ,
    input [5:0] Prescale ,
    input PAR_EN , PAR_TYP ,
    output data_valid ,
    output [7:0] P_DATA ,
    output                            parity_error,
    output                            framing_error
);

wire strt_glitch  ,sampled_bit ;
wire par_chk_en , strt_chk_en , stp_chk_en ,deser_en , dat_samp_en,edge_enable;
wire [5:0] edge_cnt ;
wire [3:0] bit_cnt  ;
wire [7:0] DATA ;

UART_RX_FSM FSM_ut (
    .clk(clk),
    .reset(reset), .Prescale(Prescale),
    .RX_IN(RX_IN) , .PAR_EN(PAR_EN) , .par_err(parity_error),
    .strt_glitch(strt_glitch),.stp_err(framing_error),
    .par_chk_en(par_chk_en),.strt_chk_en(strt_chk_en),.stp_chk_en(stp_chk_en),.deser_en(deser_en),.dat_samp_en(dat_samp_en),
    .edge_enable(edge_enable),.edge_cnt(edge_cnt),.bit_cnt(bit_cnt),
    .data_valid(data_valid)
);

EdgeBitCounter  EdgeBitCounter_ut (
    .clk(clk),
    .reset(reset),
    .enable(edge_enable),
    .Prescale(Prescale),
    .edge_cnt(edge_cnt),.bit_cnt(bit_cnt)
);

ParityCheck ParityCheck_ut (
    .clk(clk),
    .reset(reset),
    .sampled_bit(sampled_bit),
    .par_chk_en(par_chk_en) , .PAR_TYP(PAR_TYP),
    .P_DATA(P_DATA),.par_err(parity_error)

);

DataSample DataSample_ut (
    .clk(clk),
    .reset(reset),
    .sampled_bit(sampled_bit),
    .data_samp_en(dat_samp_en),
    .edge_cnt(edge_cnt),
    .Prescale(Prescale),.RX_IN(RX_IN)
);

Deserializer Deserializer_ut(
    .clk(clk),
    .reset(reset),
    .sampled_bit(sampled_bit),
    .deser_en(deser_en),
    .P_DATA(P_DATA)

);

StartCheck StartCheck_ut (
    .clk(clk),
    .reset(reset),
    .sampled_bit(sampled_bit),
    .strt_ch_en(strt_chk_en),
    .strt_glitch(strt_glitch)
);

StoptCheck StoptCheck_ut (
    .clk(clk),
    .reset(reset),
    .sampled_bit(sampled_bit),
    .stp_ch_en(stp_chk_en),
    .stp_err(framing_error)
);

    
endmodule