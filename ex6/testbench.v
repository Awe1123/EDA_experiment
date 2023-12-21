`timescale 1ns/1ns

module test6;
  reg clk, rstn;
  reg RXD;
  wire TXD, led0, led1;
  
  test_uart test_uart(
    .clk(clk), 
    .rstn(rstn), 
    .TXD(TXD), 
    .RXD(RXD), 
    .led0(led0), 
    .led1(led1)
  );
  
  always begin
    clk = 1'b1;
    #10 clk = 1'b0;
    #10;
  end
  
  initial begin
    rstn = 1'b0;
    #100 rstn = 1'b1;
  end

  // TESTBENCH TX
  reg [7:0]	txdata[0:10];
  integer	tx_i;
  initial begin
    RXD = 1'b1;
	wait(rstn);
    #100;
	
	for (tx_i=0;tx_i<=10;tx_i=tx_i+1) begin
		txdata[tx_i] = 8'h11*tx_i;
		uart_txbyte(txdata[tx_i]);
		#(208333*2);
	end
	$display("TESTBENCH TX: %x %x %x %x %x %x %x %x %x %x %x\n", txdata[0],txdata[1],txdata[2],txdata[3],txdata[4],txdata[5],txdata[6],txdata[7],txdata[8],txdata[9],txdata[10]);
	
  end
  
  // TESTBENCH RX
  reg [7:0]	rxdata[0:10];
  integer	rx_i;
  initial begin
	wait(rstn);
    #100;
	for (rx_i=0;rx_i<=10;rx_i=rx_i+1) begin
		uart_rxbyte(rxdata[rx_i]);
	end
	$display("TESTBENCH RX: %x %x %x %x %x %x %x %x %x %x %x\n", rxdata[0],rxdata[1],rxdata[2],rxdata[3],rxdata[4],rxdata[5],rxdata[6],rxdata[7],rxdata[8],rxdata[9],rxdata[10]);

	#1000;
	$stop;
  end
  
  	task uart_txbyte;
		input       [7:0]	    i_data;
        integer                 i;

		`ifdef PARITY_CHECK
		integer                 one_cnt;
		`endif
	begin
		`ifdef PARITY_CHECK
		one_cnt = 0;
		`endif

 //     $display("TESTBENCH TX: will send one byte : %x\n", i_data);

  		#208333; 
  		RXD = 1'b0;

        for (i=7; i>=0; i=i-1) begin
  			#208333;          
  			RXD = i_data[i];
			
			`ifdef PARITY_CHECK
			if (i_data[i])
				one_cnt = one_cnt + 1;
			`endif
		end

		`ifdef PARITY_CHECK
  		#208333;          
		if (one_cnt[0])
  			RXD = 1'b0;
		else
  			RXD = 1'b1;
		`endif

  		#208333;          
  		RXD = 1'b1;
    end
    endtask
	
	task uart_rxbyte;
		output       [7:0]	    o_data;
		integer                 i;
		`ifdef PARITY_CHECK
		integer                 one_cnt;
		`endif
	begin
        wait(!TXD);
  		#208333; 


        o_data = 8'h00;
        for (i=7; i>=0; i=i-1) begin
  			#104333;          
            o_data[i] = TXD;
			`ifdef PARITY_CHECK
			if (TXD)
				one_cnt = one_cnt + 1;
			`endif
  			#104000;          
		end

		`ifdef PARITY_CHECK
  		#104333;          
        if (one_cnt[0] == TXD) begin
            $display("TESTBENCH RX: Odd bit is wrong!\n");
			#100;
            $stop;
        end
  		#104000;    
		`endif		

  		#104333;          
        if (!TXD) begin
            $display("TESTBENCH RX: Stop bit is wrong!\n");
			#100;
            $stop;
        end
  		#104000;          

//      $display("TESTBENCH RX: Received one byte : %x\n", o_data);
    end
    endtask
endmodule