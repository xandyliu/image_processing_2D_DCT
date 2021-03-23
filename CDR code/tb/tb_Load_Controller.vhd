--Engineer     : Haines Todd
--Date         : 11/15/2018
--Name of file : tb_Load_Controller.vhd
--Description  : test bench for toplevel_DCT

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_Load_Controller is
end tb_Load_Controller;

architecture tb_Load_Controller_arch of tb_Load_Controller is 
	
	component LoadController
		port (
			-- input side
			clk, rst	: in  std_logic;
			
			BROM_addr	: out std_logic_vector(14 downto 0);
			BROM_data	: in std_logic_vector(7 downto 0);
			BROM_read	: out std_logic; --read en signal may not be required
			
			pixel_val	: out unsigned(7 downto 0);
			
			--coordinates of the current DCT being computed, relative to the whole image
			k, el		: out std_logic_vector(2 downto 0); 
			
			next_out  	: in  std_logic;
			out_valid 	: out std_logic
		); end component;

	component simulated_BRAM_unblocked
		port(
			clka : in std_logic;
			ena : in std_logic;
			wea : in std_logic_vector( 0 downto 0);
			addra : in std_logic_vector( 14 downto 0);
			dina : in std_logic_vector(7 downto 0);
			douta : out std_logic_vector(7 downto 0)
		); end component;

  --signals local only to the present ip
  
  signal clk	: std_logic;
  signal rst 	: std_logic;
  
  signal BROM_addr	: std_logic_vector(14 downto 0);
  signal BROM_data	: std_logic_vector(7 downto 0);
  signal BROM_read	: std_logic;
  signal pixel_val	: unsigned(7 downto 0);
  
  signal k			: std_logic_vector(2 downto 0);
  signal el			: std_logic_vector(2 downto 0);
  
  signal next_out	: std_logic;
  signal out_valid	: std_logic;
  
  signal DCT_RAM_addr	: std_logic_vector(14 downto 0);
  signal DCT_RAM_data	: std_logic_vector(15 downto 0);
  signal DCT_RAM_write	: std_logic;
  
  --signals related to the file operations
  
  --the DCT values for the image stored as a vector which is ordered in the following way
  --proceeding to the right and down block by block and proceeding to the right and down within each block
  
  file   output_file: text;  
  -- time
  constant T: time  := 20 ns;
  --signal cycle_count: integer;

begin
	
	DUT: LoadController
	port map (
		clk => clk,
		rst => rst,
		BROM_addr => BROM_addr,
		BROM_data => BROM_data,
		BROM_read => BROM_read,
		pixel_val => pixel_val,
		k => k,
		el => el,
		next_out => next_out,
		out_valid => out_valid
	);
	
  bram: simulated_BRAM_unblocked
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
    file_open(output_file, "run/Load_Controller_Output.txt", write_mode);

	write(output_line, string'("Pixel Value, K index, L index"), left, 15);
    writeline(output_file, output_line);

    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
	next_out <= '0';
    wait until falling_edge(clk);
    rst <= '0';
	

    while true loop  
  --while not endfile(input_file) loop

      wait until falling_edge(clk);
	  next_out <= '1';
      -- sample and write to output file
      if (out_valid = '1') then
        write(output_line, to_integer(pixel_val), right, 3);
		write(output_line, string'(", "));
		write(output_line, to_integer(unsigned(k)), left, 1);
		write(output_line, string'(", "));
		write(output_line, to_integer(unsigned(el)), left, 1);
		writeline(output_file, output_line);
      end if;
    end loop;

    file_close(output_file);
    report "Test completed";
    stop(0);

  end process;



end tb_Load_Controller_arch;
