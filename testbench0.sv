`timescale 1 ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2021 11:49:00
// Design Name: 
// Module Name: testbench_v0
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


module testbench_v0 ();

    localparam CLK_PERIOD_SYS  = 10;
    
    wire  [3:0] led_4bits_tri_o;
    reg         clk_sys, reset;
    
    always #(CLK_PERIOD_SYS/2)  clk_sys  <= ~clk_sys;

    initial
    begin
    	clk_sys <= 1'b0;
        reset   = 1'b0; // Active-low reset
        repeat (1000) @(posedge clk_sys) begin end; // Wait 1000 clock cycles to allow the processor to complete reset
        reset   <= 1'b1;
    end
    
    pullup i_led_4bits_pu[3:0] (led_4bits_tri_o); // LEDs are driven by tri-state.  Add pull-ups
    
    design_1_wrapper DUT (
        .reset                      (reset),      
        .led_4bits_tri_o            (led_4bits_tri_o),
        .sys_clock                  (clk_sys)
    );
      
endmodule
