vsim -gui work.tb_conv


#add wave -position end  sim:/tb_conv/accepted_OUT_sample
#add wave -position end  sim:/tb_conv/add_i
#add wave -position end  sim:/tb_conv/add_i_CONV1D
#add wave -position end  sim:/tb_conv/add_i_PROCESS
#add wave -position end  sim:/tb_conv/be
#add wave -position end  sim:/tb_conv/clk
#add wave -position end  sim:/tb_conv/data
#add wave -position end  sim:/tb_conv/done_OUT_SAMPLE
#add wave -position end  sim:/tb_conv/done_tot
#add wave -position end  sim:/tb_conv/ext_mem_gnt
#add wave -position end  sim:/tb_conv/ram_data_out
#add wave -position end  sim:/tb_conv/REPLACE_FILTER
#add wave -position end  sim:/tb_conv/REPLACE_INPUT
#add wave -position end  sim:/tb_conv/REPLACED_FILTER
#add wave -position end  sim:/tb_conv/replaced_IN_sample
#add wave -position end  sim:/tb_conv/req_i
#add wave -position end  sim:/tb_conv/RST_n
#add wave -position end  sim:/tb_conv/SEL_MUX_ADD
#add wave -position end  sim:/tb_conv/SEL_MUX_DATA
#add wave -position end  sim:/tb_conv/SEL_MUX_we_i
#add wave -position end  sim:/tb_conv/start
#add wave -position end  sim:/tb_conv/wdata
#add wave -position end  sim:/tb_conv/wdata_CONV1D
#add wave -position end  sim:/tb_conv/wdata_PROCESS
#add wave -position end  sim:/tb_conv/we_i
#add wave -position end  sim:/tb_conv/we_i_conv1d
#add wave -position end  sim:/tb_conv/we_i_process
###############################################################################
add wave -position end  sim:/tb_conv/clk
add wave -position insertpoint /tb_conv/conv1d_uut/p_state
add wave -position insertpoint /tb_conv/conv1d_uut/wdata
add wave -position insertpoint /tb_conv/conv1d_uut/data
add wave -position insertpoint /tb_conv/we_i
add wave -position insertpoint /tb_conv/conv1d_uut/CNT_I
add wave -position insertpoint /tb_conv/conv1d_uut/CNT_J
add wave -position insertpoint /tb_conv/conv1d_uut/CNT_M
add wave -position insertpoint /tb_conv/conv1d_uut/CNT_S
add wave -position insertpoint /tb_conv/conv1d_uut/CNT_Z
add wave -position insertpoint /tb_conv/conv1d_uut/CNT_FG

add wave -position insertpoint /tb_conv/conv1d_uut/REG_ACC_0
add wave -position insertpoint /tb_conv/conv1d_uut/REG_ACC_1
add wave -position insertpoint /tb_conv/conv1d_uut/REG_ACC_2
add wave -position insertpoint /tb_conv/conv1d_uut/REG_ACC_3

add wave -position insertpoint /tb_conv/conv1d_uut/REG_R0_O
add wave -position insertpoint /tb_conv/conv1d_uut/REG_R1_O
add wave -position insertpoint /tb_conv/conv1d_uut/REG_R2_O
add wave -position insertpoint /tb_conv/conv1d_uut/REG_R3_O

#############################################################################
run 100000 ns