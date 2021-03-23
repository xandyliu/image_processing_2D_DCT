--Engineer     : Xingyang Liu
--Name of file : DCT_8x8_MAC.VHD
--Description  : DCT algorithm implementation. submodule of toplevel_DCT.vhd.
--				 receive pixel and DCT index values from load_controller.vhd and output DCT value to BRAM.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DCT_8x8_MAC is
	port (
		-- input side
		clk, rst      	: in  std_logic;
		next_in       	: out std_logic;
		in_valid      	: in  std_logic;
		pixel_val_in  	: in  unsigned (7 downto 0);
		
		k, el			: in unsigned (2 downto 0);
		
		-- output side
		next_out      	: in  std_logic;
		out_valid     	: out std_logic;
		DCT_val_out		: out signed (31 downto 0)
	);
end DCT_8x8_MAC;

architecture rtl of DCT_8x8_MAC is
	
	type State_type is (IDLE, COMPUTE);
	signal state 	: State_type;
	
	signal cosLUT_mk	: signed (8 downto 0);
	signal cosLUT_nl	: signed (8 downto 0);
	signal mult_LUT		: signed (17 downto 0);
	signal mult_pixel	: signed (25 downto 0);
	signal sum_mult		: signed (31 downto 0);
	signal sum_wire		: signed (31 downto 0);
	
	signal k_reg	: unsigned (2 downto 0);
	signal l_reg	: unsigned (2 downto 0);
	
	--stage 1 handshake and data_reg
	signal stall_s1		: std_logic;
	signal valid_s1_reg	: std_logic;
	signal pixel_s1_reg 	: unsigned (7 downto 0);
	signal m_reg	: unsigned (2 downto 0);
	signal n_reg	: unsigned (2 downto 0);
	--stage 2 handshake and data_reg
	signal stall_s2		: std_logic;
	signal valid_s2_reg	: std_logic;
	signal pixel_s2_reg 	: unsigned (7 downto 0);
	signal pixel_extend: signed (8 downto 0);
	--signal cosLUT_mk_reg	: signed (8 downto 0);
	--signal cosLUT_nl_reg	: signed (8 downto 0);
	signal mult_LUT_reg    : signed (17 downto 0);
	
	--stage 3 handshake and data_reg
	signal stall_s3		: std_logic;
	signal valid_s3_reg	: std_logic;
	signal sum_reg		: signed (31 downto 0);
	
	-- in and out stage
	signal stall_s4 	: std_logic;
	signal valid_s0_reg : std_logic;
	
	-- control signals
	signal clear_sum		: std_logic;
	signal pixel_done		: std_logic;
	signal kernel_done		: std_logic;
begin
	pixel_extend <= signed(resize(pixel_s2_reg, 9));
	-- handshake: in and out stages
	next_in <= not stall_s1;
	out_valid <= '1' when (valid_s1_reg = '1') and (valid_s2_reg = '1') and (m_reg = "000") and (n_reg = "000") else '0'; 
	stall_s4 <= not next_out;
	valid_s0_reg <= in_valid;
	
	DCT_val_out	<= sum_wire;
	--------------------------------------------------------------------
	-- Stage 1
	stall_s1 <= valid_s1_reg and stall_s2;
	
	Stage1_valid_data: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				valid_s1_reg <= '0';
				pixel_s1_reg <= (others=>'0');
			else
				if stall_s1 = '0' then
					valid_s1_reg <= valid_s0_reg;
					if valid_s0_reg = '1' then
						pixel_s1_reg <= pixel_val_in;
					end if;
				end if;
			end if;
		end if;
	end process;
	--------------------------------------------------------------------
	-- Stage 2
	stall_s2 <= valid_s2_reg and stall_s3;
	
	Stage2_valid_data: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				valid_s2_reg <= '0';
				--cosLUT_mk_reg <= (others => '0');
				--cosLUT_nl_reg <= (others => '0');
				mult_LUT_reg  <= (others => '0');
				pixel_s2_reg <= (others => '0');
			else
				if stall_s2 = '0' then
					valid_s2_reg <= valid_s1_reg;
					if valid_s1_reg = '1' then
						--cosLUT_mk_reg <= cosLUT_mk;
						--cosLUT_nl_reg <= cosLUT_nl;
						mult_LUT_reg <= mult_LUT;
						pixel_s2_reg <= pixel_s1_reg;
					end if;
				end if;
			end if;
		end if;
	end process;
	--------------------------------------------------------------------
	-- Stage 3
	stall_s3 <= '1' when (valid_s3_reg = '1') and (stall_s4 = '1') and (m_reg = "111") and (n_reg = "111") else '0';
	
	Stage3_valid_data: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				valid_s3_reg <= '0';
				sum_reg <= (others => '0');
			else
				if stall_s3 = '0' then
					valid_s3_reg <= valid_s2_reg;
					if valid_s2_reg = '1' then
						sum_reg <= sum_wire;
					end if;
				end if;
			end if;
		end if;
	end process;
	--------------------------------------------------------------------
	-- control sigs
	-- m_reg n_reg
	pixel_done <= '1' when stall_s1 = '0' and valid_s0_reg = '1' else '0';

	mn_regs: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				m_reg <= "111";
				n_reg <= "111";
			else
				if pixel_done = '1' then
					n_reg <= n_reg + "001";
					if n_reg = "111" then
						m_reg <= m_reg + "001";
					end if;
				end if;
			end if;
		end if;
	end process;
	-- k_reg l_reg
	kernel_done <= '1' when (pixel_done = '1') and m_reg = "111" and n_reg = "111" else '0';
	
	kl_regs: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				k_reg <= "000";
				l_reg <= "000";
			else
				if kernel_done = '1' then
					k_reg <= k;
					l_reg <= el;
				end if;
			end if;
		end if;
	end process;
		
	-- clear_sum_reg
	clear_sum <= '1' when m_reg = "000" and n_reg = "001" else '0';
	--------------------------------------------------------------------
	-- combinational computation
	mult_LUT 	<= cosLUT_mk 	* cosLUT_nl	;
	--mult_LUT 	<= cosLUT_mk_reg 	* cosLUT_nl_reg	;
	mult_pixel 	<= resize(pixel_extend * mult_LUT_reg, 26);
	sum_mult 	<= sum_reg 		+ resize(mult_pixel, sum_mult'length);
	sum_wire <= sum_mult when clear_sum = '0' else resize(mult_pixel, sum_wire'length);
	
	
	-- instantiate 2 cosLUT, all combinational logic
	cosLUT_mknl: entity work.cosLUT
	port map (
		m   	=> m_reg,
		k 		=> k_reg,
		n   	=> n_reg,
		l 		=> l_reg,
		lut_out_mk	=> cosLUT_mk,
		lut_out_nl	=> cosLUT_nl
	);

end rtl;
