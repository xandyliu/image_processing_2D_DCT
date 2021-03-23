--Engineer     : Haines Todd, Andrew Paredes
--Date         : 11/6/2018
--Name of file : tb.vhd
--Description  : test bench for toplevel_DCT

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb is
end tb;

architecture tb_arch of tb is 
	component toplevel_DCT 
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
	end component;

  --signals local only to the present ip
  
  signal clk	: std_logic;
  signal rst 	: std_logic;
  
  signal BROM_addr	: std_logic_vector(14 downto 0);
  signal BROM_data	: std_logic_vector(7 downto 0);
  signal BROM_read	: std_logic;
  
  signal DCT_RAM_addr	: std_logic_vector(14 downto 0);
  signal DCT_RAM_data	: signed(17 downto 0);
  signal DCT_RAM_write	: std_logic;
  
  --signals related to the file operations
  
  --the DCT values for the image stored as a vector which is ordered in the following way
  --proceeding to the right and down block by block and proceeding to the right and down within each block
  
  file   output_file: text;  
  -- time
  constant T: time  := 20 ns;
  signal cycle_count: integer;

begin
  DUT: toplevel_DCT
  port map (
		clk	=> clk,
		rst	=> rst,
		BROM_addr	=> BROM_addr,
		BROM_data	=> BROM_data,
		BROM_read	=> BROM_read,
		DCT_RAM_addr	=> DCT_RAM_addr,
		DCT_RAM_data	=> DCT_RAM_data,
		DCT_RAM_write	=> DCT_RAM_write
	);
	
  bram: entity work.simulated_BRAM_unblocked
  port map (
		clka	=> clk,
		ena	=> BROM_read,
		wea	=> (others => '0'),
		addra	=> BROM_addr,
		dina	=> (others => '0'),
		douta	=> BROM_data
	);


  p_clk: process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;

  p_sim: process
    variable char_comma     : character;
    variable output_line    : line;
  begin
    file_open(output_file, "run/Toplevel_DCT_Output.txt", write_mode);

	write(output_line, string'("DCT Value, DCT Ram Address"), left, 30);
    writeline(output_file, output_line);
	
	cycle_count <= 0;

    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';

    while (cycle_count < (19200*65)) loop  
  --while not endfile(input_file) loop

      wait until rising_edge(clk);
	  cycle_count <= cycle_count + 1;
      -- sample and write to output file
      if (DCT_RAM_write = '1') then
        write(output_line, to_integer(signed(DCT_RAM_data)), right, 5);
		write(output_line, string'(", "));
		write(output_line, to_integer(unsigned(DCT_RAM_addr)), right, 5);
		writeline(output_file, output_line);
      end if;
      
    end loop;

    file_close(output_file);
    report "Test completed";
    stop(0);

  end process;



end tb_arch;
