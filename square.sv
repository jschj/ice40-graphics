module square(
    input logic clk, input logic rst,
    output logic [7:0] sx, output logic [6:0] sy, output logic [11:0] color
);
    typedef enum {
        IDLE,
        DRAWING,
        DONE
    } draw_state;

    localparam LEFT = 10;
    localparam RIGHT = 100;
    localparam TOP = 25;
    localparam BOTTOM = 55;

    draw_state state;

    always_ff @(posedge clk) begin
        if (rst) begin
            sx <= LEFT;
            sy <= TOP;
            state <= IDLE;
        end

        if (state == IDLE)
            state <= DRAWING;

        if (state == DRAWING) begin
            if (sx == RIGHT - 1) begin
                sx <= LEFT;
                sy <= sy + 1;
            end else begin
                sx <= sx + 1;
            end

            if (sx == RIGHT - 1 && sy == BOTTOM - 1)
                state <= DONE;
        end
    end

    assign color = 12'hfff;
endmodule
