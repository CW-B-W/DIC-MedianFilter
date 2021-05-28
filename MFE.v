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

parameter S0 = 0;
reg [x:0] state;
reg [x:0] n_state;

always @(posedge clk or posedge rst) begin
    state <= n_state;
end

always @(*) begin
    if (reset) begin
        
    end
    else begin
        
    end
end

always @(*) begin
    if (reset) begin
        
        
    end
    else
        
    end
end


endmodule