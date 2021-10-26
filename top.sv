`include "vga_controller.sv"

module top(input clk,
           output hsync, output vsync,
           output r0, output r1, output r2, output r3,
           output g0, output g1, output g2, output g3,
           output b0, output b1, output b2, output b3,
           output logic LED_R, output logic LED_G, output logic LED_B
);
    vga_controller controller(
        clk, 1'd0,
        hsync, vsync,
        { r3, r2, r1, r0 },
        { g3, g2, g1, g0 },
        { b3, b2, b1, b0 },
        LED_R, LED_G, LED_B
    );
endmodule
