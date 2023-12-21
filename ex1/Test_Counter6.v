
module Test_Counter6 ;
  reg  U;           //Up/Down inputs      
  reg  CLK, CLR_;   //Clock and Reset
  wire  CO,BO;      //output  
  wire [2:0]  Q;    //Register output

  Counter6 U0(CLK,CLR_,U,Q,CO,BO); //???????
  
  initial begin     // CLR_
    CLR_ = 1'b0;
    CLR_ = #10 1'b1;
    #360 $stop;
  end 
  
  always begin    // CLK
    CLK = 1'b0;
    CLK = #10 1'b1;
    #10;
  end 
  
  initial begin   //U
    U = 1'b0;
    #190;
    U = 1'b1;
  end 
endmodule

