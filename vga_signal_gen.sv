/*
    All values are taken from http://tinyvga.com/vga-timing
 */

//`define VGA_640_480_75
//`ifdef VGA_640_480_75
//`define X_V 640
//`define X_F 24
//`define X_S 40
//`define X_B 128
//`define X_W 832

//`define Y_V 480
//`define Y_F 9
//`define Y_S 2
//`define Y_B 29
//`define Y_W 520
//`endif

module vga_signal_gen(
    input logic pixel_clk,
    input logic rst,
    output logic [10:0] x, output logic [10:0] y, output logic is_visible, output logic is_new_frame,
    output logic h_sync, output logic v_sync
);
    logic is_visible_x, is_visible_y;

    localparam X_V = 640;
    localparam X_F = 24;
    localparam X_S = 40;
    localparam X_B = 128;
    localparam X_W = 832;

    localparam Y_V = 480;
    localparam Y_F = 9;
    localparam Y_S = 2;
    localparam Y_B = 29;
    localparam Y_W = 520;

    always_ff @(posedge pixel_clk) begin
        if (rst) begin
            x <= 0;
            y <= 0;
        end

        if (x == X_W - 1) begin
            x <= 0;

            if (y == Y_W - 1)
                y <= 0;
            else
                y <= y + 1;
        end else begin
            x <= x + 1;
        end

        if (x == X_V + X_F - 1)
            h_sync <= 0;

        if (x == X_V + X_F + X_S - 1)
            h_sync <= 1;

        if (y == Y_V + Y_F - 1)
            v_sync <= 0;

        if (y == Y_V + Y_F + Y_S - 1)
            v_sync <= 1;

        if (x == 0)
            is_visible_x <= 1;
        
        if (x == X_V - 1)
            is_visible_x <= 0;

        if (y == 0)
            is_visible_y <= 1;
        
        if (y == Y_V - 1)
            is_visible_y <= 0;
    
        is_new_frame <= x == X_W - 1 && y == Y_W - 1;
    end

    assign is_visible = is_visible_x && is_visible_y;

endmodule
