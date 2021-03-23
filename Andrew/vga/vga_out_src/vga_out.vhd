-- Engineer    : Andrew Paredes
-- Date        : 11/12/2018
-- Description : This src code takes 4 bit rgb values and outputs the values to a vga port to be displayed on a monitor.
-- The outputs are 4 bits wide because the basys 3 board vga port only support 4 bit resolution for the output.
-- The vga operates in a  raster scanning fashion similar to old CRT monitors.
-- The raster scanning is controlled by two pulses called the vertical and horizontal syncs.
-- In order to achieve a display that operates at 60 FPS the timing of the vsync and hsync must be calculated to ensure the screen is refreshed 60 times a second.
-- The timing is usually standard for monitors. 
-- The front porch back porch and sync delay are used to achieve the correct timing as well as influence the displays resolution.
-- The values for the front porch, back porch, and sync delays were set such that the resolution of the screen was set to a resolution of 640 x 480 
-- Timing values were obtained from this website http://tinyvga.com/vga-timing/640x480@60Hz
-- The 640 x 480 resolution operates only if the pixel clock is about 25Mhz for the most accuracy it would be 25.175Mhz
-- generics can be altered to support different resolutions and pixel clk speeds

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vga_out is
	generic(
---------- Horizontal raster scan -----------------------------------------------
	h_visible_area : integer := 640;
	h_front_porch  : integer := 16;
	h_back_porch   : integer := 48;
	h_sync_delay   : integer := 96; -- sync goes low during this section
	h_line         : integer := 800;
---------- Vertical raster scan -----------------------------------------------
	v_visible_area : integer := 480;
	v_front_porch  : integer := 10;
	v_back_porch   : integer := 33;
	v_sync_delay   : integer := 2; -- sync goes low during this section
	v_frame         : integer := 525
	);
	port(
	pixel_clk : in std_logic; -- should be 25Mhz if generics are left unchanged
	r_in      : in std_logic_vector( 3 downto 0);
	b_in      : in std_logic_vector( 3 downto 0);
	g_in      : in std_logic_vector( 3 downto 0);
	r_out     : out std_logic_vector( 3 downto 0);
	g_out     : out std_logic_vector( 3 downto 0);
	b_out     : out std_logic_vector( 3 downto 0);
	hsync     : out std_logic;
	vsync     : out std_logic;
	en_display : out std_logic
	);
end vga_out;

architecture arch of vga_out is

signal h_cntr : integer := 0;
signal v_cntr : integer := 0;
signal en_v_cntr : std_logic := '0';

begin

-- Horizontal counter
h_count : process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			if( h_cntr = (h_line - 1) ) then
				h_cntr <= 0;
				en_v_cntr <= '1';
			else
				h_cntr <= h_cntr + 1;
				en_v_cntr <= '0';
			end if;
		end if; 
	end process h_count;

--Vertical counter (Only enabled after an entire horizontal line has been scanned through)
v_count : process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			if( en_v_cntr = '1') then
				if( v_cntr = (v_frame - 1) ) then
					v_cntr <= 0;
				else
					v_cntr <= v_cntr + 1;
				end if;
			end if;
		end if; 
	end process v_count;

	hsync <='0' when ((h_cntr < h_sync_delay + h_front_porch) and (h_cntr > h_front_porch))  else '1';
	vsync <='0' when ((v_cntr < v_sync_delay + v_front_porch) and (v_cntr > v_front_porch))  else '1';
	

-- Synchronize process which  sets the vsync and hsync pulses depending on the values of th vertical and horizontal counters	
--synchronize : process( h_cntr, v_cntr )
--	begin
--		if(h_cntr > (h_front_porch - 1) and h_cntr < (h_front_porch + h_sync_delay -1)) then
--			hsync <= '0';
--		else
--			hsync <= '1';
--		end if;
		
--		if(v_cntr > (v_front_porch - 1) and v_cntr < (v_front_porch + v_sync_delay -1)) then
--			vsync <= '0';
--		else
--			vsync <= '1';
--		end if;
--	end process synchronize;

--Process which writes pixels values to the output only when in the active video region. Otherwise rgb_out values are set to zero.
assign_rgb_values :process( h_cntr,v_cntr,r_in,b_in,g_in)
	begin
		if(h_cntr > (h_front_porch + h_back_porch + h_sync_delay -1) and v_cntr >(v_front_porch + v_back_porch + v_sync_delay -1 )) then
			r_out <= r_in;
			g_out <= g_in;
			b_out <= b_in;
			en_display <= '1';
		else
			r_out <= (others => '0');
			g_out <= (others => '0');
			b_out <= (others => '0');
			en_display <= '0';
		end if;
	end process assign_rgb_values;
end architecture arch;
