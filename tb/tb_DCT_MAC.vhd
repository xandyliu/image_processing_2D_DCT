--Engineer     : Xingyang Liu
--Name of file : tb_DCT_MAC.vhd
--Description  : test bench for DCT_8x8_MAC.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_DCT_MAC is

end tb_DCT_MAC;

architecture tb_arch of tb_DCT_MAC is 

  --signals local only to the present ip
  signal clk, rst      : std_logic;
  signal next_out      : std_logic;
  signal in_valid      : std_logic  := '0';
  signal pixel_val_in  : unsigned (7 downto 0);
  signal next_in       : std_logic;
  signal out_valid     : std_logic;
  signal k, el	       : unsigned (2 downto 0);
  signal DCT_val_out   : signed (31 downto 0);
  --signals related to the file operations
  file   input_file : text;
  file   output_file: text;
  -- time
  constant T: time  := 20 ns;

  signal pixel_count: unsigned (5 downto 0);
  --signal DCT_count: unsigned (6 downto 0);

begin

  DUT: entity work.DCT_8x8_MAC
  port map (
          -- input side
          clk      => clk,
          rst      => rst,
          pixel_val_in  => pixel_val_in,
          in_valid => in_valid,
          next_in  => next_in,
          k => k, 
          el => el,
          -- output side
          out_valid     => out_valid,
          next_out	=> next_out,
          DCT_val_out => DCT_val_out
         );

  p_clk: process
	
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;

  -- SIMULATION STARTS
  p_read_data: process
	variable input_line : line;
    	variable pixel  : std_logic_vector(7 downto 0);
  begin
    file_open(input_file, "tb_DCT_8x8_MAC_input.txt", read_mode);
    pixel_count <= "000000";

    rst <= '1';
    k <= "000";
    el <= "000";
    
    pixel_val_in <= "00000000";
    in_valid <= '0';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);

    while not endfile(input_file) loop

      readline(input_file, input_line);
      read(input_line, pixel);
      in_valid <= '1';
      pixel_val_in <= unsigned(pixel);
      wait until rising_edge(clk);
	if pixel_count = "111111" then
		pixel_count <= "000000";
		el <= el + "001";
	else
		pixel_count <= pixel_count + "000001";
	end if;

	if el = "111" and pixel_count = "111111" then
		k <= k + "001";
	end if;
    end loop;

    file_close(input_file);
    wait;
  end process;

p_write_data:process
variable output_line: line;
begin
--DCT_count <= "0000000";
file_open(output_file, "tb_DCT_8x8_MAC_output.txt", write_mode);
	next_out <= '1';
for i in 0 to 127 loop
	wait until out_valid = '1';
	wait until rising_edge(clk);
      	write(output_line, DCT_val_out);
	writeline(output_file, output_line);
end loop;
	file_close(output_file);
	stop(0);-- until rising_edge(clk);
end process;



end tb_arch;
