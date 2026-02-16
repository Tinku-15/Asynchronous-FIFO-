`timescale 1ns/1ps

module async_fifo_tb;

parameter DATA_WIDTH = 64;
parameter DEPTH      = 1024;
parameter BEATS      = 5;

reg wr_clk=0;
reg rd_clk=0;
reg wr_rst=1;
reg rd_rst=1;

reg wr_en=0;
reg rd_en=0;

reg  [63:0] din;
wire [63:0] dout;

wire wr_full, wr_empty;
wire rd_full, rd_empty;

// DUT
async_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (
    wr_clk, wr_rst, wr_en, din, wr_full, wr_empty,
    rd_clk, rd_rst, rd_en, dout, rd_full, rd_empty
);

// clocks
//always #4   wr_clk = ~wr_clk;
//always #3.2 rd_clk = ~rd_clk;
always #3.2 wr_clk = ~wr_clk;   // faster write
always #4   rd_clk = ~rd_clk;   // slower read

// reset
initial begin
    #20 wr_rst=0;
        rd_rst=0;
end

// scoreboard
reg [63:0] exp[0:10000];
integer w=0;
integer r=0;

reg [63:0] pipe;
reg valid;
reg pass_printed=0;

// WRITE
always @(posedge wr_clk)
if (!wr_rst && w<BEATS && !wr_full) begin
    din <= {$random,$random};
    exp[w] = din;
    wr_en <= 1;
    w = w+1;
end else wr_en<=0;

// READ
always @(posedge rd_clk) begin
    if (rd_rst) begin
        rd_en<=0; valid<=0;
    end else begin
        rd_en<=!rd_empty;

        if (!rd_empty && r<BEATS) begin
            pipe<=exp[r];
            valid<=1;
            r=r+1;
        end else valid<=0;

        if (valid && dout!==pipe) begin
            $display("ERROR at %0d", r-1);
        end
    end
end

// PASS message (no finish)
always @(posedge rd_clk)
if (!pass_printed &&
    w==BEATS &&
    r==BEATS &&
    rd_empty &&
    !valid)
begin
    $display("================================");
    $display("FIFO PASS - %0d beats verified", BEATS);
    $display("Simulation continues running...");
    $display("================================");
    pass_printed = 1;
end

// waveform
initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, async_fifo_tb);
end

endmodule
