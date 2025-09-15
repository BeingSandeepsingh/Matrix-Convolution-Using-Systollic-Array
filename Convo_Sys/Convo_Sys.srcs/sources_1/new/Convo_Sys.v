`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.08.2025 12:01:38
// Design Name: 
// Module Name: Convo_Sys
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


module Convo_Sys#(parameter width=16,stride=1,padding=0,N=6,M=2)( 
   input [width-1:0] A,
   input [width-1:0] B,
   input clk,rst,
   output reg done,
   output reg [width-1:0] Convout
   );
   
   localparam SIZE_A = (N + 2*padding) * (N + 2*padding);  // total storage
   localparam SIZE_B = (M + 2*padding) * (M + 2*padding);

   reg [width-1:0] Ar [0:SIZE_A-1];  // Flattened 1D array
   reg [width-1:0] Br [0:SIZE_B-1];
   
   
   
//   reg [width-1:0] Ar [0:N-1+2*padding][0:N-1+2*padding];
//   reg [width-1:0] Br [0:M-1+2*padding][0:M-1+2*padding];
   reg Ard,Brd;
   reg [(N+2*padding):0] row_A,col_A;
   reg [SIZE_A-1:0] addr_A;
   reg [(M+2*padding):0] row_B,col_B;
   reg [SIZE_B-1:0] addr_B;
   
   
   
   reg [3:0] j;
   
   reg [3:0] CS,NS ;
   
   
   
   
   
   
localparam S_0  = 4'b0000;
localparam S_1  = 4'b0001;
localparam S_2  = 4'b0010;
localparam S_3  = 4'b0011;
localparam S_4  = 4'b0100;
localparam S_5  = 4'b0101;
localparam S_6  = 4'b0110;
localparam S_7  = 4'b0111;
localparam S_8  = 4'b1000;
localparam S_9  = 4'b1001;
localparam S_10 = 4'b1010;
localparam S_11 = 4'b1011;
localparam S_12 = 4'b1100;
localparam S_13 = 4'b1101;
localparam S_14 = 4'b1110;
localparam S_15 = 4'b1111;

   integer k;
   integer out_x, out_y;
   integer i;
 
   always@(posedge clk) begin
      if (rst==1)begin
         CS<=S_0;
         end
      else    
         CS<=NS;
      end
      
   always@(posedge clk)begin       
     case(CS)
     S_0: begin
            
             done<=0;
           for (k = 0; k < SIZE_A; k = k+1)begin
                 Ar[k] <= 0;
                 end
           for (k = 0; k < SIZE_B; k = k+1)begin
                 Br[k] <= 0;
                 end
           for (i = 0; i < ((N-M)/stride+1)*((N-M)/stride+1); i = i+1) begin
                Convout[i] <= 0; end        
        Ard<=0; 
        Brd<=0;
        row_A<=0;
        col_A<=0;
        addr_A<=0;
        row_B<=0;col_B<=0;
        addr_B<=0;
        j<=0;
         end
     
         
     S_1: begin     
             addr_A <= row_A * (N+2*padding) + col_A;
          end
          
     S_2: begin     
              if (row_A >= padding && row_B < N+padding &&
                col_A >= padding && col_B < N+padding) begin
                Ar[addr_A] <= A;// N*N central region
              end
              else begin
                   end
          end         
     S_3: begin if (col_A == (N+2*padding)-1) begin
                col_A <= 0;
                end
                else begin
                col_A <= col_A + 1;
                end
          end     
     S_4: begin     
            if (row_A == (N+2*padding)-1) begin
                    row_A <= 0;
                    Ard <= 1;   // finished loading
                end else begin
                    row_A <= row_A + 1;
                end
          end
          
      S_5: begin  
               if(j<=SIZE_B) begin
                 Br[j]<=B;  
               end
               else begin
               end
            end
            
      S_6: begin      
             j<=j+1;
           end
      S_7: begin     
           
      
           end
      
//     S_5: begin     
//             addr_B <= row_B * (M+2*padding) + col_B;
//          end
          
//     S_6: begin     
//              if (row_B >= padding && row_B < M+padding &&
//                col_B >= padding && col_B < M+padding) begin
//                Br[addr_B] <= B;// N*N central region
//              end
//              else begin
//                   end
//          end         
//     S_7: begin if (col_B == (M+2*padding)-1) begin
//                col_B<= 0;
//                end
//                else begin
//                col_B <= col_B + 1;
//                end
//          end     
//     S_8: begin     
//            if (row_B == (M+2*padding)-1) begin
//                    row_B <= 0;
//                    Brd <= 1;   // finished loading
//                end else begin
//                    row_B <= row_B + 1;
//                end
//          end    
     S_9: begin
               
                
          end
     endcase     
   end  
   
    always@(*)begin       
     case(CS)
     S_0: begin
            NS=S_1;
         end
    S_1: begin     
             NS=S_2;
          end
    S_2: begin     
             NS=S_3;
          end         
    S_3: begin if (col_A == (N+2*padding)-1) begin
               NS=S_4;
                end
                else begin
               NS=S_1;
                end
          end     
     S_4: begin     
            if (row_A == (N+2*padding)-1) begin
                  NS=S_5  ; // finished loading
                end 
                else begin
                 NS=S_1;
                end
          end
     S_5: begin     
             NS=S_6;
          end
          
     S_6: begin     
             NS=S_7;
          end         
     S_7: begin if (col_B == (M+2*padding)-1) begin
             NS=S_8;
                end
                else begin
             NS=S_5;
                end
          end     
     S_8: begin     
            if (row_B == (M+2*padding)-1) begin
                 NS=S_9;  // finished loading
                end else begin
                 NS=S_4;
                end
          end   
          
     S_9:begin   
                   
           
          end
     endcase     
   end  
   
   
                   
                   
//             if (i<(N) & k<padding) begin
//                Ar[i][k]<=A;
//                   end
//             else 
//                  begin
//                Ard<=1;
//                  end
   endmodule
