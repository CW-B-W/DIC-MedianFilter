`timescale 1ns/10ps
`define CYCLE      25.0          	  // Modify your clock period here
`define End_CYCLE  100000000              // Modify cycle times once your design need more cycle times!
`define PAT         "img.dat"
`define L0_EXP0     "golden.dat"     
module testfixture;
    reg	[7:0]	PAT	[0:16383];
    reg	[7:0]	L0_EXP0	[0:16383];  
    reg	[7:0]	L0_MEM0	[0:16383]; 
    reg		reset = 0;
    reg		clk = 0;
    reg		ready = 0;
    wire	[13:0]	iaddr;
    reg		[7:0]	idata;
    wire	[7:0]	data_wr;
    reg		[7:0]	data_rd;
    wire	[13:0]	addr;
    wire		wen; // 0 read 1 write
    reg		check0=0;

    integer		p0, p1, p2;
    integer		err00, err01, err10;
    integer		pat_num;

    MFE u_mfe(
        .clk(clk),
		.reset(reset),
		.busy(busy),	
		.ready(ready),	
		.iaddr(iaddr),
		.idata(idata),
        .data_rd(data_rd),
        .data_wr(data_wr),
        .addr(addr),
        .wen(wen)
    );

    always begin #(`CYCLE/2) clk = ~clk; end
        initial begin  // global control
	    $display("-----------------------------------------------------\n");
 	    $display("START!!! Simulation Start .....\n");
 	    $display("-----------------------------------------------------\n");
		reset = 1'b1;
   	    #(`CYCLE*2);  #1;   reset = 1'b0;  
    end
	initial begin
		wait(busy == 0); @(negedge clk); #1;  ready = 1'b1;
		 wait(busy == 1);#(`CYCLE/4); ready = 1'b0;
	end

    initial begin // initial pattern and expected result
	    wait(reset==1);
	    wait ((ready==1) && (busy ==0) ) begin
		    $readmemh(`PAT, PAT);
            $readmemh(`L0_EXP0, L0_EXP0);
	    end	
    end
    
    always@(negedge clk) begin // generate the stimulus input data
	#1;
	if ((ready == 0) & (busy == 1)) idata <= PAT[iaddr];
	else idata <= 'hx;
	end
    always@(negedge clk) begin
	    if (wen == 0) begin
			data_rd <= L0_MEM0[addr] ;
	    end
    end

    always@(posedge clk) begin 
		if (wen == 1) begin
			check0 <= 1; 
			L0_MEM0[addr] <= data_wr; 
            if (addr == 128) begin
                err00 = 0;
                for (p0 = 0; p0 < 127; p0 = p0 + 1) begin
                    if (L0_MEM0[p0] != L0_EXP0[p0]) begin
                        err00 = err00 + 1;
                    end
                end
                if (err00 > 0) begin
                    $display("Wrong answer in first 128 pixels!\n");
                    $finish;
                end
                else begin
                    $display("Right answer in first 128 pixels!\n");
                    $stop;
                end
            end
	    end
    end
    initial  begin
        #`End_CYCLE ;
 	    $display("-----------------------------------------------------\n");
 	    $display("Error!!! The simulation can't be terminated under normal operation!\n");
 	    $display("-------------------------FAIL------------------------\n");
 	    $display("-----------------------------------------------------\n");
 	    $finish;
    end
    //-------------------------------------------------------------------------------------------------------------------
    initial begin  	// Sobel_x
    check0<= 0;
    wait(busy==1); wait(busy==0);
    if (check0 == 1) begin 
    	err00 = 0;
    	for (p0=0; p0<=16383; p0=p0+1) begin
    		if (L0_MEM0[p0] == L0_EXP0[p0]) ;
    		/*else if ( (L0_MEM0[p0]+20'h1) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h1) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]+20'h2) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h2) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]+20'h3) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h3) == L0_EXP0[p0]) ;*/
    		else begin
    			err00 = err00 + 1;
    			begin 
					if (err00 < 200) begin
    					$display("WRONG! Result image has error , Pixel %d is wrong!", p0);
    					$display("               The output data is %h, but the expected data is %h ", L0_MEM0[p0], L0_EXP0[p0]);
					end
    			end
    		end
    	end
    	if (err00 == 0) $display(" Result image is correct !");
    	else		 $display(" Result image be found %d error !", err00);
    end
    end
    initial begin
      wait(busy == 1);
      wait(busy == 0);      
    $display(" ");
	$display("-----------------------------------------------------\n");
	$display("--------------------- S U M M A R Y -----------------\n");
	    if( (check0==1)&(err00==0) ) $display("Congratulations! Result image data have been generated successfully! The result is PASS!!\n");
		else if (check0 == 0) $display("Result image output was fail! \n");
		else $display("FAIL!!!  There are %d errors! in result image \n", err00);
	    if ((check0) == 0) $display("FAIL!!! No output data was found!! \n");
	    $display("-----------------------------------------------------\n");
        #(`CYCLE/2); $finish;
    end
endmodule