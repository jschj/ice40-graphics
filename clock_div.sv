module clock_div #(
    parameter DIV = 0
) (
    input logic clk,
    output logic clk_slow
);
    logic [$clog2(DIV):0] counter;

    always @(posedge clk) begin
        if (counter == 0)
            counter <= DIV;
        else
            counter <= counter - 1;
    end

    assign clk_slow = clk && (counter == 0);

endmodule
