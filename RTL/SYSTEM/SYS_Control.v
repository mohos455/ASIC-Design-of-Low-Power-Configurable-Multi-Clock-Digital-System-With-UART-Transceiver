module SYS_CONTROL #(

    parameter BUS_WIDTH = 8 , Reg_Addr = 4 , ALU_FUN = 4 

) (

    input REF_CLK , SYNC_RST ,

    input [BUS_WIDTH : 0] DATA_sync_out , 

    input [BUS_WIDTH - 1 : 0] Rd_D ,

    input Rd_D_Valid ,

    input [BUS_WIDTH*2 - 1 : 0] ALU_OUT ,

    input ALU_OUT_valid ,

    input FIFO_FULL ,

    output reg WrEn , RdEn , WR_INC ,

    output reg [Reg_Addr-1 : 0] Addr ,

    output reg [BUS_WIDTH - 1 : 0] Wr_D , 

    output reg [BUS_WIDTH - 1 : 0] WR_Data_FIFO , 

    output reg Gate_EN , EN,CLKDIV_EN,

    output reg [ALU_FUN-1 : 0] FUN 

);



    reg [3:0] state_reg , state_next ;
    reg [ALU_FUN-1 : 0] FUN_reg , FUN_next ;

    reg [BUS_WIDTH-1 : 0] Operation, Operation_next ;
    reg [Reg_Addr-1 : 0] Addr_reg , Addr_next;

    reg [BUS_WIDTH*2 - 1 : 0] ALU_reg, ALU_next ;

    localparam  Reg_write =  8'hAA ,

                Reg_read  =  8'hBB ,

                ALU_W_OP  =  8'hCC ,

                ALU_N_OP  =  8'hDD ;

    

    localparam  IDLE       = 0 ,

                DECODE     = 1 ,

                ADDRESS     = 2 ,  

                WRITE      = 3 ,

                READ       = 4 ,

                ALU_OP_A   = 5 ,

                ALU_OP_B   = 6 ,

                ALU_fun    = 7 ,

                ALU_OUT_1  = 8 ,

                ALU_OUT_2  = 9 ;





    always @(posedge REF_CLK or negedge SYNC_RST) begin

        if(~SYNC_RST) begin
            FUN_reg <= 0 ;
            state_reg <= 0 ;
            ALU_reg<=0 ;
            Addr_reg<= 0 ;
            Operation <= 0;

        end

        else begin
            FUN_reg <= FUN_next ;
            state_reg <= state_next ;
            Operation <= Operation_next;
            ALU_reg<=ALU_next ;
            Addr_reg<= Addr_next ;

        end

    end



    always @(*) begin

        state_next = state_reg ;

        Operation_next = Operation ;

        ALU_next = ALU_reg;
	    Addr_next = Addr_reg ; 
	    FUN_next = FUN_reg;

        case (state_reg)

        IDLE : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                state_next = DECODE ;

            end

            else begin

                state_next = IDLE ;

            end

        end



        DECODE : begin

            Operation_next = DATA_sync_out[BUS_WIDTH-1:0] ;

            if((DATA_sync_out[BUS_WIDTH-1:0] == Reg_write)|| (DATA_sync_out[BUS_WIDTH-1:0] == Reg_read)) begin

                state_next = ADDRESS ;

            end

            else if(DATA_sync_out[BUS_WIDTH-1:0] == ALU_W_OP) begin

                state_next = ALU_OP_A ;

            end

            else if(DATA_sync_out[BUS_WIDTH-1:0] == ALU_N_OP) begin

                state_next = ALU_fun ;

            end

            else  begin

                state_next = IDLE ;

            end

        end



        ADDRESS : begin

            if(DATA_sync_out[BUS_WIDTH]) begin
                Addr_next = DATA_sync_out[Reg_Addr-1 : 0] ;

                if((Operation == Reg_write))begin

                    state_next = WRITE ;

                end

                else if(Operation == Reg_read) begin

                    state_next = READ ;

                end

                else  begin

                    state_next = IDLE ;

                end

                end

            else begin

                state_next = ADDRESS ;

            end

        end

        WRITE : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                state_next =  IDLE;

            end

            else begin

                state_next = WRITE ;

            end

        end

    

        READ : begin

            if(Rd_D_Valid) begin

                state_next = IDLE ;

            end

            else begin

                state_next = READ ;

            end

        end

        ALU_OP_A : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                state_next = ALU_OP_B ;

            end

            else begin

                state_next = ALU_OP_A ;

            end

        end

        ALU_OP_B : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                state_next = ALU_fun ;

            end

            else begin

                state_next = ALU_OP_B ;

            end

        end

        ALU_fun : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                state_next = ALU_OUT_1 ;
                FUN_next = DATA_sync_out[ALU_FUN-1 : 0] ;

            end

            else begin

                state_next = ALU_fun ;

            end

        end

        ALU_OUT_1 : begin

            if(ALU_OUT_valid) begin

                ALU_next = ALU_OUT ;

                state_next = ALU_OUT_2 ;

            end

            else begin

                state_next = ALU_OUT_1 ;

            end

        end

        ALU_OUT_2 : begin

            if(ALU_OUT_valid) begin

                state_next = IDLE ;

            end

            else begin

                state_next = ALU_OUT_2 ;

            end

        end

        default : state_next = IDLE ;

        endcase

    end



    always @(*) begin

        case (state_reg)

        IDLE , DECODE : begin

            WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

            Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

            Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

        end

        ADDRESS : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = Addr_reg ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

                Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

                end

            else begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

                Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

             end

        end

        WRITE : begin

            

        if(DATA_sync_out[BUS_WIDTH]) begin

            WrEn  = 1 ; RdEn = 0 ; WR_INC = 0 ;

            Addr = Addr_reg ;  Wr_D = DATA_sync_out[BUS_WIDTH-1:0] ; WR_Data_FIFO = 0 ;

            Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

            end

        else begin

            WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

            Addr = Addr_reg ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

            Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

         end

        end

        

        READ : begin

        if(Rd_D_Valid && !FIFO_FULL) begin

            WrEn  = 0 ; RdEn = 1 ; WR_INC = 1 ;

            Addr = Addr_reg ;  Wr_D = 0 ; WR_Data_FIFO = Rd_D ;

            Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

            end

        else begin

            WrEn  = 0 ; RdEn = 1 ; WR_INC = 0 ;

            Addr = Addr_reg ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

            Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

         end

        end

        ALU_OP_A : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                WrEn  = 1 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 0 ;  Wr_D = DATA_sync_out[BUS_WIDTH-1:0] ; WR_Data_FIFO = 0 ;

                Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

                end

            else begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

                Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

             end

         end

        ALU_OP_B : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                WrEn  = 1 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 1 ;  Wr_D = DATA_sync_out[BUS_WIDTH-1:0] ; WR_Data_FIFO = 0 ;

                Gate_EN = 1; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

                end

            else begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

                Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

             end

         end

        ALU_fun : begin

            if(DATA_sync_out[BUS_WIDTH]) begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ; CLKDIV_EN= 1;

                Gate_EN = 1; EN = 1 ; FUN = FUN_reg ;

                end

            else begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

                Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

             end

        end

        ALU_OUT_1 : begin

            if(ALU_OUT_valid && !FIFO_FULL) begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 1;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = ALU_reg [BUS_WIDTH - 1: 0];

                Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

                end

            else begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

                Gate_EN = 1; EN = 1 ; FUN = FUN_reg ; CLKDIV_EN= 1;

             end

        end

        ALU_OUT_2 : begin

            if(ALU_OUT_valid && !FIFO_FULL) begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 1; CLKDIV_EN= 1;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = ALU_reg [2*BUS_WIDTH - 1: BUS_WIDTH];

                Gate_EN = 0; EN = 0 ; FUN = 0 ;

                end

            else begin

                WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

                Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

                Gate_EN = 1; EN = 1 ; FUN = FUN_reg ; CLKDIV_EN= 1;

             end

        end

        default : begin

            WrEn  = 0 ; RdEn = 0 ; WR_INC = 0 ;

            Addr = 0 ;  Wr_D = 0 ; WR_Data_FIFO = 0 ;

            Gate_EN = 0; EN = 0 ; FUN = 0 ; CLKDIV_EN= 1;

        end

        endcase

    end

    

endmodule
