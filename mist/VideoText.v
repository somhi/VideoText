// FPGA video driver project 2019
// Antonio Sánchez

module VideoText (
   input  	 CLOCK_27,

   // LED outputs
   output 	 LED, // LED Yellow
	
   // SDRAM interface
   inout  [15:0] SDRAM_DQ, // SDRAM Data bus 16 Bits
   output [12:0] SDRAM_A, // SDRAM Address bus 13 Bits
   output 	 SDRAM_DQML, // SDRAM Low-byte Data Mask
   output 	 SDRAM_DQMH, // SDRAM High-byte Data Mask
   output 	 SDRAM_nWE, // SDRAM Write Enable
   output 	 SDRAM_nCAS, // SDRAM Column Address Strobe
   output 	 SDRAM_nRAS, // SDRAM Row Address Strobe
   output 	 SDRAM_nCS, // SDRAM Chip Select
   output [1:0]  SDRAM_BA, // SDRAM Bank Address
   output 	 SDRAM_CLK, // SDRAM Clock
   output 	 SDRAM_CKE, // SDRAM Clock Enable
  
   // SPI interface to arm io controller
   output 	 SPI_DO,
   input 	 SPI_DI,
   input 	 SPI_SCK,
   input 	 SPI_SS2,
   input 	 SPI_SS3,
   input 	 SPI_SS4,
   input 	 CONF_DATA0, 

//    output 	 AUDIO_L, // sigma-delta DAC output left
//    output 	 AUDIO_R, // sigma-delta DAC output right

   output 	     VGA_HS,
   output 	     VGA_VS,
   output [5:0]  VGA_R,
   output [5:0]  VGA_G,
   output [5:0]  VGA_B

//    input     UART_RX,
//    output    UART_TX
);

assign LED=NewKey;

wire sys_clk;
wire PS2Clk;
wire PS2Data;
wire vga_blank;

pll PLL_inst(
    .inclk0(CLOCK_27),
//    .c0(clk48),    
    .c1(sys_clk)		// 50 MHz
);    

assign LED=NewKey;

wire NewKey;
wire [7:0] Ascii;
wire [10:0] mem_addr;
wire [15:0] mem_data;
wire [15:0] ret_data;
wire we;

// //7 Segment Display 
// wire [3:0]cc;		//output
// wire [7:0]anode;	    //output
// wire disp_mode;		//input

// wire [7:0] intanode;
// assign anode=~intanode;
// wire [7:0]value;
// reg [12:0]display_prescaler;
// wire display_clk;
// assign display_clk=display_prescaler[12];

// always @(posedge sys_clk)
// display_prescaler<=display_prescaler+1'b1;

Keyb_Driver Teclado(
	.sys_clk(sys_clk),
	.PS2Clk (PS2Clk),
	.PS2Data(PS2Data),
	.Result (Ascii),
	.NewKey (NewKey),
	// .Key_LeftShift(Leds[0]),
	// .Key_RightShift(Leds[1]),
	// .Key_AltGR(Leds[2]),
	// .Key_CapsLock (Leds[3])
);

Text_Editor Editor(
	.sys_clk(sys_clk),
	.NewKey(NewKey),
	.Ascii(Ascii),
	.mem_addr(mem_addr),
	.mem_data(mem_data),
	.we(we),
	.ret_data(ret_data),
    .reset(reset)
);	 
	 
Video_Driver Video_inst (
	.sys_clk(sys_clk),         
	.we(we),
	.mem_addr(mem_addr),
	.mem_data(mem_data),
	.ret_data(ret_data),
	.VSync(video_vs),
	.HSync(video_hs),
	.Red(video_r[5:2]),
	.Green(video_g[5:2]),
	.Blue(video_b[5:2]),
    .vga_blank(vga_blank)
);	  


//  outdisplay Display(
// 	.clk(display_clk),
// 	.disp_mode(disp_mode),
//    .int_reg(Ascii),
//    .cc(cc),
//    .anode(intanode)
//   );


// MIST STUFF

//`include "build_id.v"

// the configuration string is returned to the io controller to allow
// it to control the menu on the OSD 
parameter CONF_STR = {
        "Z80_SOC;;",
        "O1,SCREEN,ON,OFF;",
        "T2,Reset;"   //,
//        "V,v1.0.",`BUILD_DATE
};

parameter CONF_STR_LEN = 9+17+8;

// the status register is controlled by the on screen display (OSD)
wire [63:0] status;

// include user_io module for arm controller communication
user_io #(.STRLEN(CONF_STR_LEN)) user_io ( 
    .conf_str   ( CONF_STR   ),
    .clk_sys    ( sys_clk    ),    

    .SPI_CLK    ( SPI_SCK    ),
    .SPI_SS_IO  ( CONF_DATA0 ),
    .SPI_MISO   ( SPI_DO     ),
    .SPI_MOSI   ( SPI_DI     ),

    .ps2_kbd_clk ( PS2Clk    ),     
    .ps2_kbd_data( PS2Data   ),     

    .status      ( status    )
);

wire [5:0] video_r, video_g, video_b;
wire video_hs, video_vs;

wire [5:0] video_r_o, video_g_o, video_b_o;
assign video_r_o = status[1] ?  6'b0 : video_r;
assign video_g_o = status[1] ?  6'b0 : video_g;
assign video_b_o = status[1] ?  6'b0 : video_b;

// include the on screen display
osd #(0,0,4) osd (
   .clk_sys ( sys_clk      ),

   // spi for OSD
   .SPI_DI  ( SPI_DI       ),
   .SPI_SCK ( SPI_SCK      ),
   .SPI_SS3 ( SPI_SS3      ),

   .R_in    ( video_r_o      ),
   .G_in    ( video_g_o      ),
   .B_in    ( video_b_o      ),
   .HSync   ( video_hs     ),
   .VSync   ( video_vs     ),

   .R_out   ( VGA_R    ),
   .G_out   ( VGA_G    ),
   .B_out   ( VGA_B    )
);
                          
assign VGA_HS = video_hs;
assign VGA_VS = video_vs;

wire reset;
assign reset = 	status[0] || status[2];

endmodule
