`timescale 1ns / 1ps


module Mux32(
    input wire Sel,
    input wire [31:0] i0,
    input wire [31:0] i1,
    output reg [31:0] O
    );
    
    always @(*) begin
        if (Sel)
            O = i1;
        else
            O = i0;
    end
endmodule
