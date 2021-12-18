// FPGA video driver project 2019
// Antonio Sánchez

module VideoText(
	input MAX10_CLK1_50,
	input PS2_KEYBOARD_CLK,
	input PS2_KEYBOARD_DAT,
	output [7:0] LED,
	// output [3:0]cc,
	// output [7:0]anode,
	// input disp_mode,
	
	output VGA_VS,
	output VGA_HS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
);

assign LED[7:5]=4'b1111;
assign LED[4]=~NewKey;

wire NewKey;
wire [7:0] Ascii;
wire [10:0] mem_addr;
wire [15:0] mem_data;
wire [15:0] ret_data;
wire we;


// //7 Segment Display 
// wire [7:0] intanode;
// assign anode=~intanode;
// wire [7:0]value;
// reg [12:0]display_prescaler;
// wire display_clk;
// assign display_clk=display_prescaler[12];

// always @(posedge MAX10_CLK1_50)
// display_prescaler<=display_prescaler+1'b1;

Keyb_Driver Teclado(
	.sys_clk(MAX10_CLK1_50),
	.PS2Clk(PS2_KEYBOARD_CLK),
	.PS2Data(PS2_KEYBOARD_DAT),
	.Result (Ascii),
	.NewKey(NewKey),
	.Key_LeftShift(LED[0]),
	.Key_RightShift(LED[1]),
	.Key_AltGR(LED[2]),
	.Key_CapsLock (LED[3]));

Text_Editor Editor(
	.sys_clk(MAX10_CLK1_50),
	.NewKey(NewKey),
	.Ascii(Ascii),
	.mem_addr(mem_addr),
	.mem_data(mem_data),
	.we(we),
	.ret_data(ret_data));	 
	 
Video_Driver Video(
	.sys_clk(MAX10_CLK1_50),
	.we(we),
	.mem_addr(mem_addr),
	.mem_data(mem_data),
	.ret_data(ret_data),
	.VSync(VGA_VS),
	.HSync(VGA_HS),
	.Red(VGA_R),
	.Green(VGA_G),
	.Blue(VGA_B));	 
	 
//  outdisplay Display(
// 	.clk(display_clk),
// 	.disp_mode(disp_mode),
//    .int_reg(Ascii),
//    .cc(cc),
//    .anode(intanode)
//   );

endmodule
