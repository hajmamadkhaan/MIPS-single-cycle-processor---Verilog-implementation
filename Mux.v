`timescale 1ns / 1ps


module Mux(
    input wire i0,
    input wire i1,
    input wire Sel,
    output reg O
    );
    
    always @(Sel or i0 or i1) begin
        if (Sel)
            O = i1;
        else
            O = i0;
    end
endmodule
