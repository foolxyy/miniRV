module miniRV_SoC (
    input  logic         fpga_rst,   // High active
    input  logic         fpga_clk,

    output logic         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
    output logic [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
    output               debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
    output logic [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output logic [31:0]  debug_wb_value      // 指令写回时，写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)

);
    logic        cpu_clk = fpga_clk;
    logic [31:0] irom_addr;
    logic [31:0] irom_data;
    logic [31:0] dram_addr;
    logic [31:0] dram_rdata;
    logic [31:0] dram_wdata;
    logic        dram_we;
    
    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (cpu_clk),

        .irom_addr          (irom_addr),
        .irom_data          (irom_data),

        .perip_addr         (dram_addr),
        .perip_rdata        (dram_rdata),
        .perip_wdata        (dram_wdata),
        .perip_wen          (dram_we),

        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)

    );
    
    // 下面两个模块，只需要实例化代码和连线代码，不需要创建IP核
    IROM Mem_IROM (
        .a          (irom_addr[17:2]),
        .spo        (irom_data)
    );

    DRAM Mem_DRAM (
        .clk        (cpu_clk),
        .a          (dram_addr[17:2]),
        .spo        (dram_rdata),
        .we         (dram_we),
        .d          (dram_wdata)
    );

endmodule