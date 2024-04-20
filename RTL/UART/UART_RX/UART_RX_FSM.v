module UART_RX_FSM (
    input clk , reset ,
    input RX_IN , PAR_EN ,
    input par_err , strt_glitch , stp_err ,
    input [5:0] Prescale ,
    input [5:0] edge_cnt ,
    input [3:0] bit_cnt ,
    output reg par_chk_en , strt_chk_en , stp_chk_en ,deser_en , dat_samp_en,
    output reg edge_enable ,
    output data_valid
);

reg [2:0] state_reg , state_next ;
localparam  IDLE   = 0 ,
            START  = 1 ,
            DATA   = 2 ,
            PAR_CK = 3 ,
            STOP   = 4 ;

always @(posedge clk , negedge reset) begin
    if(~reset) begin
        state_reg  <= IDLE ;
    end
    else begin
        state_reg <= state_next ;
    end
end

always @(*) begin
    state_next = state_reg ;
    case (state_reg)
        IDLE : begin
            if(RX_IN) 
                state_next = IDLE;
            else 
                state_next = START;
        end

        START : begin 
            if(edge_cnt == (Prescale -1)) begin
                if(strt_glitch)
                   state_next = IDLE;
                else 
                state_next = DATA;
            end
            else begin
                state_next = START;
            end
    end

        DATA : begin
            if(bit_cnt<9)
                state_next = DATA;
            else if(PAR_EN)
                state_next = PAR_CK;
            else 
                state_next = STOP;
        end

        PAR_CK : begin
            if((edge_cnt == (Prescale -1))) begin
                if(par_err)
                    state_next = IDLE;
                else
                    state_next = STOP;
            end
            else begin
                state_next = PAR_CK;
            end
        end
        STOP : begin
            if ( (edge_cnt == (Prescale -1))) begin
                if(RX_IN ||stp_err ) 
                    state_next = IDLE;
                else 
                    state_next = START;
                end
        else begin
            state_next = STOP;
        end
    end

        default: begin 
            state_next = IDLE;
        end
    endcase
end


always @(*) begin
    case (state_reg)
        IDLE : begin
            dat_samp_en  = 0 ;
            edge_enable  = 0 ;
            if(edge_cnt == 7 ) begin
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                deser_en     = 0 ;    
            end
            else begin
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                deser_en     = 0 ;
            end
        end

        START : begin
            dat_samp_en  = 1 ;
            edge_enable  = 1 ;
            if(edge_cnt == (Prescale -1) ) begin
                par_chk_en   = 0 ;
                strt_chk_en  = 1 ;
                stp_chk_en   = 0 ;
                deser_en     = 0 ;
            end
            else begin
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                deser_en     = 0 ;
            end
        end

        DATA : begin
            dat_samp_en  = 1 ;
            edge_enable  = 1 ;
            if(edge_cnt == (Prescale -1) ) begin
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                deser_en     = 1 ;
            end
            else begin
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                deser_en     = 0 ;
            end
        end

        PAR_CK :  begin
            dat_samp_en  = 1 ;
            edge_enable  = 1 ;
            if(edge_cnt == (Prescale -1) ) begin
                par_chk_en   = 1 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                deser_en     = 0 ;
            end
            else begin
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                deser_en     = 0 ;
            end
        end
        STOP : begin
            dat_samp_en  = 1 ;
            if (state_next == START)
                edge_enable  = 0;
            else begin
                edge_enable  = 1 ;

            end
            if(edge_cnt == (Prescale -1) ) begin
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 1 ;
                deser_en     = 0 ;
            end
            else begin
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                deser_en     = 0 ;
            end
        end
        default: begin
                dat_samp_en  = 0 ;
                edge_enable  = 0 ;
                if(edge_cnt == (Prescale -1) ) begin
                    par_chk_en   = 0 ;
                    strt_chk_en  = 0 ;
                    stp_chk_en   = 0 ;
                    deser_en     = 0 ;    
                end
                else begin
                    par_chk_en   = 0 ;
                    strt_chk_en  = 0 ;
                    stp_chk_en   = 0 ;
                    deser_en     = 0 ;
                end
            end        
    endcase
end

assign data_valid = (~(par_err | strt_glitch | stp_err) &&( state_reg == STOP ));
    
endmodule