Structure:
-src/toplevel_DCT.vhd
	- src/LoadController.vhd: Loads pixels from the BRAM holding the original image and feeds them to the DCT_8x8_MAC in a predefined order
	- src/DCT_8x8_MAC.vhd: DCT algorithm that process a 8x8 block of image
		- cosLUT.vhd: Look-up table for fixed-point cosine values
	-vga_out_src/vga_top.vhd
		- vga_out_src/vga_out.vhd: Reads input pixels values and supplies them to the vga port.

testbenches:
tb/tb_DCT_MAC.vhd: test the functionality DCT_8x8_MAC module
	- run/tb_DCT_MAC_input.txt: Matlab generated input sequence of pixel values
	- run/tb_DCT_MAC_output_ref.txt: Matlab generated DCT sequence (golden reference)
	- run/tb_DCT_MAC_output.txt: ModelSim simluated DCT output sequence
	
tb/tb.vhd: Instantiates the toplevel_DCT module as device under test
	- run/Toplevel_DCT_Output_ref.txt: Matlab generated DCT sequence with DCT RAM store locations
	- run/Toplevel_DCT_Output.txt: Modelsim simulated Toplevel DCT output. Contents written to DCT RAM

tb/tb_Load_Controller.vhd: Instantiates the LoadController module as device under test. Compare output file with run/Load_Controller_Output_ref.txt

tb/vga_out_tb.vhd: test the functionality vga out module

matlab scripts:
matlab/ECE6276_2D_DCT.m: models for 2D DCT.
matlab/dct_fft_test.m: MATLAB code for sorting out how 2D DCT works.

Other:
src/simulated_BRAM_unblocked.vhd: simulated BRAM with the test image preloaded

golden_reference.csv: spreadsheet of expected DCT output values
