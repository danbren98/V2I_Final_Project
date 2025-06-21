module spi_driver #(
	parameter int DATA_WIDTH = 8
) (
	input  logic clk,
	input  logic rst_n,
	input  logic start,                    // Start transaction
	input  logic [DATA_WIDTH-1:0] tx_data, // Data to transmit
	output logic done,                     // Asserted when transmission is complete
	output logic [DATA_WIDTH-1:0] rx_data, // Data received on MISO
	spi_if.master spi                      // SPI master modport interface
);

	typedef enum logic [1:0] {IDLE, START, TRANSFER, DONE} state_t;
	state_t state;

	logic [DATA_WIDTH-1:0] shift_out;
	logic [DATA_WIDTH-1:0] shift_in;
	logic [$clog2(DATA_WIDTH):0] bit_cnt;

	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			spi.sclk   <= 0;
			spi.ssn    <= 1;
			spi.mosi   <= 0;
			shift_out  <= 0;
			shift_in   <= 0;
			bit_cnt    <= 0;
			rx_data    <= 0;
			done       <= 0;
			state      <= IDLE;
		end else begin
			case (state)

				IDLE: begin
					done		<=	0;
					spi.sclk	<=	0;
					spi.ssn		<= ~start;
					if (start) begin
						shift_out	<=	tx_data;
						shift_in	<=	0;
						bit_cnt		<=	0;
						state		<=	START;
					end
				end

				START: begin
					spi.ssn		<=	0;
					spi.mosi	<=	shift_out[DATA_WIDTH-1];
					spi.sclk	<=	1;
					state		<=	TRANSFER;
				end

				TRANSFER: begin
					spi.sclk	<=	~spi.sclk;

					if (spi.sclk == 0) begin
						// Falling edge: load next bit and sample MISO
						shift_in <= {shift_in[DATA_WIDTH-2:0], spi.miso};

						if (bit_cnt < DATA_WIDTH-1) begin
							bit_cnt		<=	bit_cnt + 1;
							shift_out	<=	{shift_out[DATA_WIDTH-2:0], 1'b0};
							spi.ssn		<=	0;
							spi.mosi	<=	shift_out[DATA_WIDTH-2];
						end else begin
							spi.ssn		<=	1;
							state		<=	DONE;
						end
					end
				end

				DONE: begin
					spi.ssn		<=	1;
					spi.sclk	<=	0;
					rx_data		<=	shift_in;
					done		<=	1;
					state		<=	IDLE;
				end

			endcase
		end
	end
endmodule
