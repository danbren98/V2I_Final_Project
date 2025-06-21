interface spi_if (input logic clk, input logic rst_n);
    logic ssn;
    logic sclk;
    logic mosi;
    logic miso;

    // Modport for SPI master (e.g., driver or DUT)
    modport master (
        output ssn, sclk, mosi,
        input  miso
    );

    // Modport for SPI slave (e.g., peripheral or monitor)
    modport slave (
        input  ssn, sclk, mosi,
        output miso
    );
endinterface
