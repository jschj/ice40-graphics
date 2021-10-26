module ball(
    input logic clk, input logic rst,
    output logic [7:0] sx, output logic [6:0] sy, output logic [11:0] color
);
    logic [7:0] x;
    logic [6:0] y;

    logic vx;
    logic vy;

    initial begin
        x <= 1;
        y <= 1;
        vx <= 1;
        vy <= 1;
    end

    always_ff @(posedge clk) begin
        if (vx)
            x <= x + 1;
        else
            x <= x - 1;
        
        if (vy)
            y <= y + 1;
        else
            y <= y - 1;

        if ((x == 0 && !vx) || (x == 255 && vx))
            vx <= !vx;

        if ((y == 0 && !vy) || (y == 127 && vy))
            vy <= !vy;

        color <= color + 1;
    end

    assign sx = x;
    assign sy = y;
endmodule
