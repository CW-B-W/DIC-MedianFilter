module MFE(clk, reset, ready, busy, iaddr, idata, data_rd, addr, data_wr, wen);

input              clk, reset;
input              ready;

output reg         busy;
output reg  [13:0] iaddr;   
input       [ 7:0] idata;                   /* data in Grayscale Image MEM */
input       [ 7:0] data_rd;                 /* data in Result MEM */
output reg  [13:0] addr;
output reg  [ 7:0] data_wr;
output reg         wen;

reg         [ 7:0] mat [8:0];
reg         [ 3:0] mat_rd_idx;              /* the idx of currently reading mat elem */
reg         [ 7:0] median;
                                            /* coordinate variable should be 8-bit, i.e., {sign, 0~127} */
reg  signed [ 7:0] x_center;                /* the x-coordinate of image which is being processed */ 
reg  signed [ 7:0] y_center;                /* the y-coordinate of image which is being processed */
wire signed [ 7:0] dx = mat_rd_idx % 3 - 1; /* the offset from x_center */
wire signed [ 7:0] dy = mat_rd_idx / 3 - 1; /* the offset from y_center */
wire signed [ 7:0] x  = x_center + dx;
wire signed [ 7:0] y  = y_center + dy;

parameter S_IDLE   =  0;
parameter S_RD_REQ =  1;
parameter S_RD_RES =  2;
parameter S_BIT_P1 =  3;
parameter S_BIT_P2 =  4;
parameter S_BIT_P3 =  5;
parameter S_BIT_P4 =  6;
parameter S_BIT_P5 =  7;
parameter S_BIT_P6 =  8;
parameter S_MF     =  9;
parameter S_WR     = 10;
reg [3:0] state;
reg [3:0] n_state;

integer i;

always @(posedge clk or negedge reset) begin
    state <= n_state;
end

always @(*) begin
    if (!reset) begin
        
    end
    else begin
        case (state)
            S_IDLE: begin
                if (ready)
                    busy <= 1;
                else
                    busy <= 0;

                x_center   <= 0;
                y_center   <= 0;
                mat_rd_idx <= 0;
            end

            S_RD_REQ: begin
                /* maybe try if (!(x == -1 || x == 128 || y == -1 || y == 128)) begin ? */
                if (!(x < 0 || x >= 128 || y < 0 || y >= 128)) begin
                    iaddr <= (x << 7) | y;
                end
            end

            S_RD_RES: begin
                /* maybe try if (x == -1 || x == 128 || y == -1 || y == 128) begin ? */
                if (x < 0 || x >= 128 || y < 0 || y >= 128) begin
                    mat[mat_rd_idx] <= 0;
                end
                else begin
                    mat[mat_rd_idx] <= idata;
                end

                if (mat_rd_idx == 8) begin
                    mat_rd_idx <= 0;
                end
                else begin
                    mat_rd_idx <= mat_rd_idx + 1;
                end
            end

            S_BIT_P1: begin
                for (i = 0; i < 8; i = i + 4) begin
                    if (mat[i] > mat[i+1]) begin
                        mat[i]   <= mat[i+1];
                        mat[i+1] <= mat[i];
                    end
                end
                for (i = 2; i < 8; i = i + 4) begin
                    if (mat[i] < mat[i+1]) begin
                        mat[i]   <= mat[i+1];
                        mat[i+1] <= mat[i];
                    end
                end
            end

            S_BIT_P2: begin
                for (i = 0; i < 2; i = i + 1) begin
                    if (mat[i] > mat[i+2]) begin
                        mat[i]   <= mat[i+2];
                        mat[i+2] <= mat[i];
                    end
                end
                for (i = 4; i < 6; i = i + 1) begin
                    if (mat[i] < mat[i+2]) begin
                        mat[i]   <= mat[i+2];
                        mat[i+2] <= mat[i];
                    end
                end
            end

            S_BIT_P3: begin
                for (i = 0; i < 4; i = i + 2) begin
                    if (mat[i] > mat[i+1]) begin
                        mat[i]   <= mat[i+1];
                        mat[i+1] <= mat[i];
                    end
                end
                for (i = 4; i < 8; i = i + 2) begin
                    if (mat[i] < mat[i+1]) begin
                        mat[i]   <= mat[i+1];
                        mat[i+1] <= mat[i];
                    end
                end
            end

            S_BIT_P4: begin
                for (i = 0; i < 4; i = i + 1) begin
                    if (mat[i] > mat[i+4]) begin
                        mat[i]   <= mat[i+4];
                        mat[i+4] <= mat[i];
                    end
                end
            end

            S_BIT_P5: begin
                for (i = 0; i < 2; i = i + 1) begin
                    if (mat[i] > mat[i+2]) begin
                        mat[i]   <= mat[i+2];
                        mat[i+2] <= mat[i];
                    end
                end
                for (i = 4; i < 6; i = i + 1) begin
                    if (mat[i] > mat[i+2]) begin
                        mat[i]   <= mat[i+2];
                        mat[i+2] <= mat[i];
                    end
                end
            end

            S_BIT_P6: begin
                for (i = 0; i < 8; i = i + 2) begin
                    if (mat[i] > mat[i+1]) begin
                        mat[i]   <= mat[i+1];
                        mat[i+1] <= mat[i];
                    end
                end
            end

            S_MF: begin
                /* Finished Bitonic sorter with mat[7:0], note that mat[8] will be now */

                /* one of mat[3], mat[4] or mat[8] is the median */
                /* if mat[3] <= mat[8] <= mat[4], then mat[8] is the median */
                if (mat[3] < mat[8] && mat[8] < mat[4])
                    median <= mat[8];
                /* if mat[3] <  mat[4] <= mat[8], then mat[4] is the median */
                else if (mat[4] < mat[8])
                    median <= mat[4];
                /* if mat[8] <= mat[3] <  mat[4], then mat[3] is the median */
                else if (mat[8] < mat[3])
                    median <= mat[3];
            end

            S_WR: begin
                addr    <= (x_center << 7) | y_center;
                data_wr <= median;
                wen     <= 1;

                if (x_center == 127) begin
                    x_center <= 0;
                    y_center <= y_center + 1;
                end
                else begin
                    x_center <= x_center + 1;
                end
            end

            default: begin
                $stop;
            end
        endcase
    end
end

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        n_state <= S_IDLE;
    end
    else begin
        case (state)
            S_IDLE: begin
                if (ready)
                    n_state <= S_RD_REQ;
                else
                    n_state <= S_IDLE;
            end

            S_RD_REQ: begin
                n_state <= S_RD_RES;
            end

            S_RD_RES: begin
                if (mat_rd_idx == 8)
                    n_state <= S_BIT_P1;
                else
                    n_state <= S_RD_REQ;
            end

            S_BIT_P1: begin
                n_state <= S_BIT_P2;
            end

            S_BIT_P2: begin
                n_state <= S_BIT_P3;
            end

            S_BIT_P3: begin
                n_state <= S_BIT_P4;
            end

            S_BIT_P4: begin
                n_state <= S_BIT_P5;
            end

            S_BIT_P5: begin
                n_state <= S_BIT_P6;
            end

            S_BIT_P6: begin
                n_state <= S_MF;
            end

            S_MF: begin
                n_state <= S_WR;
            end

            S_WR: begin
                if (x_center == 127 && y_center == 127)
                    n_state <= S_IDLE;
                else
                    n_state <= S_RD_REQ;
            end

            default: begin
                $stop;
            end
        endcase
    end
end


endmodule
