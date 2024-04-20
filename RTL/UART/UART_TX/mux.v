module MUX41 (
    input [1:0] sel ,
    input sel3,sel4 ,
    output reg selected
);

always @(*) begin
    selected = 0 ;
    case (sel)
        2'b00 : selected = 1'b0 ;
        2'b01 : selected = 1'b1 ;
        2'b10 : selected = sel3 ;
        2'b11 : selected = sel4 ;      
    endcase
end
    
endmodule