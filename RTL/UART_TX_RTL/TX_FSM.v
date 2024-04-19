module TX_FSM (
    input clk , reset ,
    input Data_Valid , PAR_EN , ser_done , 
    output reg ser_en , Busy ,
    output reg [1:0] mux_sel 
);


localparam  IDEL   = 0,
            START  = 1,
            DATA   = 2,
            PARITY = 3,
            STOP   = 4;

reg [2:0] state_reg , state_next ;

always @(posedge clk , negedge reset) begin
    if(~reset) begin
        state_reg  <= 0 ;
    end
    else
        state_reg <= state_next ;
end

always @(*) begin
    state_next = state_reg ;

    case (state_reg)
       IDEL : begin
                if(~Data_Valid) begin
                    state_next = IDEL ;
                end
                else
                    state_next = START ;
    end
        START : begin
            state_next = DATA ;
        end

        DATA : begin
            if(~ser_done) begin
                state_next = DATA ;
            end
            else if (ser_done && PAR_EN ) begin
                state_next = PARITY ;
            end
            else begin
                state_next = STOP ;

            end
        end
        PARITY : begin
            state_next = STOP ;
        end
        STOP : begin
            if(Data_Valid) 
                state_next = START ;
            else begin
                state_next = IDEL ;
            end
        end

        default: state_next = IDEL ;
    endcase
end


/////////// OUTPUT //////////

always @(*) begin

    case (state_reg)
        IDEL : begin
            Busy    = 0 ;
            ser_en  = 0 ;
            mux_sel = 2'b01 ;
        end
        START : begin
            Busy    = 1;
            ser_en  = 0 ;
            mux_sel = 2'b00 ;
        end

        DATA : begin
            Busy    = 1 ;
            ser_en  = 1 ;
            mux_sel = 2'b10 ;
        end
        PARITY : begin
            Busy    = 1 ;
            ser_en  = 1 ;
            mux_sel = 2'b11 ;
        end
        STOP : begin
            Busy    = 1 ;
            ser_en  = 1 ;
            mux_sel = 2'b01 ;
        end

default: begin
            Busy    = 0 ;
            ser_en  = 0 ;
            mux_sel = 2'b01 ;
        end
    endcase
end

    
endmodule