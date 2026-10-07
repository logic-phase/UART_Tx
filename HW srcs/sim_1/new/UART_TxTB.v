`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2026 12:30:02 AM
// Design Name: 
// Module Name: UART_TxTB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_TxTB();

reg Clk ; 
reg nRst ; 
reg [7:0] Data ; 

wire Tx ; 
wire Data_ready ; 
wire Err ;


initial begin 
    nRst = 0 ; 
    #100 ; 
    nRst = 1 ; 
end 

initial begin 
    Clk = 0 ; 
    forever #5 
    Clk = ~Clk ; 
end 


initial begin
    Data = 8'b01000101; 
    #3000000
    Data = 8'b10110101;
    #5000000 
    Data = 8'b11001001; 
end 



UART_Tx 
UART_TxUT(
.Clk(Clk),
.nRst(nRst),
.Data(Data), 
 
.Tx(Tx),
.Data_ready(Data_ready), 
.Err(Err)
); 
endmodule
