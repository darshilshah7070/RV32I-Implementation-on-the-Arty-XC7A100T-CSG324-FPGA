   
 
`include "mypll.v"



module Clockworks 
(
   input  CLK, // clock pin of the board
   input  RESET, // reset pin of the board
   output clk,   // (optionally divided) clock for the design.
                 // divided if SLOW is different from zero.
   output resetn // (optionally timed) negative reset for the design
);               
   parameter SLOW=0;

   generate

/****************************************************

 Slow speed mode.
 - Create a clock divider to let observe what happens.
 - Nothing special to do for reset
 
 ****************************************************/
      if(SLOW != 0) begin

`ifdef BENCH
   localparam slow_bit=SLOW-4;
`else
   localparam slow_bit=SLOW;
`endif
	 reg [slow_bit:0] slow_CLK = 0;
	 always @(posedge CLK) begin
	    slow_CLK <= slow_CLK + 1;
	 end
	 assign clk = slow_CLK[slow_bit];


	 assign resetn = !RESET;



	 
      end else begin 
	

        assign clk=CLK;



	 reg [15:0] 	    reset_cnt = 0;
 
	 assign resetn = &reset_cnt;
 
	 always @(posedge clk,posedge RESET) begin
	    if(RESET) begin
	       reset_cnt <= 0;
	    end else begin
	       /* verilator lint_off WIDTH */
	       reset_cnt <= reset_cnt + !resetn;
	       /* verilator lint_on WIDTH */	       
	    end
	 end

      end
   endgenerate

endmodule
