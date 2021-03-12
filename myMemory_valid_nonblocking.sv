`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2021 18:33:38
// Design Name: 
// Module Name: myMemory
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


module myMemory
(
    input  wire                   clk,
    input  wire                   rstn,
    
    input wire [13-1:0]           s_axi_awaddr,
    input wire [2:0]              s_axi_awprot,
    output wire                   s_axi_awready,
    input wire                    s_axi_awvalid,
    input wire                    s_axi_bready,
    output wire [1:0]              s_axi_bresp,
    output wire                   s_axi_bvalid,
    input wire [32-1:0]           s_axi_wdata,
    output wire                   s_axi_wready,

    input wire                    s_axi_wvalid,   
    input  wire [13-1:0]  		  s_axi_araddr,
    input  wire [2:0]             s_axi_arprot,
    input  wire                   s_axi_arvalid,
    output wire                   s_axi_arready,
    input  wire [3:0]             s_axi_wstrb,
    output reg  [32-1:0]  	      s_axi_rdata,
    output wire [1:0]             s_axi_rresp,
    output reg                   s_axi_rvalid,
    input  wire                   s_axi_rready
);

     
    localparam IDLE = 0, WAIT_ARVALID = 1, SEND_DATA = 2, WAIT_AWVALID = 3, WAIT_VALID_DATA = 4, WAIT_RESP = 5;
    localparam MEM_NUM_LINE= 8*1024;
    parameter VMEM_FILE = "C:/ES1_Project/Finali/my_axi_memory/hardware/bram_a7.hex";
    reg [2:0] state_read_port;
    reg [2:0] state_write_port;

    /*(* ram_style = "distributed" *)*/  reg [31:0]  memTb   [0:MEM_NUM_LINE-1];
    wire reset;

    
	initial
    begin
        $readmemh(VMEM_FILE, memTb);
    end
    //load the memory with readmemh

    assign reset = ~rstn;   
    //dataflow assignments 
	assign s_axi_arready = (state_read_port == WAIT_ARVALID) ? 1 : 0;
	//assign s_axi_rvalid  = (state_read_port == SEND_DATA) ? 1 : 0;
	assign s_axi_rresp   = 2'b00;

    assign s_axi_awready = (state_write_port == WAIT_AWVALID) ? 1 : 0;
    assign s_axi_wready  =  (state_write_port == WAIT_VALID_DATA) ? 1 : 0;
    assign s_axi_bvalid  =  (state_write_port == WAIT_RESP) ? 1 : 0;
    assign s_axi_bresp = 2'b00;
    //assign s_axi_rdata = memTb[s_axi_araddr>>2]; 

	//--------------------
    

     
    always @(posedge clk, posedge reset) begin
        if (reset)
            state_read_port <= IDLE;
        else 
            case (state_read_port) 
                IDLE : begin
                    state_read_port <= WAIT_ARVALID;
                    s_axi_rvalid <= 0;
                end
                
    			WAIT_ARVALID: begin
                    s_axi_rvalid <= 0;					

    				state_read_port <= WAIT_ARVALID;
    				if (s_axi_arvalid) begin
    					state_read_port <= SEND_DATA;  
    					s_axi_rdata <= memTb[s_axi_araddr>>2];  
    					s_axi_rvalid <= 1;					
                    end    
                end
                
    			SEND_DATA: begin
    				state_read_port <= SEND_DATA;
                    s_axi_rvalid <= 0;
    				if(s_axi_rready)
    					state_read_port <= WAIT_ARVALID;
    			end
    			
    			default: 
    			    begin 
    			    state_read_port <= IDLE; 
                    s_axi_rvalid <= 0;
                    end
    		endcase
     end 

   /* always @(posedge clk, posedge reset) begin
        if (reset)
            state_write_port <= IDLE;
        else 
            case (state_write_port)
                IDLE : begin
                    state_write_port <= WAIT_AWVALID;
                end

                WAIT_AWVALID : begin
                    if (s_axi_awvalid) begin
                        state_write_port <= WAIT_VALID_DATA;
                    end
                end

                WAIT_VALID_DATA : begin
                    if (s_axi_wvalid) begin
                        memTb[s_axi_awaddr>>2] <= s_axi_wdata;
             
                        state_write_port <= WAIT_RESP;
                    end
                end

                WAIT_RESP : begin
                    if (s_axi_bready) begin
                        state_write_port <= WAIT_AWVALID;
                    end
                end
                
                default:  
    			    state_write_port <= IDLE; 

        endcase
     end*/
endmodule
