--Engineer     : Haines Todd
--Date         : 11/16/2018
--Name of file : LoadController.VHD
--Description  : Loads pixel values from the BROM and feeds them into the DCT_8x8_MAC
			   -- Values are sent to the DCT_8x8_MAC block by block such that the DCT MAC
			   -- doesn't need to do any buffering of the data.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LoadController is
	port (
		clk, rst   	: in  std_logic;
		
		--ports to the BROM interface
		BROM_addr	: out std_logic_vector(14 downto 0);
		BROM_data	: in std_logic_vector(7 downto 0);
		BROM_read	: out std_logic;
		
		--the pixel value to be sent to the DCT_8x8_MAC
		pixel_val	: out unsigned(7 downto 0);
		
		--coordinates of the current DCT being computed, relative to the current block
		k, el		: out std_logic_vector(2 downto 0); 
		
		--address of where the current DCT being computed, will be stored in the DCT RAM
		DCT_RAM_addr: out std_logic_vector(14 downto 0);
		
		next_out   	: in  std_logic;
		out_valid 	: out std_logic
	);
end LoadController;

architecture rtl of LoadController is

	--row and column coordinates of the DCT block currently being calculated 
	signal r	: integer range 0 to 14 := 0;
	signal c	: integer range 0 to 19 := 0;
	
	-- k and l relative to the current block
	signal k_block_reg	: integer range 0 to 7 := 0;
	signal el_block_reg : integer range 0 to 7 := 0;
	
	-- k and l relative to the entire image, used to calculate DCT_RAM_addr 
	signal k_DCT_reg	: integer range 0 to 119 := 0;
	signal el_DCT_reg	: integer range 0 to 159 := 0;
	
	--m and n coordinates relative to the current block
	signal m_block_reg	: integer range 0 to 7 := 0;
	signal n_block_reg 	: integer range 0 to 7 := 0;
	
	--m and n coordinates relative to the entire image, used to calculate BROM_addr
	signal m_DCT_reg	: integer range 0 to 119 := 0;
	signal n_DCT_reg	: integer range 0 to 159 := 0;
	
	signal stall			: std_logic;
	signal inc_dct_calc 	: std_logic;
	signal inc_dct_block	: std_logic;
	
	signal inc_calc_meta	: std_logic;
	signal counting			: std_logic;
	signal in_valid			: std_logic;
	
	signal out_valid_reg    : std_logic;
	signal finished         : std_logic;

begin

	m_DCT_reg  <= (r*8) + m_block_reg;
	n_DCT_reg  <= (c*8) + n_block_reg;
	
	--BROM_addr calculation
	BROM_addr <= std_logic_vector (to_unsigned(m_DCT_reg*160, BROM_addr'length) + to_unsigned(n_DCT_reg, BROM_addr'length));
	
	k_DCT_reg  <= (r*8) + k_block_reg;
	el_DCT_reg <= (c*8) + el_block_reg;

	--DCT RAM addr calculation
	DCT_RAM_addr <= std_logic_vector (to_unsigned(k_DCT_reg*160, BROM_addr'length) + to_unsigned(el_DCT_reg, BROM_addr'length));
	
	BROM_read <= '1'; --set the BROM to always be read on every rising clock edge
	in_valid <= (NOT stall) AND counting AND (NOT finished); --only stall, when rst is asserted or when next_out being pulled low by the next module
	stall  <= (NOT next_out); --stall the counters when next_out is low
	
	--signal to increment k and el when a DCT calculation is finished
	inc_dct_calc  <= '1' when (m_block_reg=7 AND n_block_reg=7) else '0';
	
	--signal to increment r and c when a DCT block is finished
	inc_dct_block <= '1' when (k_block_reg=7 AND el_block_reg=7 AND inc_dct_calc='1') else '0';
	
	valid_pipeline: process(clk)  begin
	   if (rising_edge(clk)) then
	       if (rst = '1') then
	           out_valid <= '0';
	       else
	           out_valid <= out_valid_reg;
	       end if;
	   end if;
	end process;
	
	pipeline_reg_proc: process(clk) begin
		if rising_edge(clk) then
			if (rst = '1') then
				pixel_val <= (others => '0');
				k  <= (others => '0');
				el <= (others => '0');
				out_valid_reg <= '0';
			elsif (stall = '0') then
				pixel_val <= unsigned(BROM_data);
				k  <= std_logic_vector(to_unsigned(k_block_reg, k'length));
				el <= std_logic_vector(to_unsigned(el_block_reg, el'length));
				out_valid_reg <= in_valid;
			end if;
		end if;
	end process;
	
	m_n_increment_proc: process(clk) begin
	
		if rising_edge(clk) then
			if (rst = '1') then
				m_block_reg <= 0;
				n_block_reg <= 0;
				counting <= '0';
			elsif (stall = '0') then
				counting <= '1';
				if (m_block_reg = 7) and (n_block_reg = 7) then --end of current DCT calculation
					m_block_reg <= 0;
					n_block_reg <= 0;
				elsif (n_block_reg = 7) then
					n_block_reg <= 0;
					m_block_reg <= m_block_reg + 1;
				else
					n_block_reg <= n_block_reg + 1;
				end if;
			end if;
		end if;
	
	end process;
	
	dct_increment_proc: process(clk) begin
	
		if rising_edge(clk) then
			if (rst = '1') then
				k_block_reg	<= 0;
				el_block_reg	<= 0;
				inc_calc_meta <= '0';
			elsif (inc_dct_calc = '1' and inc_calc_meta = '0') then
				inc_calc_meta <= '1';
			elsif (inc_calc_meta = '1') then
				inc_calc_meta <= '0';
			
				if (k_block_reg = 7) and (el_block_reg = 7) then --end of current DCT block
					k_block_reg <= 0;
					el_block_reg <= 0;
				elsif (el_block_reg = 7) then
					k_block_reg  <= k_block_reg + 1;
					el_block_reg <= 0;
				else
					el_block_reg <= el_block_reg + 1;
				end if;
			end if;
		end if;

	end process;
	
	dct_block_increment_proc: process(clk) begin
		
		if rising_edge(clk) then
			if (rst = '1') then
				r <= 0;
				c <= 0;
				finished <= '0';
			elsif (inc_dct_block = '1') then
				if (r = 14) and (c = 19) then --end of whole image
					r <= 0;
					c <= 0;
					finished <= '1';
				elsif (c = 19) then	
					r <= r + 1;
					c <= 0;
				else
					c <= c + 1;
				end if;
			end if;
		end if;
	
	end process;

end rtl;


