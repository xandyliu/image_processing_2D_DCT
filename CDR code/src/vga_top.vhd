-- Engineer    : Andrew Paredes
-- Date        : 11/12/2018
-- Description : This src code takes 4 bit rgb values and outputs the values to a vgaout block port to be displayed on a monitor. Displays an image of lena.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_top is
    Port ( clk : in std_logic;
           Red : out STD_LOGIC_VECTOR (3 downto 0);
           Green : out STD_LOGIC_VECTOR (3 downto 0);
           Blue : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC);
end vga_top;

architecture Behavioral of vga_top is

component vga_out
	port(
    pixel_clk  : in std_logic; -- should be 25Mhz if generics are left unchanged
    r_in       : in std_logic_vector( 3 downto 0);
    b_in       : in std_logic_vector( 3 downto 0);
    g_in       : in std_logic_vector( 3 downto 0);
    r_out      : out std_logic_vector( 3 downto 0);
    g_out      : out std_logic_vector( 3 downto 0);
    b_out      : out std_logic_vector( 3 downto 0);
    hsync      : out std_logic;
    vsync      : out std_logic;
    en_display : out std_logic
    );
    end component;
    
 COMPONENT input_image
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
    END COMPONENT;

signal r_in 		: std_logic_vector(3 downto 0);
signal g_in 		: std_logic_vector(3 downto 0);
signal b_in 		: std_logic_vector(3 downto 0);
signal rgb  		: std_logic_vector(3 downto 0);
signal rgb_muxed	: std_logic_vector(3 downto 0);

signal clk_cntr : unsigned( 3 downto 0) := (others => '0');

signal clk25Mhz : std_logic;

signal h_counter 	: integer range 0 to 639 	:= 0;
signal v_counter	: integer range 0 to 479 	:= 0;
signal addra 		: integer range 0 to 19200 	:= 0;

signal en_display : std_logic;

begin

clk25Mhz <= clk_cntr(1);

clk_div: process(clk)
	begin
		if(rising_edge(clk)) then
			clk_cntr <= clk_cntr + 1;
		end if;
	end process clk_div;

--this process keeps track of which pixel the 640x480 VGA display is on
image_coord_counter: process(clk25Mhz)
	begin
		if(rising_edge(clk25Mhz)) then
			if(en_display = '1') then
			
				if (h_counter = (640-1)) then
					h_counter <= 0;
					if (v_counter = (480-1)) then
						v_counter <= 0;
					else
						v_counter <= v_counter + 1;
					end if;
				else
					h_counter <= h_counter + 1;
				end if;
			end if;
		end if;
	end process image_coord_counter;
	
addr_gen: process(clk25Mhz)
	begin
		if(rising_edge(clk25Mhz)) then
			if(en_display = '1') then
				if ((h_counter = 0) AND (v_counter = 0)) then
					addra <= 0;
				elsif ((h_counter < 160) AND (v_counter < 120)) then
					addra <= addra + 1;
				else
					addra <= 19200; --set addra to 19200 when no pixel value is to be displayed	
				end if;
			end if;
		end if;
	end process addr_gen;

input_image_ram : input_image
              PORT MAP (
                clka => clk25Mhz,
                wea => (others => '0'),
				addra => std_logic_vector(to_unsigned(addra, 15)),
                dina => (others => '0'),
                douta => rgb
              );
              
			  
rgb_muxed <= (others=>'0') when (addra = 19200)  else rgb;
r_in <= rgb_muxed;
g_in <= rgb_muxed;
b_in <= rgb_muxed;
            
output_image: vga_out
                port map (
                pixel_clk => clk25Mhz,
                r_in => r_in,
                g_in => g_in,
                b_in => b_in,
                r_out => Red,
                g_out => Green,
                b_out => Blue,
                hsync => Hsync,
                vsync => Vsync,
                en_display => en_display             
                );           

end Behavioral;
