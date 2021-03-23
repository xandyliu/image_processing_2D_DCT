-- Engineer    : Andrew Paredes
-- Date        : 11/12/2018
-- Description : This src code is a rudimentary testbench to test the results of the vga_out module/component.
-- Simply tests the creating of a red screen with nothing else in it.
-- clk is configured to operate at 25Mhz in this testbench.
-- This is done so simulation timing results can be compared to vga standard timing obtained from the following website.
-- http://tinyvga.com/vga-timing/640x480@60Hz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_out_tb is
end vga_out_tb;

architecture behav of vga_out_tb is

component vga_out
	port(
	pixel_clk : in std_logic;
	r_in      : in std_logic_vector( 3 downto 0);
	b_in      : in std_logic_vector( 3 downto 0);
	g_in      : in std_logic_vector( 3 downto 0);
	r_out     : out std_logic_vector( 3 downto 0);
	g_out     : out std_logic_vector( 3 downto 0);
	b_out     : out std_logic_vector( 3 downto 0);
	hsync     : out std_logic;
	vsync     : out std_logic;
	en_display: out std_logic
	);
end component vga_out;

signal clk   : std_logic;
signal r_in  : std_logic_vector( 3 downto 0);
signal b_in  : std_logic_vector( 3 downto 0);
signal g_in  : std_logic_vector( 3 downto 0);
signal r_out : std_logic_vector( 3 downto 0);
signal g_out : std_logic_vector( 3 downto 0);
signal b_out : std_logic_vector( 3 downto 0);
signal hsync : std_logic;
signal vsync : std_logic;
signal en_display : std_logic;

constant clk_period : time := 40 ns; -- Same as using a 25 MHZ pixel clk

begin

DUT : vga_out
	port map(
	pixel_clk => clk,
	r_in => r_in,
	b_in => b_in,
	g_in => g_in,
	r_out => r_out,
	b_out => b_out,
	g_out => g_out,
	hsync => hsync,
	vsync => vsync,
	en_display => en_display
	);

clk_process : process
    begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process clk_process;

proc_stim: process
	begin
	--init signals
	r_in <= X"f";
	g_in <= X"0";
	b_in <= X"0";
	wait;

	end process proc_stim;

end architecture behav;



