module spram_daisy_chain(
    input logic clk,
    input logic [15:0] addr,
    input logic we,
    input logic [15:0] data_in,
    output logic [15:0] data_out
);
    logic [1:0] block_select;
    logic [15:0] data_outs [3:0];

    always_ff @(posedge clk) begin
        block_select <= addr[15:14];
        data_out <= data_outs[block_select];
    end

    genvar i;
    generate;
        for (i = 0; i < 4; i++) begin
            logic [13:0] inst_addr;
            logic [15:0] inst_data_out;
            logic inst_we = we && (block_select == i);

            assign inst_addr = addr[13:0];

            SB_SPRAM256KA spram_inst(
                .ADDRESS(inst_addr),
                .DATAIN(data_in),
                .MASKWREN({inst_we, inst_we, inst_we, inst_we}),
                .WREN(inst_we),
                .CHIPSELECT(1'd1),
                .CLOCK(clk),
                .STANDBY(1'd0),
                .SLEEP(1'd0),
                .POWEROFF(1'd1),
                .DATAOUT(inst_data_out)
            );

            always_ff @(posedge clk)
                data_outs[i] <= inst_data_out;
        end
    endgenerate
endmodule

module framebuffer(
    input logic clk,
    input logic rst,
    input logic we, input logic [7:0] wx, input logic [7:0] wy, input logic [11:0] wc,
    input logic re, input logic [7:0] rx, input logic [7:0] ry, output logic [11:0] rc
);
    localparam WIDTH = 256;
    localparam HEIGHT = 256;

    typedef enum {
        IDLE,
        READ,
        WRITE
    } fb_state;

    logic [15:0] addr;
    logic spram_we;
    logic [15:0] data_in;
    logic [15:0] data_out;

    spram_daisy_chain spram(
        .clk(clk),
        .addr(addr),
        .we(spram_we),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    fb_state state;
    logic [2:0] cycle_counter;

    initial begin
        state <= IDLE;
        cycle_counter <= 0;
    end

    always @(posedge clk) begin
        if (rst)
            state <= IDLE;

        if (state == IDLE) begin
            if (re) begin                
                state <= READ;
                cycle_counter <= 1;

                addr <= ry * WIDTH + rx;
                spram_we <= 1'b0;
                data_in <= 0;
            end else if (we) begin
                state <= WRITE;
                cycle_counter <= 1;

                addr <= wy * WIDTH + wx;
                spram_we <= 1'b1;
                data_in <= { 4'd0, wc };
            end
        end

        if (state != IDLE) begin
            cycle_counter <= cycle_counter - 1;

            if (cycle_counter == 1)
                state <= IDLE;
        end
    end

    assign rc = data_out[11:0];
endmodule
