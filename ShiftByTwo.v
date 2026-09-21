`timescale 1ns / 1ps

module ShiftByTwo(
    input wire [31:0] dataIn,
    output wire [31:0] dataOut
    );
    
    assign dataOut = dataIn << 2;    
endmodule
