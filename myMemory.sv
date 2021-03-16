`timescale 1ns / 1ps


module myMemory #(
    parameter MEM_DEPTH = 8*1024,
    parameter LOG2_MEM_DEPTH = 13,
    parameter MEM_WIDTH = 32,
    parameter VMEM_FILE = "/home/chiara/Documenti/vivadoData/2019.1/project_fakemem_tbimpl2/bram_a7.hex"
) (
    input  wire                               clk,
    input  wire                               rstn,
    
    
    // Write AXI4-LITE Port
    input  wire [LOG2_MEM_DEPTH-1:0]          s_axi_awaddr,
    output wire                               s_axi_awready,
    input  wire                               s_axi_awvalid,
    input  wire                               s_axi_bready,
    output wire [1:0]                         s_axi_bresp,
    output wire                               s_axi_bvalid,
    input  wire [MEM_WIDTH-1:0]               s_axi_wdata,
    output wire                               s_axi_wready,
    input  wire                               s_axi_wvalid,
    input  wire [2:0]                         s_axi_awprot,   
    input  wire [3:0]                         s_axi_wstrb,
    
    
    // Read AXI4-LITE Port
    input  wire                               s_axi_arvalid,
    output wire                               s_axi_arready,
    input  wire [LOG2_MEM_DEPTH-1:0]          s_axi_araddr,
    input  wire [2:0]                         s_axi_arprot,    
    output wire [1:0]                         s_axi_rresp,
    output reg  [MEM_WIDTH-1:0]               s_axi_rdata,
    output wire                               s_axi_rvalid,
    input  wire                               s_axi_rready
);

    // Read FSM states definition
    localparam IDLE_R = 2'b00, WAIT_ARVALID = 2'b01, SEND_DATA = 2'b10;
    // Write FSM states definition
    localparam IDLE_W = 2'b00, WAIT_AWVALID = 2'b01, WAIT_VALID_DATA = 2'b10, WAIT_WRESP_READY = 2'b11;
    
    reg [2:0] state_read_port;
    reg [2:0] state_write_port;
    // Memory structure, which is implemented in LUTs
    (* ram_style = "distributed" *) reg [MEM_WIDTH-1:0] memTb [0:MEM_DEPTH-1];

    // Dataflow assignments for Read Port
    assign s_axi_arready = (state_read_port == WAIT_ARVALID) ? 1 : 0;
    assign s_axi_rvalid  = (state_read_port == SEND_DATA) ? 1 : 0;
    assign s_axi_rresp   = 2'b00;

    
    // Dataflow assignments for Write Port
    assign s_axi_awready = (state_write_port == WAIT_AWVALID) ? 1 : 0;
    assign s_axi_wready  = (state_write_port == WAIT_VALID_DATA) ? 1 : 0;
    assign s_axi_bvalid  = (state_write_port == WAIT_WRESP_READY) ? 1 : 0;
    assign s_axi_bresp   = 2'b00;
    
  
    // Read FSM
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin   
            $readmemh(VMEM_FILE, memTb); // Load the memory with VMEM_FILE file
            state_read_port <= IDLE_R;
        end
        else 
            case (state_read_port) 
                IDLE_R : begin 
                    state_read_port <= WAIT_ARVALID;
                end
                
                WAIT_ARVALID: begin 
                    if (s_axi_arvalid) begin // If valid read address is on the bus
                        state_read_port <= SEND_DATA;  
                        s_axi_rdata <= memTb[s_axi_araddr>>2]; // Put requested data on the bus from memory             
                    end    
                end
                
                SEND_DATA: begin
                    if(s_axi_rready) // If handshake happened
                        state_read_port <= WAIT_ARVALID; // Wait for new read requests
                end
                
                default:  
                    state_read_port <= IDLE_R; 

            endcase
    end 

    
    // Write FSM 
    always @(posedge clk, negedge rstn) begin
        if (rstn)
            state_write_port <= IDLE_W;
        else 
            case (state_write_port)
                IDLE_W : begin
                    state_write_port <= WAIT_AWVALID;
                end

                WAIT_AWVALID : begin
                    if (s_axi_awvalid) begin // If valid write address is on the bus
                        state_write_port <= WAIT_VALID_DATA; // wait now for valid data
                    end
                end

                WAIT_VALID_DATA : begin
                    if (s_axi_wvalid) begin // If valid data to be writted arrived
                        memTb[s_axi_awaddr>>2] <= s_axi_wdata; // Put them into memory
                        state_write_port <= WAIT_WRESP_READY; // Wait for wresp_ready to be set
                    end
                end

                WAIT_WRESP_READY : begin
                    if (s_axi_bready) begin // If wresp handshake has arrived
                        state_write_port <= WAIT_AWVALID; // Wait for new write requests
                    end
                end
                
                default:  
                    state_write_port <= IDLE_W; 

        endcase
    end
    
endmodule
