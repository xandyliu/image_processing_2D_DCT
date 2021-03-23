-- Engineer    : Andrew Paredes
-- Date        : 11/12/2018
-- Description : This src code takes 4 bit rgb values and outputs the values to a vgaout block port to be displayed on a monitor. Displays an image of lena.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_top is
    Port (

		DCT_RAM_addr	: out STD_LOGIC_VECTOR(14 downto 0);
		DCT_RAM_data	: in SIGNED(17 downto 0);
		DCT_RAM_read	: out STD_LOGIC;
	
		clk 		: in STD_LOGIC;
		clk25Mhz 	: in STD_LOGIC;
		Red 		: out STD_LOGIC_VECTOR (3 downto 0);
		Green 		: out STD_LOGIC_VECTOR (3 downto 0);
		Blue 		: out STD_LOGIC_VECTOR (3 downto 0);
		Hsync 		: out STD_LOGIC;
		Vsync 		: out STD_LOGIC
	);
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

signal h_counter 	: integer range 0 to 639 	:= 0;
signal v_counter	: integer range 0 to 479 	:= 0;
signal addra 		: integer range 0 to 19200 	:= 0;

signal DCT_data_abs	: signed(17 downto 0);

signal en_display : std_logic;

begin

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
					addra <= addra;
				end if;
			end if;
		end if;
	end process addr_gen;
	
	DCT_RAM_addr <= std_logic_vector(to_unsigned(addra, 15));
	DCT_RAM_read <= '1';
	
	

	--take the absolute value of the DCT_RAM_data port and fit the value into rgb
	DCT_data_abs <= abs(DCT_RAM_data);
	
	
	poor_mans_log_base_2: process(DCT_data_abs) begin
        if (DCT_data_abs > to_signed(65536,DCT_data_abs'length))    then rgb <= x"F";    
        elsif (DCT_data_abs > to_signed(32768,DCT_data_abs'length)) then rgb <= x"F";
        elsif (DCT_data_abs > to_signed(16384,DCT_data_abs'length)) then rgb <= x"E";
        elsif (DCT_data_abs > to_signed(8192,DCT_data_abs'length)) then rgb <= x"D";
        elsif (DCT_data_abs > to_signed(4096,DCT_data_abs'length)) then rgb <= x"C";
        elsif (DCT_data_abs > to_signed(2048,DCT_data_abs'length)) then rgb <= x"B";
        elsif (DCT_data_abs > to_signed(1024,DCT_data_abs'length)) then rgb <= x"A";
        elsif (DCT_data_abs > to_signed(512,DCT_data_abs'length)) then rgb <= x"9";
        elsif (DCT_data_abs > to_signed(256,DCT_data_abs'length)) then rgb <= x"8";
        elsif (DCT_data_abs > to_signed(128,DCT_data_abs'length)) then rgb <= x"7";
        elsif (DCT_data_abs > to_signed(64,DCT_data_abs'length)) then rgb <= x"6";
        elsif (DCT_data_abs > to_signed(32,DCT_data_abs'length)) then rgb <= x"5";
        elsif (DCT_data_abs > to_signed(16,DCT_data_abs'length)) then rgb <= x"4";
        elsif (DCT_data_abs > to_signed(8,DCT_data_abs'length)) then rgb <= x"3";
        elsif (DCT_data_abs > to_signed(4,DCT_data_abs'length)) then rgb <= x"2";
        elsif (DCT_data_abs > to_signed(2,DCT_data_abs'length)) then rgb <= x"1";
        else rgb <= (others => '0');
        end if;
    end process poor_mans_log_base_2;
	
	--rgb <= std_logic_vector(resize( shift_right(DCT_data_abs,12) , rgb'length));
	--rgb <= std_logic_vector(DCT_data_abs(3 downto 0));
    --rgb <= "1100";
-- input_image_ram : input_image
              -- PORT MAP (
                -- clka => clk25Mhz,
                -- wea => (others => '0'),
				-- addra => std_logic_vector(to_unsigned(addra, 15)),
                -- dina => (others => '0'),
                -- douta => rgb
              -- );
              
			  
rgb_muxed <= x"C" when (h_counter >= 160) OR (v_counter >= 120) else rgb;
--rgb_muxed <="1111";
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
