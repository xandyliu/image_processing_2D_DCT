
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
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
    END COMPONENT;

signal r_in : std_logic_vector(3 downto 0);
signal g_in : std_logic_vector(3 downto 0);
signal b_in : std_logic_vector(3 downto 0);
signal rgb  : std_logic_vector(3 downto 0);
signal clk_cntr : unsigned( 3 downto 0) := (others => '0');
signal addra : unsigned( 18 downto 0) := (others => '0');
signal clk25Mhz : std_logic;

signal en_display : std_logic;

begin

clk25Mhz <= clk_cntr(1);

clk_div: process(clk)
            begin
                if(rising_edge(clk)) then
                    clk_cntr <= clk_cntr + 1;
                end if;
            end process clk_div;

addr_gen: process(clk25Mhz)
	begin
		if(rising_edge(clk25Mhz)) then
			if(en_display = '1') then
				if(addra = 307200) then
					addra <= (others => '0');
				else
					addra <= addra + 1;
				end if;
			end if;
		end if;
	end process addr_gen;
		
input_image_ram : input_image
              PORT MAP (
                clka => clk25Mhz,
                wea => (others => '0'),
                addra => std_logic_vector(addra),
                dina => (others => '0'),
                douta => rgb
              );
              r_in <= rgb;
              g_in <= rgb;
              b_in <= rgb;
            
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
