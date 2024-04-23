module BitSYNC #(
    parameter NUM_STAGES = 2 , DATA_WIDTH = 1
) (
    input clk , reset ,
    input [DATA_WIDTH-1:0] ASYNC ,
    output [DATA_WIDTH-1:0] SYNC
);

    genvar i ;

    reg [DATA_WIDTH-1:0] reg_file [NUM_STAGES-1:0];

    generate
        for( i =0 ; i< NUM_STAGES ; i=i+1  ) begin
            always @(posedge clk , negedge reset) begin
                if(~reset) begin
                    reg_file[i] <= 0;
                end 
                else if(i == 0) begin
                    reg_file[i] <= ASYNC ;
                end
                else begin
                    reg_file[i] <= reg_file[i-1] ;
                end
            end
        end
    endgenerate
    assign SYNC = reg_file[NUM_STAGES-1];

    
endmodule