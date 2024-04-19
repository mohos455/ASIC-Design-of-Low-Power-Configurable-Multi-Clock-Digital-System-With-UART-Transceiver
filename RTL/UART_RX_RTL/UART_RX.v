module UART_RX (
    input clk , reset ,
    input RX_IN ,
    input [4:0] Prescale ,
    input PAR_EN , PAR_TYP ,
    output data_valid ,
    output [7:0] P_DATA 
);

wire par_err , strt_glitch , stp_err ,sampled_bit ;
wire par_chk_en , strt_chk_en , stp_chk_en ,deser_en , dat_samp_en,edge_enable;
wire [4:0] edge_cnt ;
wire [3:0] bit_cnt  ;
wire [7:0] DATA ;

UART_RX_FSM FSM_ut (
    .clk(clk),
    .reset(reset),
    .RX_IN(RX_IN) , .PAR_EN(PAR_EN) , .par_err(par_err),
    .strt_glitch(strt_glitch),.stp_err(stp_err),
    .par_chk_en(par_chk_en),.strt_chk_en(strt_chk_en),.stp_chk_en(stp_chk_en),.deser_en(deser_en),.dat_samp_en(dat_samp_en),
    .edge_enable(edge_enable),.edge_cnt(edge_cnt),.bit_cnt(bit_cnt),
    .data_valid(data_valid)
);

EdgeBitCounter #(.Prescale(8)) EdgeBitCounter_ut (
    .clk(clk),
    .reset(reset),
    .enable(edge_enable),
    .edge_cnt(edge_cnt),.bit_cnt(bit_cnt)
);

ParityCheck ParityCheck_ut (
    .clk(clk),
    .reset(reset),
    .sampled_bit(sampled_bit),
    .par_chk_en(par_chk_en) , .PAR_TYP(PAR_TYP),
    .P_DATA(DATA),.par_err(par_err)

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
    .P_DATA(DATA)

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
    .stp_err(stp_err)
);

assign P_DATA = DATA;
    
endmodule