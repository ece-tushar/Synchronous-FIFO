module Datapath #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter RAM_DEPTH = 16
    )(
    input w_en,r_en,clk,rst,
    input [DATA_WIDTH-1:0] data_in,
    output FullFlag,EmptyFlag,
    output [DATA_WIDTH-1:0] data_out
    );
    

    wire  w_dsbl,r_dsbl,full_flag;
    wire [ADDR_WIDTH-1:0] w_ptr,r_ptr;
    wire [ADDR_WIDTH:0] w_cnt,r_cnt;
    wire [DATA_WIDTH-1:0] ram_data_out;
    wire w_phase,r_phase,wrt_allwd,rd_allwd,empty_flag;
    
    assign w_phase = w_cnt[ADDR_WIDTH];
    assign r_phase = r_cnt[ADDR_WIDTH];
    
    assign w_ptr = w_cnt[ADDR_WIDTH-1:0];
    assign r_ptr = r_cnt[ADDR_WIDTH-1:0];
    
    RAM16x8 #(DATA_WIDTH,RAM_DEPTH,ADDR_WIDTH)
    RAM1     (data_in,clk,rst,w_dsbl,
              w_ptr,r_ptr,ram_data_out);
                  
    counter #(ADDR_WIDTH)
    WCNTR    (clk,rst,w_dsbl,w_cnt);
    
    counter #(ADDR_WIDTH)
    RCNTR    (clk,rst,r_dsbl,r_cnt);
    
    OPreg   #(DATA_WIDTH)
    OUTreg   (ram_data_out,clk,rst,r_dsbl,
              data_out);
    
    assign full_flag = (w_ptr == r_ptr) && (w_phase != r_phase);
    assign wrt_allwd = (~full_flag) || (full_flag && w_en && r_en);
    
    assign empty_flag = (w_cnt == r_cnt);
    assign rd_allwd = (~empty_flag);
        
    assign w_dsbl = ~(wrt_allwd && w_en);
    assign r_dsbl = ~(rd_allwd && r_en);
    
    assign FullFlag = full_flag;
    assign EmptyFlag = empty_flag;
    
endmodule