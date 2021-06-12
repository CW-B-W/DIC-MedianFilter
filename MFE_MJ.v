module MFE(clk, reset, ready, busy, iaddr, idata, data_rd, addr, data_wr, wen);

input              clk, reset;
input              ready;

output reg         busy;
output reg  [13:0] iaddr;   
input       [ 7:0] idata;                                                    /* data in Grayscale Image MEM */
input       [ 7:0] data_rd;                                                  /* data in Result MEM */
output reg  [13:0] addr;
output reg  [ 7:0] data_wr;
output reg         wen;

reg         [ 7:0] mat [8:0];
reg         [ 3:0] mat_rec_idx;                                              /* the idx of currently reading mat elem */
reg                req_sent;
wire               req_done = mat_rec_idx >= 8;
                                                                             /* coordinate variable should be 8-bit, i.e., {sign, 0~127} */
reg  signed [ 7:0] x_center;                                                 /* the x-coordinate of image which is being processed */ 
reg  signed [ 7:0] y_center;                                                 /* the y-coordinate of image which is being processed */
wire signed [ 7:0] x_req  = x_center + (mat_rec_idx+req_sent) / 4'd3 - 4'd1; /* the x-coordinate of requesting pixel */
wire signed [ 7:0] y_req  = y_center + (mat_rec_idx+req_sent) % 4'd3 - 4'd1; /* the y-coordinate of requesting pixel */
wire signed [ 7:0] x_rec  = x_center + (mat_rec_idx)          / 4'd3 - 4'd1; /* the x-coordinate of received pixel */
wire signed [ 7:0] y_rec  = y_center + (mat_rec_idx)          % 4'd3 - 4'd1; /* the y-coordinate of received pixel */

reg         [ 7:0] mat_for_sort [8:0];
reg         [ 3:0] sort_idx;
reg         [ 7:0] sort_a;
reg         [ 7:0] sort_b;
reg         [ 7:0] sort_c;
reg         [ 7:0] sort_s0;
reg         [ 7:0] sort_s1;
reg         [ 7:0] sort_s2;

parameter S_IDLE   =  0;
parameter S_RD     =  1;
parameter S_SORT_R =  2;
parameter S_SORT_C =  3;
parameter S_SORT_D =  4;
parameter S_SORT_E =  5;
parameter S_WR     =  6;
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
            x_center    <= 0;
            y_center    <= 0;
            mat_rec_idx <= 0;
            req_sent    <= 0;
        end

        S_RD: begin
            if (!req_done) begin
                wen      <= 0;
                busy     <= 1;
                req_sent <= 1;
                if (!(x_req < 0 || x_req >= 128 || y_req < 0 || y_req >= 128)) begin
                    iaddr <= (y_req << 7) | x_req;
                end
            end

            if (req_sent) begin
                for (i = 0; i < 9-1; i = i + 1) begin
                    mat[i]          <= mat[i+1];
                    mat_for_sort[i] <= mat[i+1];
                end

                if (x_rec < 0 || x_rec >= 128 || y_rec < 0 || y_rec >= 128) begin
                    mat[8]          <= 0;
                    mat_for_sort[8] <= 0;
                end
                else begin
                    mat[8]          <= idata;
                    mat_for_sort[8] <= idata;
                end

                if (mat_rec_idx == 8) begin
                    mat_rec_idx <= 6;
                    sort_idx    <= 0;
                    req_sent    <= 0;
                end
                else begin
                    mat_rec_idx <= mat_rec_idx + 4'd1;
                end
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
                mat_rec_idx <= 0;
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
                n_state = S_RD;
        end

        S_RD: begin
            if (mat_rec_idx == 8)
                n_state = S_SORT_R;
            else
                n_state = S_RD;
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
                n_state = S_RD;
        end

        default: begin
        end
    endcase
end


endmodule
