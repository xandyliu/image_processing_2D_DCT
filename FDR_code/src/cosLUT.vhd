--Engineer     : Xingyang Liu
--Name of file : cosLUT.vhd
--Description  : cosine look-up table. This module is the submodule of DCT_8x8_MAC.vhd
--				 receive index from DCT_8x8_MAC.vhd and output 2 cos values to DCT_8x8_MAC.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


--lookup table holding the values for the cosine function
-- cos( (pi/8) * k (m + 1/2) )

entity cosLUT is
    port(
    	m   : in unsigned(2 downto 0);
		k 	: in unsigned(2 downto 0);
		n   : in unsigned(2 downto 0);
		l 	: in unsigned(2 downto 0);
		lut_out_mk	: out signed(8 downto 0);
		lut_out_nl	: out signed(8 downto 0)
     );
end cosLUT;

architecture rtl of cosLUT is

	--Xandy's LUT values generated from Matlab simulation
	type array8x8x9bit is array (0 to 7, 0 to 7) of signed(8 downto 0);
	constant cosLUT : array8x8x9bit := (
		("011111111", "011111011", "011101101", "011010101", "010110101", "010001110", "001100010", "000110010"	),
		("011111111", "011010101", "001100010", "111001110", "101001011", "100000101", "100010011", "101110010"	),
		("011111111", "010001110", "110011110", "100000101", "101001011", "000110010", "011101101", "011010101"	),
		("011111111", "000110010", "100010011", "101110010", "010110101", "011010101", "110011110", "100000101"	),
		("011111111", "111001110", "100010011", "010001110", "010110101", "100101011", "110011110", "011111011"	),
		("011111111", "101110010", "110011110", "011111011", "101001011", "111001110", "011101101", "100101011"	),
		("011111111", "100101011", "001100010", "000110010", "101001011", "011111011", "100010011", "010001110"	),
		("011111111", "100000101", "011101101", "100101011", "010110101", "101110010", "001100010", "111001110"	)
	);


begin
	lut_out_mk <= cosLUT(to_integer(m), to_integer(k));
	lut_out_nl <= cosLUT(to_integer(n), to_integer(l));
end rtl;











