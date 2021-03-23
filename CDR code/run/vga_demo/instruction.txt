To run the vga demo the follwing steps are required. 

	1. Import the src files and constraint files to vivado.
		-Make sure to include vga out and vga top src files.
	2. Create a single port ram using the block memory generator from the Ip_library
		- Name the ram input_image
		- make sure port widths for read and write are 4 bits
		- read and write depths must be 307200
		- import the image_4bit.coe as an init file to the ram also check the box indicating all remaing memroy addresses intiialized to 0
	3. Generate bitstream

	4. Connect vgat cable from monitor to vga port on the board.

	5. Power the board on.

	6.Download to board using any appropriate method. I used jtag programming via usb uart programming port.

	7.(Optional) To observe waveform in Modelsim only use vga_out.vhd and vga_out_tb.vhd The top file is not necessary.

Alternatively

	1. Open vivado

	2.Select open hardware manager

	3. Connect to the board.

	4. Program using the provided vga_top.bit file

	
