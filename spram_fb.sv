module spram_2(
    input logic clk,
    input logic [14:0] addr,
    input logic we,
    input logic [15:0] data_in,
    output logic [15:0] data_out
);
    logic block_select;
    logic [15:0] data_outs [1:0];

    always_ff @(posedge clk) begin
        block_select <= addr[14];
        data_out <= data_outs[block_select];
    end

    genvar i;
    generate;
        for (i = 0; i < 2; i++) begin
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

module spram_double_buffered(
    input logic clk, input logic rst,
    input logic switch_banks,
    input logic we, input logic [14:0] w_addr, input logic [15:0] w_data,
    input logic [14:0] r_addr, output logic [15:0] r_data
);
    logic bank_select;

    always_ff @(posedge clk) begin
        if (rst)
            bank_select <= 0;
        else if (switch_banks)
            bank_select <= !bank_select; 
    end

    logic [15:0] data_out_0;
    logic [15:0] data_out_1;

    spram_2 bank_0(
        .clk(clk),
        .addr(!bank_select ? w_addr : r_addr),
        .we(!bank_select ? we : 1'b0),
        .data_in(w_data),
        .data_out(data_out_0)
    );

    spram_2 bank_1(
        .clk(clk),
        .addr(bank_select ? w_addr : r_addr),
        .we(bank_select ? we : 1'b0),
        .data_in(w_data),
        .data_out(data_out_1)
    );

    assign r_data = bank_select ? data_out_0 : data_out_1;

endmodule

module spram_fb_double_buffered(
    input logic clk, input logic rst, input logic switch_buffers,
    input logic we, input logic [7:0] wx, input logic [7:0] wy, input logic [11:0] wc,
    input logic [7:0] rx, input logic [7:0] ry, output logic [11:0] rc
);

    logic spram_we;
    logic [14:0] w_addr;
    logic [15:0] w_data;

    logic [14:0] r_addr;
    logic [15:0] r_data;

    spram_double_buffered spram(
        .clk(clk), .rst(rst), .switch_banks(switch_buffers),
        .we(spram_we), .w_addr(w_addr), .w_data(w_data),
        .r_addr(r_addr), .r_data(r_data)
    );

    always_ff @(posedge clk) begin
        if (we) begin
            w_addr <= wy * 256 + wx;
            w_data <= { 4'd0, wc };
        end

        r_addr <= ry * 256 + rx;
        spram_we <= we;
    end

    assign rc = r_data[11:0];

endmodule
