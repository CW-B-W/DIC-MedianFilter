module MFE(clk, reset, ready, busy, iaddr, idata, data_rd, addr, data_wr, wen);

input             clk, reset;
input             ready;

output reg        busy;
output reg [13:0] iaddr;
input      [ 7:0] idata;
input      [ 7:0] data_rd;
output reg [13:0] addr;
output reg [ 7:0] data_wr;
output reg        wen;



endmodule