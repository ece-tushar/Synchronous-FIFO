module RAM16x8 #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4
    )(
    input [DATA_WIDTH-1:0] data_in,
    input clk,rst,w_dsbl,
    input [ADDR_WIDTH-1:0] w_addr,r_addr,
    output [DATA_WIDTH-1:0] data_out
    );

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    integer i;
    always @ (posedge clk)
        if (rst)
            begin
                for (i = 0; i < DEPTH; i = i + 1)
                    mem[i] <= {DATA_WIDTH{1'b0}};
            end
        else if (!w_dsbl)
            mem[w_addr] <= data_in;
              
    assign data_out = mem[r_addr];
      
endmodule

module counter #(
    parameter ADDR_WIDTH = 4
    )(
    input clk,rst,dsbl,
    output reg [ADDR_WIDTH:0] count
    );
    
    always @ (posedge clk)
        if (rst)
            count <= {(ADDR_WIDTH+1){1'b0}};
        else if (!dsbl)
            count <= count + 1;
            
endmodule
    
module OPreg #(
    parameter DATA_WIDTH = 8
    )(
    input [DATA_WIDTH-1:0] data_in,
    input clk,rst,r_dsbl,
    output reg [DATA_WIDTH-1:0] data_out
    );
    
    always @ (posedge clk)
        if (rst)
           data_out <= {DATA_WIDTH{1'b0}};
        else if (!r_dsbl)
            data_out <= data_in;
  
endmodule 
