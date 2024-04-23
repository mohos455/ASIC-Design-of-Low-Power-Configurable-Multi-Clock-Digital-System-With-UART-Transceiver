module DATA_SYNC #(
    parameter NUM_STAGES = 2 , BUS_WIDTH = 8
) (
    input clk , reset ,
    input [BUS_WIDTH -1 : 0] Unsync_bus ,
    input bus_enable ,
    output reg [BUS_WIDTH -1 : 0] sync_bus ,
    output reg enable_pulse
);

    wire bus_enable_syn , PulseGen_out;
    BitSYNC  #(.NUM_STAGES(NUM_STAGES) , .DATA_WIDTH(1)) BUS_EN_SYN (

    .clk(clk), .reset(reset) ,.ASYNC(bus_enable) , .SYNC(bus_enable_syn)
    );

    PulseGen PulseGen_UNT (
    .clk(clk) , .reset(reset) ,
    .Q(bus_enable_syn) ,
    .PulseGen_out(PulseGen_out)
    );

    always @(posedge clk , negedge reset) begin
        if(~reset) begin
            enable_pulse <= 0;
        end
        else begin
            enable_pulse <= PulseGen_out;
        end
    end


    always @(posedge clk , negedge reset) begin
        if(~reset) begin
            sync_bus <=0 ;
        end else begin
            case (PulseGen_out)
                1'b0 : sync_bus <= sync_bus ;
                1'b1 : sync_bus <= Unsync_bus;
            endcase
        end
    end


    
endmodule
