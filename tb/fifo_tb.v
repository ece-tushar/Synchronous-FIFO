module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter RAM_DEPTH = 16;
    
    reg clk,w_en,r_en,rst;
    reg [DATA_WIDTH-1:0] data_in;
    wire FullFlag,EmptyFlag;
    wire [DATA_WIDTH-1:0] data_out;
    wire [ADDR_WIDTH-1:0]w_ptr = dut.w_ptr;
    wire [ADDR_WIDTH-1:0]r_ptr = dut.r_ptr;
    wire [ADDR_WIDTH:0]w_cnt = dut.w_cnt;
    wire [ADDR_WIDTH:0]r_cnt = dut.r_cnt;
    wire [DATA_WIDTH-1:0] ram_0 [0:RAM_DEPTH-1] = dut.RAM1.mem;
    
   
    Datapath dut (
                .w_en(w_en),
                .r_en(r_en),
                .clk(clk),
                .rst(rst),
                .data_in(data_in),
                .FullFlag(FullFlag),
                .EmptyFlag(EmptyFlag),
                .data_out(data_out)
                );
       
    initial clk = 1;
    always #5 clk = ~clk;
    
    task reset_dut;
        begin
            rst = 1;
            w_en = 0;
            r_en = 0;
            data_in = 0;
        
        repeat(2)begin
             @(negedge clk);
            end
            
            rst = 0;
        end
    endtask
      
    task fifo_write_edge;
        input integer count;
        integer i;
        begin
        for (i=0;i<count;i = i+1) begin
            @ (negedge clk)
                begin
                    data_in = $random;
                    w_en = 1;
                end
             if (i == count-1) begin
                r_en = 1;
                end
                end
        @(negedge clk) begin
            w_en = 0;
            r_en = 0;
        end
        end
    endtask
    
    task fifo_write;
        input integer count;
        integer i;
        begin
        for (i=0;i<count;i = i+1) begin
            @ (negedge clk)
                begin
                    data_in = $random;
                    w_en = 1;
                end
                end
        @(negedge clk) begin
            w_en = 0;
        end
        end
    endtask
    
    task fifo_read;
            input integer count;
            integer i;
            begin
            for (i=0;i<count;i = i+1) begin
                @ (negedge clk)
                    begin
                        r_en = 1;
                    end
                    end
            @(negedge clk) begin
                r_en = 0;
            end
            end
        endtask
    

    initial 
        begin
            reset_dut();
            fifo_write(4);
            fifo_read(4);
            fifo_write_edge(17);
           
            $finish;
           
        end
initial begin
            $display("------------------------------------------------------------");
            $display(" time | wr rd | data_in | data_out | w_ptr | r_ptr | full | empty");
            $display("------------------------------------------------------------");
        
            $monitor("%4t  |  %b   %b |   %h    |    %h    |   %0d   |   %0d   |   %b   |   %b",
                     $time,
                     w_en,
                     r_en,
                     data_in,
                     data_out,
                     w_ptr,
                     r_ptr,
                     FullFlag,
                     EmptyFlag);
        end
endmodule 

