module MFE(clk, reset, ready, busy, iaddr, idata, data_rd, addr, data_wr, wen);

input              clk, reset;
input              ready;

output reg         busy;
output reg  [13:0] iaddr;   
input       [ 7:0] idata;                         /* data in Grayscale Image MEM */
input       [ 7:0] data_rd;                       /* data in Result MEM */
output reg  [13:0] addr;
output reg  [ 7:0] data_wr;
output reg         wen;

reg         [ 7:0] mat [8:0];
reg         [ 3:0] mat_rd_idx;                    /* the idx of currently reading mat elem */
                                                  /* coordinate variable should be 8-bit, i.e., {sign, 0~127} */
reg  signed [ 7:0] x_center;                      /* the x-coordinate of image which is being processed */ 
reg  signed [ 7:0] y_center;                      /* the y-coordinate of image which is being processed */
wire signed [ 1:0] dx = mat_rd_idx / 4'd3 - 4'd1; /* the offset from x_center */
wire signed [ 1:0] dy = mat_rd_idx % 4'd3 - 4'd1; /* the offset from y_center */
wire signed [ 7:0] x  = x_center + dx;
wire signed [ 7:0] y  = y_center + dy;

reg         [ 7:0] mat_for_sort [8:0];
reg         [ 3:0] sort_idx;
reg         [ 7:0] sort_a;
reg         [ 7:0] sort_b;
reg         [ 7:0] sort_c;
reg         [ 7:0] sort_s0;
reg         [ 7:0] sort_s1;
reg         [ 7:0] sort_s2;

parameter S_IDLE   =  0;
parameter S_RD_REQ =  1;
parameter S_RD_RES =  2;
parameter S_SORT_R =  3;
parameter S_SORT_C =  4;
parameter S_SORT_D =  5;
parameter S_SORT_E =  6;
parameter S_WR     =  7;
reg [2:0] state;
reg [2:0] n_state;

integer i;

task sort_2;
    input  [7:0] a, b;
    output [7:0] s0, s1;
    begin
        if (a < b) begin
            s0 = a;
            s1 = b;
        end
        else begin
            s0 = b;
            s1 = a;
        end
    end
endtask

task sort_3;
    input  [7:0] a, b, c;
    output [7:0] s0, s1, s2;
    begin
        if (a <= c && b <= c) begin
            s2 = c;
            sort_2(a, b, s0, s1);
        end
        else begin
            if (a <= b) begin /* a <= c <  b */
                s2 = b;
                sort_2(a, c, s0, s1);
            end
            else begin
                s2 = a;
                sort_2(b, c, s0, s1);
            end
        end
    end
endtask

always @(posedge clk or posedge reset) begin
    if (reset)
        state <= S_IDLE;
    else
        state <= n_state;
end

always @(posedge clk) begin
    case (state)
        S_IDLE: begin
            busy <= 0;
            x_center   <= 0;
            y_center   <= 0;
            mat_rd_idx <= 0;
        end

        S_RD_REQ: begin
            wen  <= 0;
            busy <= 1;
            if (!(x < 0 || x >= 128 || y < 0 || y >= 128)) begin
                iaddr <= (y << 7) | x;
            end
        end

        S_RD_RES: begin
            for (i = 0; i < 9-1; i = i + 1) begin
                mat[i]          <= mat[i+1];
                mat_for_sort[i] <= mat[i+1];
            end

            if (x < 0 || x >= 128 || y < 0 || y >= 128) begin
                mat[8]          <= 0;
                mat_for_sort[8] <= 0;
            end
            else begin
                mat[8]          <= idata;
                mat_for_sort[8] <= idata;
            end

            if (mat_rd_idx == 8) begin
                mat_rd_idx <= 6;
                sort_idx   <= 0;
            end
            else begin
                mat_rd_idx <= mat_rd_idx + 4'd1;
            end
        end

        S_SORT_R: begin
            case (sort_idx)
                0: begin
                    sort_a <= mat_for_sort[0];
                    sort_b <= mat_for_sort[1];
                    sort_c <= mat_for_sort[2];
                    sort_idx <= 1;
                end

                1: begin
                    mat_for_sort[0] <= sort_s0;
                    mat_for_sort[1] <= sort_s1;
                    mat_for_sort[2] <= sort_s2;
                    sort_a <= mat_for_sort[3];
                    sort_b <= mat_for_sort[4];
                    sort_c <= mat_for_sort[5];
                    sort_idx <= 2;
                end

                2: begin
                    mat_for_sort[3] <= sort_s0;
                    mat_for_sort[4] <= sort_s1;
                    mat_for_sort[5] <= sort_s2;
                    sort_a <= mat_for_sort[6];
                    sort_b <= mat_for_sort[7];
                    sort_c <= mat_for_sort[8];
                    sort_idx <= 3;
                end

                3: begin
                    mat_for_sort[6] <= sort_s0;
                    mat_for_sort[7] <= sort_s1;
                    mat_for_sort[8] <= sort_s2;
                    sort_idx <= 4;
                end

                default: begin
                end
            endcase
        end

        S_SORT_C: begin
            case (sort_idx)
                4: begin
                    sort_a <= mat_for_sort[0];
                    sort_b <= mat_for_sort[3];
                    sort_c <= mat_for_sort[6];
                    sort_idx <= 5;
                end

                5: begin
                    mat_for_sort[0] <= sort_s0;
                    mat_for_sort[3] <= sort_s1;
                    mat_for_sort[6] <= sort_s2;
                    sort_a <= mat_for_sort[1];
                    sort_b <= mat_for_sort[4];
                    sort_c <= mat_for_sort[7];
                    sort_idx <= 6;
                end

                6: begin
                    mat_for_sort[1] <= sort_s0;
                    mat_for_sort[4] <= sort_s1;
                    mat_for_sort[7] <= sort_s2;
                    sort_a <= mat_for_sort[2];
                    sort_b <= mat_for_sort[5];
                    sort_c <= mat_for_sort[8];
                    sort_idx <= 7;
                end

                7: begin
                    mat_for_sort[2] <= sort_s0;
                    mat_for_sort[5] <= sort_s1;
                    mat_for_sort[8] <= sort_s2;
                    sort_idx <= 8;
                end

                default: begin
                end
            endcase
        end

        S_SORT_D: begin
            case (sort_idx)
                8: begin
                    sort_a <= mat_for_sort[2];
                    sort_b <= mat_for_sort[4];
                    sort_c <= mat_for_sort[6];
                    sort_idx <= 9;
                end

                9: begin
                    mat_for_sort[2] <= sort_s0;
                    mat_for_sort[4] <= sort_s1;
                    mat_for_sort[6] <= sort_s2;
                    sort_idx <= 0;
                end

                default: begin
                end
            endcase
        end

        S_SORT_E: begin
            sort_3(sort_a, sort_b, sort_c, sort_s0, sort_s1, sort_s2);
        end

        S_WR: begin
            addr    <= (y_center << 7) | x_center;
            data_wr <= mat_for_sort[4];
            wen     <= 1;

            if (x_center == 127) begin
                x_center   <= 0;
                y_center   <= y_center + 8'd1;
                mat_rd_idx <= 0;
            end
            else begin
                x_center   <= x_center + 8'd1;
            end
        end

        default: begin
        end
    endcase
end

always @(*) begin
    n_state = S_IDLE;
    case (state)
        S_IDLE: begin
            if (reset)
                n_state = S_IDLE;
            else
                n_state = S_RD_REQ;
        end

        S_RD_REQ: begin
            n_state = S_RD_RES;
        end

        S_RD_RES: begin
            if (mat_rd_idx == 8)
                n_state = S_SORT_R;
            else
                n_state = S_RD_REQ;
        end

        S_SORT_R: begin
            if (sort_idx == 3)
                n_state = S_SORT_C;
            else
                n_state = S_SORT_E;
        end

        S_SORT_C: begin
            if (sort_idx == 7)
                n_state = S_SORT_D;
            else
                n_state = S_SORT_E;
        end

        S_SORT_D: begin
            if (sort_idx == 9)
                n_state = S_WR;
            else
                n_state = S_SORT_E;
        end

        S_SORT_E: begin
            if (sort_idx <= 3)
                n_state = S_SORT_R;
            else if (sort_idx <= 7)
                n_state = S_SORT_C;
            else
                n_state = S_SORT_D;
        end

        S_WR: begin
            if (x_center == 127 && y_center == 127)
                n_state = S_IDLE;
            else
                n_state = S_RD_REQ;
        end

        default: begin
        end
    endcase
end


endmodule
