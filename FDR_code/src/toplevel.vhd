--Engineer     : Haines Todd
--Date         : 11/26/2018
--Name of file : toplevel.VHD
--Description  : Combines the toplevel_DCT module, BRAM IP instances, and VGA controller into one entity
--				Input/Output ports in this entity go to physical ports on the Basy's Board

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
	port (
		-- input side
		clk, rst      	: in  std_logic;
		
		--define physical ports to VGA connector
		Red 	: out STD_LOGIC_VECTOR (3 downto 0);
		Green 	: out STD_LOGIC_VECTOR (3 downto 0);
		Blue 	: out STD_LOGIC_VECTOR (3 downto 0);
		Hsync 	: out STD_LOGIC;
		Vsync 	: out STD_LOGIC
	);
end toplevel;

architecture structural of toplevel is

COMPONENT bram_dual_port_ip
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
  );
END COMPONENT;


COMPONENT BRAM_IP
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;
	
	signal BROM_read_wire	: std_logic;
	signal BROM_addr_wire	: std_logic_vector(14 downto 0);
	signal BROM_data_wire	: std_logic_vector(7 downto 0);
	
	signal DCT_RAM_INPORT_write_wire	: std_logic_vector(0 downto 0);
	signal DCT_RAM_INPORT_addr_wire		: std_logic_vector(14 downto 0);
	signal DCT_RAM_INPORT_data_wire		: signed(17 downto 0);
	
	signal DCT_RAM_OUTPORT_read_wire	: std_logic;
	signal DCT_RAM_OUTPORT_addr_wire	: std_logic_vector(14 downto 0);
	signal DCT_RAM_OUTPORT_data_wire	: std_logic_vector(17 downto 0);
	
	signal Red_wire 	:  std_logic_vector (3 downto 0);
	signal Green_wire 	:  std_logic_vector (3 downto 0);
	signal Blue_wire 	:  std_logic_vector (3 downto 0);
	signal Hsync_wire 	:  std_logic;
	signal Vsync_wire 	:  std_logic;
	
	signal clk_cntr : unsigned( 3 downto 0) := (others => '0');
	signal clk25Mhz : std_logic;
	
	

begin

--	BROM_addr 		<= BROM_addr_wire;
--	BROM_data_wire 	<= BROM_data;
--	BROM_read 		<= BROM_read_wire;
	
--	DCT_RAM_data 	<= DCT_RAM_data_wire;
--	DCT_RAM_write 	<= DCT_RAM_write_wire;
	
	
	
	clk25Mhz <= clk_cntr(1);
	
	clk_div: process(clk)
		begin
			if(rising_edge(clk)) then
				clk_cntr <= clk_cntr + 1;
			end if;
		end process clk_div;
	
	
	
	input_image_BRAM : BRAM_IP
	port map (
		clka	=> clk,
		ena	=> BROM_read_wire,
		wea	=> (others => '0'),
		addra	=> BROM_addr_wire,
		dina	=> (others => '0'),
		douta	=> BROM_data_wire
	);
	
	
	toplevel_DCT_inst : entity  work.toplevel_DCT
	port map (
		-- input side
		clk 			=> clk,
		rst				=> rst,
		
		BROM_addr		=> BROM_addr_wire,
		BROM_data		=> BROM_data_wire,
		BROM_read		=> BROM_read_wire,
		
		DCT_RAM_addr	=> DCT_RAM_INPORT_addr_wire,
		DCT_RAM_data	=> DCT_RAM_INPORT_data_wire,
		DCT_RAM_write	=> DCT_RAM_INPORT_write_wire(0)
	);
	
	
	dct_RAM_dual_port : bram_dual_port_ip
      PORT MAP (
        clka => clk,
        ena => '1',
        wea => DCT_RAM_INPORT_write_wire,
        addra => DCT_RAM_INPORT_addr_wire,
        dina => STD_LOGIC_VECTOR(DCT_RAM_INPORT_data_wire),
        clkb => clk25Mhz,
        enb => '1',
        addrb => DCT_RAM_OUTPORT_addr_wire,
        doutb => DCT_RAM_OUTPORT_data_wire
      );
	
	
	vga_top_inst : entity work.vga_top
    port map (
	
		DCT_RAM_addr	=> DCT_RAM_OUTPORT_addr_wire,
		DCT_RAM_data	=> signed(DCT_RAM_OUTPORT_data_wire),
		DCT_RAM_read	=> DCT_RAM_OUTPORT_read_wire,
	
		clk 	=> clk,
		clk25Mhz=> clk25Mhz,
		Red 	=> Red_wire,
		Green 	=> Green_wire,
		Blue 	=> Blue_wire,
		Hsync 	=> Hsync_wire,
		Vsync 	=> Vsync_wire
	);


end structural;