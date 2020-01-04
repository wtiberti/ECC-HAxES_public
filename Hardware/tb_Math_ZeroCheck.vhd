-- Component: tb_Math_ZeroCheck
-- Desc: Testbench for Math_ZeroCheck
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_ZeroCheck is
end tb_Math_ZeroCheck;

architecture rtl of tb_Math_ZeroCheck is
	component Math_ZeroCheck is
	generic (
		nbits : integer := 8
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		result : out std_logic
	);
	end component;
	signal i : std_logic_vector(191 downto 0);
	signal o : std_logic;
begin
	zc : Math_ZeroCheck generic map (nbits => 192)
	port map (
		input => i,
		result => o
	);

	process
	begin
		i <= x"000000000000000000000000000000000000000000000000";
		wait for 20 ns;
		i <= x"0000000000000000000000000000000000000F0000000000";
		wait for 20 ns;
		wait;
	end process;


end rtl;
