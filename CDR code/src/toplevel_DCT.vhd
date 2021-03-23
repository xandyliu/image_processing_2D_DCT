-- File Name:  	toplevel_DCT.VHD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel_DCT is
	port (
		-- input side
		clk, rst      	: in  std_logic;
		
		BROM_addr	: out std_logic_vector(14 downto 0);
		BROM_data	: in std_logic_vector(7 downto 0);
		BROM_read	: out std_logic; --read en signal may not be required
		
		DCT_RAM_addr	: out std_logic_vector(14 downto 0);
		DCT_RAM_data	: out signed(17 downto 0);
		DCT_RAM_write	: out std_logic
	);
end toplevel_DCT;

architecture structural of toplevel_DCT is
	
	signal dct_val_wire		: signed(31 downto 0);
	
	signal k_coord_wire, el_coord_wire	: std_logic_vector(2 downto 0);
	
	signal next_out_in_load_mac_wire	: std_logic;
	signal valid_load_mac_wire			: std_logic;
	
	signal next_out_in_mac_store_wire	: std_logic;
	signal valid_mac_store_wire			: std_logic;
	
	
	signal BROM_addr_wire		: std_logic_vector(14 downto 0);
	signal BROM_data_wire		: std_logic_vector(7 downto 0);
	signal BROM_read_wire		: std_logic; --read en signal may not be required
	signal pixel_val_wire		: unsigned(7 downto 0);
	
	signal DCT_RAM_addr_wire	: std_logic_vector(14 downto 0);
	signal DCT_RAM_data_wire	: signed(17 downto 0);
	signal DCT_RAM_write_wire	: std_logic;
	

begin

	BROM_addr 		<= BROM_addr_wire;
	BROM_data_wire 	<= BROM_data;
	BROM_read 		<= BROM_read_wire;
	
	DCT_RAM_data 	<= DCT_RAM_data_wire;
	DCT_RAM_write 	<= DCT_RAM_write_wire;
	
	
	
	

	load_controller: entity work.LoadController
	port map (
		-- input side
		clk 		=> clk,
		rst 		=> rst,
		
		BROM_addr	=> BROM_addr_wire,
		BROM_data	=> BROM_data_wire,
		BROM_read	=> BROM_read_wire,
		
		pixel_val	=> pixel_val_wire,
		
		k  			=> k_coord_wire,
		el 			=> el_coord_wire,
		
		DCT_RAM_addr=> DCT_RAM_addr_wire,
		
		next_out   => next_out_in_load_mac_wire,
		out_valid  => valid_load_mac_wire
	);
	
	
	
	
	
	dct_8x8_mac_inst: entity work.DCT_8x8_MAC
	port map (
		-- input side
		clk 			=> clk,
		rst 			=> rst,
		next_in 		=> next_out_in_load_mac_wire,
		in_valid 		=> valid_load_mac_wire,
		pixel_val_in 	=> pixel_val_wire,
		
		k 				=> unsigned(k_coord_wire),
		el 				=> unsigned(el_coord_wire),
		DCT_RAM_addr_in	=> DCT_RAM_addr_wire,
		
		next_out 		=> next_out_in_mac_store_wire,
		out_valid 		=> DCT_RAM_write_wire,
		DCT_val_out 	=> DCT_RAM_data_wire,
		DCT_RAM_addr_out=> DCT_RAM_addr
		
	);

end structural;