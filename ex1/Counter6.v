
module Counter6 (CP,CLR_,U,Q,CO,BO);
    input CP, CLR_, U;  
    output reg [2:0] Q; //Data output
    output CO,BO;
    
    assign CO = U & (Q == 3'd5);
    assign BO = ~U & (Q == 3'd0) & (CLR_== 1'b1);
    
    always @ (posedge CP or negedge CLR_)
      if (~CLR_) 
          Q <= 3'b000;            //asynchronous clear
      else if (U==1)              //U=1,Up Counter
          Q <= (Q + 1'b1)%6; 
      else  if (Q == 3'b000)
          Q <= 3'd5; 
      else                        //U=0,Down Counter
          Q <= (Q - 1'b1)%6;
endmodule
