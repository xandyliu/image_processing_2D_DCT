
--Engineer     : Yanshen Su 
--Date         : 10/01/2018
--Name of file : tb_fft_top.vhd
--Description  : test bench for fft_top

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
  file   input_data_file  : text;
  -- time
  constant T: time  := 20 ns;

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
  begin

    rst <= '1';
    k <= "001";
    el <= "001";
    next_out <= '1';
    pixel_val_in <= "00000001";
    in_valid <= '0';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    in_valid <= '1';
    wait until rising_edge(clk);
    k <= "000";
    el <= "000";
    for i in 0 to 63 loop
    	wait until rising_edge(clk); 
    end loop;
    pixel_val_in <= "00000010";
    for i in 0 to 63 loop
    	wait until rising_edge(clk); 
    end loop;
    in_valid <= '0';

    wait;
  end process;



end tb_arch;
