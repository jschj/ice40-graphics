`include "vga_signal_gen.sv"
//`include "spram_framebuffer.sv"
`include "spram_fb.sv"


module vga_controller(
    input logic clk, input logic rst,
    output logic hsync, output logic vsync,
    output logic [3:0] r, output logic [3:0] g, output logic [3:0] b
);
    logic pixel_clk;
    logic real_clk;

    SB_PLL40_2_PAD #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),
        .DIVF(7'd83),
        .DIVQ(3'd5),
        .FILTER_RANGE(3'b001)
    ) uut (
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .PACKAGEPIN(clk),
        .PLLOUTGLOBALA(real_clk),
        .PLLOUTGLOBALB(pixel_clk)
    );

    logic [10:0] sx;
    logic [10:0] sy;
    logic o_hsync;
    logic o_vsync;
    logic de;
    logic new_frame;

    vga_signal_gen gen(
        pixel_clk, rst,
        sx, sy, de, new_frame,
        o_hsync, o_vsync);

    logic [3:0] red;
    logic [3:0] green;
    logic [3:0] blue;

    logic [11:0] fb_out;

    logic [7:0] wx;
    logic [6:0] wy;

    initial begin
        wx <= 0;
        wy <= 0;
    end

    /*
    framebuffer fb(
        .clk(pixel_clk),
        .rst(1'b0),
        .we(fill_image), .wx(wx), .wy(wy), .wc({ wx[3:0], wy }),
        .re(!fill_image),
        .rx(sx[7:0]),
        .ry(sy[7:0]),
        .rc(fb_out)

    ); */

    logic [11:0] color;

    spram_fb_double_buffered fb(
        .clk(pixel_clk), .rst(1'b0), .switch_buffers(new_frame),
        .we(1'b1), .wx(wx), .wy(wy), .wc(color),
        .rx(sx[7:0]), .ry(sy[7:0]), .rc(fb_out)
    );

    /* the area outside the framebuffer is black */
    assign red   = (sx[10:8] | sy[10:7]) ? 0 : fb_out[3:0];
    assign green = (sx[10:8] | sy[10:7]) ? 0 : fb_out[7:4];
    assign blue  = (sx[10:8] | sy[10:7]) ? 0 : fb_out[11:8];

    always_ff @(posedge pixel_clk) begin
        if (wx == 255)
            wx <= 0;
        else
            wx <= wx + 1;

        if (wx == 255)
            wy <= wy + 1;
    end

    always_ff @(posedge pixel_clk)
        if (new_frame)
            color <= color + 1;

    always_ff @(posedge pixel_clk) begin
        hsync <= o_hsync;
        vsync <= o_vsync;

        if (de) begin
            r <= red;
            g[3:1] <= green[3:1];
            g[0] <= pixel_clk;
            //g[0] <= 0;
            //g <= {pixel_clk, pixel_clk, pixel_clk, pixel_clk};
            //g <= green;
            b <= blue;
        end else begin
            r <= 0;
            g <= 0;
            b <= 0;
        end
    end
endmodule
