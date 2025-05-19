module counter_7seg (
    input clk,             // 50 MHz system clock
    input [2:0] KEY,       // KEY[0]=reset, KEY[1]=count up, KEY[2]=count down (all active-low)
    output reg [6:0] HEX0, // 7-segment display output
    output [3:0] LEDR      // Show full binary count on LEDs
);

    reg [3:0] count = 0;

    // Synchronizers for edge detection of KEY1 and KEY2
    reg [1:0] key1_sync = 2'b11;
    reg [1:0] key2_sync = 2'b11;

    // Assign count to LEDR
    assign LEDR = count;

    // Synchronize buttons to clock domain
    always @(posedge clk) begin
        key1_sync <= {key1_sync[0], KEY[1]};
        key2_sync <= {key2_sync[0], KEY[2]};
    end

    // Edge detection (falling edge = button press)
    wire key1_edge = (key1_sync[1] & ~key1_sync[0]); // count up
    wire key2_edge = (key2_sync[1] & ~key2_sync[0]); // count down

    // Counter logic
    always @(posedge clk) begin
        if (~KEY[0])  // Reset (active-low)
            count <= 0;
        else if (key1_edge) begin
            if (count == 9)
                count <= 0;
            else
                count <= count + 1;
        end
        else if (key2_edge) begin
            if (count == 0)
                count <= 9;
            else
                count <= count - 1;
        end
    end

    // 7-segment decoder (active-low)
    always @(*) begin
        case (count)
            4'd0: HEX0 = 7'b100_0000;
            4'd1: HEX0 = 7'b111_1001;
            4'd2: HEX0 = 7'b010_0100;
            4'd3: HEX0 = 7'b011_0000;
            4'd4: HEX0 = 7'b001_1001;
            4'd5: HEX0 = 7'b001_0010;
            4'd6: HEX0 = 7'b000_0010;
            4'd7: HEX0 = 7'b111_1000;
            4'd8: HEX0 = 7'b000_0000;
            4'd9: HEX0 = 7'b001_0000;
            default: HEX0 = 7'b111_1111;
        endcase
    end

endmodule
