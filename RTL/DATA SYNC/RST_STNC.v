module RSTSYNC #(
    parameter NUM_STAGES = 2 
) (
    input clk , reset ,
    output SYNC_RST
);

    genvar i ;

    reg [NUM_STAGES-1:0] reg_file ;

    generate
        for( i =0 ; i< NUM_STAGES ; i=i+1  ) begin
            always @(posedge clk , negedge reset) begin
                if(~reset) begin
                    reg_file[i] <= 0;
                end 
                else if(i == 0) begin
                    reg_file[i] <= 1'b1 ;
                end
                else begin
                    reg_file[i] <= reg_file[i-1] ;
                end
            end
        end
    endgenerate
    assign SYNC_RST = reg_file[NUM_STAGES-1];

    
endmodule