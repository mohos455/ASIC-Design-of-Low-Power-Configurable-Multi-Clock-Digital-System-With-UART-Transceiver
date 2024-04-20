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
reg busy_reg ;

always @(posedge clk , negedge reset) begin
    if(~reset) begin
        state_reg  <= 0 ;
        Busy<= 0;
    end
    else begin
        
        Busy<= busy_reg;
        state_reg <= state_next ;
    end
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
                state_next = IDEL ;
            
        end

        default: state_next = IDEL ;
    endcase
end


/////////// OUTPUT //////////

always @(*) begin

    case (state_reg)
        IDEL : begin
            busy_reg    = 0 ;
            ser_en  = 0 ;
            mux_sel = 2'b01 ;
        end
        START : begin
            busy_reg    = 1;
            ser_en  = 0 ;
            mux_sel = 2'b00 ;
        end

        DATA : begin
            busy_reg    = 1 ;
            ser_en  = 1 ;
            mux_sel = 2'b10 ;
            if(ser_done)
            ser_en = 1'b0 ;  
			else
                ser_en = 1'b1 ; 
        end
        PARITY : begin
            busy_reg    = 1 ;
            ser_en  = 1 ;
            mux_sel = 2'b11 ;
        end
        STOP : begin
            busy_reg    = 1 ;
            ser_en  = 1 ;
            mux_sel = 2'b01 ;
        end

default: begin
    busy_reg    = 0 ;
            ser_en  = 0 ;
            mux_sel = 2'b01 ;
        end
    endcase
end

    
endmodule