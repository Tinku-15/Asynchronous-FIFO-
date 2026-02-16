`timescale 1ns/1ps

module async_fifo #(
    parameter DATA_WIDTH = 64,
    parameter DEPTH = 1024
)(
    // write domain
    input  wire wr_clk,
    input  wire wr_rst,
    input  wire wr_en,
    input  wire [DATA_WIDTH-1:0] din,
    output wire wr_full,
    output wire wr_empty,

    // read domain
    input  wire rd_clk,
    input  wire rd_rst,
    input  wire rd_en,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire rd_full,
    output wire rd_empty
);

    initial if ((DEPTH & (DEPTH-1)) != 0)
        $fatal("DEPTH must be power of 2");

    localparam AW = $clog2(DEPTH);

    // memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // pointers
    reg [AW:0] wr_bin=0, wr_gray=0;
    reg [AW:0] rd_bin=0, rd_gray=0;

    // sync pointers
    reg [AW:0] rd_gray_w1=0, rd_gray_w2=0;
    reg [AW:0] wr_gray_r1=0, wr_gray_r2=0;

    function [AW:0] bin2gray(input [AW:0] b);
        bin2gray = (b>>1) ^ b;
    endfunction

    // =========================================================
    // WRITE DOMAIN
    // =========================================================

    wire [AW:0] wr_bin_next  = wr_bin + 1;
    wire [AW:0] wr_gray_next = bin2gray(wr_bin_next);

    // full detect
    assign wr_full =
        (wr_gray_next ==
        {~rd_gray_w2[AW:AW-1], rd_gray_w2[AW-2:0]});

    // empty as seen by write side
    assign wr_empty = (wr_gray == rd_gray_w2);

    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            wr_bin<=0; wr_gray<=0;
        end else if (wr_en && !wr_full) begin
            mem[wr_bin[AW-1:0]] <= din;
            wr_bin  <= wr_bin_next;
            wr_gray <= wr_gray_next;
        end
    end

    // sync read pointer ? write domain
    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            rd_gray_w1<=0; rd_gray_w2<=0;
        end else begin
            rd_gray_w1<=rd_gray;
            rd_gray_w2<=rd_gray_w1;
        end
    end

    // =========================================================
    // READ DOMAIN
    // =========================================================

    wire [AW:0] rd_bin_next  = rd_bin + 1;
    wire [AW:0] rd_gray_next = bin2gray(rd_bin_next);

    // empty detect
    assign rd_empty = (rd_gray == wr_gray_r2);

    // full as seen by read side
    assign rd_full =
        (wr_gray_r2 ==
        {~rd_gray[AW:AW-1], rd_gray[AW-2:0]});

    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            rd_bin<=0; rd_gray<=0; dout<=0;
        end else if (rd_en && !rd_empty) begin
            dout    <= mem[rd_bin[AW-1:0]];
            rd_bin  <= rd_bin_next;
            rd_gray <= rd_gray_next;
        end
    end

    // sync write pointer ? read domain
    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            wr_gray_r1<=0; wr_gray_r2<=0;
        end else begin
            wr_gray_r1<=wr_gray;
            wr_gray_r2<=wr_gray_r1;
        end
    end

endmodule
