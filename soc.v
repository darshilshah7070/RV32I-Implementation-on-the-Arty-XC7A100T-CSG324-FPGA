module Memory (
    input clk,
    input [31:0] mem_addr, //address to read/write
    output reg [31:0] mem_rdata, //data to be read by CPU
    input mem_read_signal,// high when cpu wants to read
    input [31:0] mem_wdata,
    input [3:0] mem_wmask //it will simplify store
);

reg [31:0] MEM [0:1535]; // 1536 4-bytes words = 6 Kb of RAM in total

   initial begin
       $readmemh("firmware.hex",MEM);
   end


wire [29:0] word_addr = mem_addr[31:2]; //>>2 or /4 for word allignment

//simplified idea for load/store (taken from picorrv)
always @(posedge clk) begin
    if(mem_read_signal) mem_rdata<=MEM[word_addr];

    if(mem_wmask[0]) MEM[word_addr][7:0] <= mem_wdata[7:0];
    if(mem_wmask[1]) MEM[word_addr][15:8] <= mem_wdata[15:8];
    if(mem_wmask[2]) MEM[word_addr][23:16] <= mem_wdata[23:16];
    if(mem_wmask[3]) MEM[word_addr][31:24] <= mem_wdata[31:24];

end
endmodule

module Processor (
    input clk,
    input reset,
    output [31:0] mem_addr,
    input [31:0] mem_rdata,
    output mem_read_signal,
    output [31:0] mem_wdata,
    output [3:0] mem_wmask
);

reg [31:0] pc=0;
reg [31:0] instr;

//---------------------------DECODER----------------------------------------


//Optimization 1: we can only focus on the 6:2 because last 2 bits are always 1
//which type of instruction by the opcode(only 10 different)
wire isReg     =  (instr[6:2] == 5'b01100); // rd <- rs1 OP rs2   
wire isImm     =  (instr[6:2] == 5'b00100); // rd <- rs1 OP Iimm
wire isBranch  =  (instr[6:2] == 5'b11000); // if(rs1 OP rs2) PC<-PC+Bimm
wire isJALR    =  (instr[6:2] == 5'b11001); // rd <- PC+4; PC<-rs1+Iimm
wire isJAL     =  (instr[6:2] == 5'b11011); // rd <- PC+4; PC<-PC+Jimm
wire isAUIPC   =  (instr[6:2] == 5'b00101); // rd <- PC + Uimm
wire isLUI     =  (instr[6:2] == 5'b01101); // rd <- Uimm   
wire isLoad    =  (instr[6:2] == 5'b00000); // rd <- mem[rs1+Iimm]
wire isStore   =  (instr[6:2] == 5'b01000); // mem[rs1+Simm] <- rs2
wire isSYSTEM  =  (instr[6:2] == 5'b11100); // special 


// The 5 immediate formats (help taken from RVALP)
wire [31:0] Uimm={instr[31:12], {12{1'b0}}};
wire [31:0] Iimm={{21{instr[31]}}, instr[30:20]};
wire [31:0] Simm={{21{instr[31]}}, instr[30:25],instr[11:7]};
wire [31:0] Bimm={{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
wire [31:0] Jimm={{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};

// Source and destination registers
wire [4:0] rs1Id = instr[19:15];
wire [4:0] rs2Id = instr[24:20];
wire [4:0] rdId  = instr[11:7];

// function codes
wire [2:0] funct3 = instr[14:12];
wire [6:0] funct7 = instr[31:25];


//--------------------------Register Bank--------------------------------

 //register bank (using all 32 registers)
reg [31:0] RegisterBank[31:0]; //BRAM
reg [31:0] rs1,rs2;//thiese are values //dont confuse with id
wire [31:0] writeBackData;
wire        writeBackEn;


//TB purpose for initializing all regiersters 0
`ifdef TB
   integer     i;
   initial begin
      for(i=0; i<32; ++i) begin
	 RegisterBank[i] = 0;
      end
   end
`endif 


//-------------------------------ALU------------------------------------

wire [31:0] aluIn1 = rs1; //we know one input is fix from RB
wire [31:0] aluIn2 = isReg ? rs2 : Iimm; //mux
reg [31:0] aluOut;
wire [4:0] shamt = isReg ? rs2[4:0] : instr[24:20];

//by funct3 we can identify alll operations
always @(*) begin
    case(funct3)
    3'b000: aluOut = (funct7[5] & instr[5]) ? //also consdiering immediate
			 (aluIn1 - aluIn2) : (aluIn1 + aluIn2);
	3'b001: aluOut = aluIn1 << shamt;
	3'b010: aluOut = ($signed(aluIn1) < $signed(aluIn2));
	3'b011: aluOut = (aluIn1 < aluIn2);
	3'b100: aluOut = (aluIn1 ^ aluIn2);
	3'b101: aluOut = funct7[5]? ($signed(aluIn1) >>> shamt) : 
			 ($signed(aluIn1) >> shamt); 
	3'b110: aluOut = (aluIn1 | aluIn2);
	3'b111: aluOut = (aluIn1 & aluIn2);	
    endcase
end


//--------------------------------Branch---------------------------------
//can be optimized if it is inside an ALU
reg yesBranch;
   always @(*) begin
    case(funct3)
	3'b000: yesBranch = (rs1 == rs2);
	3'b001: yesBranch = (rs1 != rs2);
	3'b100: yesBranch = ($signed(rs1) < $signed(rs2));
	3'b101: yesBranch = ($signed(rs1) >= $signed(rs2));
	3'b110: yesBranch = (rs1 < rs2);
	3'b111: yesBranch = (rs1 >= rs2);
	default: yesBranch = 1'b0; //avoiding latch
    endcase
  end


//---------------------------MUX for selecting output-----------------------------

assign writeBackData = (isJAL || isJALR) ? (pc +4) : (isLUI) ? Uimm :(isAUIPC) ? (pc + Uimm) : (isLoad) ? LOAD_data : aluOut;

assign writeBackEn = (state==EXECUTE && !isBranch && !isStore && !isLoad) ||(state==WAIT_DATA) ; 


//--------------------------Incrementer-----------------------------

wire [31:0] next_pc = (isBranch && yesBranch) ? pc+Bimm : isJAL ? pc+Jimm :isJALR ? rs1+Iimm : pc+4;

//------------------------------Load---------------------------------

wire [31:0] loadstore_addr = rs1 + (isStore ? Simm : Iimm); 
wire mem_byteAccess     = funct3[1:0] == 2'b00;
wire mem_halfwordAccess = funct3[1:0] == 2'b01;


wire [15:0] LOAD_halfword =loadstore_addr[1] ? mem_rdata[31:16] : mem_rdata[15:0];

wire[7:0] LOAD_byte = loadstore_addr[0] ? LOAD_halfword[15:8] : LOAD_halfword[7:0];

wire LOAD_sign =!funct3[2] & (mem_byteAccess ? LOAD_byte[7] : LOAD_halfword[15]);

wire [31:0] LOAD_data = mem_byteAccess ? {{24{LOAD_sign}},LOAD_byte} : mem_halfwordAccess ? {{16{LOAD_sign}}, LOAD_halfword} : mem_rdata ;


//----------------------------------Store----------------------------

assign mem_wdata[ 7: 0] = rs2[7:0];
assign mem_wdata[15: 8] = loadstore_addr[0] ? rs2[7:0]  : rs2[15: 8];
assign mem_wdata[23:16] = loadstore_addr[1] ? rs2[7:0]  : rs2[23:16];
assign mem_wdata[31:24] = loadstore_addr[0] ? rs2[7:0]  :loadstore_addr[1] ? rs2[15:8] : rs2[31:24];

wire [3:0] STORE_wmask = mem_byteAccess ? (loadstore_addr[1] ? (loadstore_addr[0] ? 4'b1000 : 4'b0100) : (loadstore_addr[0] ? 4'b0010 : 4'b0001)) : mem_halfwordAccess ? (loadstore_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111;



//-------------------------------FSM---------------------------------

localparam FETCH_INSTR = 0;
localparam WAIT_INSTR  = 1;
localparam FETCH_REGS  = 2;
localparam EXECUTE     = 3;
localparam LOAD        = 4;
localparam WAIT_DATA   = 5;
localparam STORE       = 6;
reg [2:0] state = FETCH_INSTR;

   always @(posedge clk) begin
      if(reset) begin
	 pc    <= 0;
	 state <= FETCH_INSTR;
      end else begin
	 if(writeBackEn && rdId != 0) begin
	    RegisterBank[rdId] <= writeBackData;
	 
	 case(state)
       FETCH_INSTR: begin
	      state <= WAIT_INSTR;
	   end
	   WAIT_INSTR: begin
	      instr <= mem_rdata;
	      state <= FETCH_REGS;
	   end
	   FETCH_REGS: begin
	      rs1 <= RegisterBank[rs1Id];
	      rs2 <= RegisterBank[rs2Id];
	      state <= EXECUTE;
	   end
	   EXECUTE: begin
	      if(!isSYSTEM) begin
		 pc <= next_pc;
	      end
	      state <= isLoad ? LOAD : isStore ? STORE : FETCH_INSTR;

`ifdef TB
	      if(isSYSTEM) $finish();
`endif
	   end
       LOAD: begin
	      state <= WAIT_DATA;
	   end
	   WAIT_DATA: begin
	      state <= FETCH_INSTR;
	   end
       STORE: begin
	      state <= FETCH_INSTR;
	   end
	 endcase
      end
   end

assign mem_addr = (state == WAIT_INSTR || state == FETCH_INSTR) ? pc : loadstore_addr ;
assign mem_read_signal = (state == FETCH_INSTR || state == LOAD);
assign mem_wmask = {4{(state == STORE)}} & STORE_wmask;

//---------------------------------TB--------------------------------------

`ifdef TB   
   always @(posedge clk) begin
    if(state == FETCH_REGS) begin
      case (1'b1)
	isReg: $display("REGISTER");
	isImm: $display("IMMEDIATE");
	isBranch: $display("BRANCH");
	isJAL:    $display("JAL");
	isJALR:   $display("JALR");
	isAUIPC:  $display("AUIPC");
	isLUI:    $display("LUI");	
	isLoad:   $display("LOAD");
	isStore:  $display("STORE");
	isSYSTEM: $display("SYSTEM");
      endcase 
  end
   end`endif	    
endmodule

//----------------------------SOC------------------------------------
module SOC (
    input  clk,        // system clock
    input  reset,      // reset button
    output [3:0] LEDS // system LEDs
    input  RXD,        // UART receive
    output TXD         // UART transmit
);
    

   wire [31:0] mem_addr;
   wire [31:0] mem_rdata;
   wire mem_read_signal;
   wire [31:0] mem_wdata;
   wire [3:0]  mem_wmask;

   Processor CPU(
      .clk(clk),
      .reset(reset),
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .mem_read_signal(mem_read_signal),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask)
   );
   //IO
   wire [31:0] RAM_rdata;
   wire [29:0] mem_wordaddr = mem_addr[31:2];
   wire isIO  = mem_addr[22];
   wire isRAM = !isIO;
   wire mem_wstrb = |mem_wmask;
   
   Memory RAM(
      .clk(clk),
      .mem_addr(mem_addr),
      .mem_rdata(RAM_rdata),
      .mem_read_signal(isRAM & mem_read_signal),
      .mem_wdata(mem_wdata),
      .mem_wmask({4{isRAM}}&mem_wmask)
   );
   
     // Memory-mapped IO in IO page, 1-hot addressing in word address.   
   localparam IO_LEDS_bit      = 0;  // W five leds
   localparam IO_UART_DAT_bit  = 1;  // W data to send (8 bits) 
   localparam IO_UART_CNTL_bit = 2;  // R status. bit 9: busy sending
   
   always @(posedge clk) begin
      if(isIO & mem_wstrb & mem_wordaddr[IO_LEDS_bit]) begin
	 LEDS <= mem_wdata;
//	 $display("Value sent to LEDS: %b %d %d",mem_wdata,mem_wdata,$signed(mem_wdata));
      end
   end

   wire uart_valid = isIO & mem_wstrb & mem_wordaddr[IO_UART_DAT_bit];
   wire uart_ready;
   
    corescore_emitter_uart #(
      .clk_freq_hz(100*1000000),//100MHz for XC7a100tcsg324
      .baud_rate(115200)
      
   ) UART(
      .i_clk(clk),
      .i_rst(!resetn),
      .i_data(mem_wdata[7:0]),
      .i_valid(uart_valid),
      .o_ready(uart_ready),
      .o_uart_tx(TXD)      			       
   );

   wire [31:0] IO_rdata = 
	       mem_wordaddr[IO_UART_CNTL_bit] ? { 22'b0, !uart_ready, 9'b0}
	                                      : 32'b0;
   
   assign mem_rdata = isRAM ? RAM_rdata :
	                      IO_rdata ;
   
    Clockworks CW(
     .CLK(CLK),
     .RESET(RESET),
     .clk(clk),
     .resetn(resetn)
   );
   
   endmodule











