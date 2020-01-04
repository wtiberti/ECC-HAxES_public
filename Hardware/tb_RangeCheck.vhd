-- Component: tb_RangeCheck
-- Desc: Testbench for RangeCheck
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_RangeCheck is
end tb_RangeCheck;

architecture rtl of tb_RangeCheck is
	component RangeCheck is
	generic (
		nbits : integer := 16
	);
	port (
		value : in std_logic_vector(nbits-1 downto 0);
		range_max : in std_logic_vector(nbits-1 downto 0);
		range_min : in std_logic_vector(nbits-1 downto 0);
		result : out std_logic
	);
	end component;
	signal v : std_logic_vector(15 downto 0);
	signal maxv : std_logic_vector(15 downto 0);
	signal minv : std_logic_vector(15 downto 0);
	signal res : std_logic;
begin
	rc : RangeCheck generic map (nbits => 16)
	port map (
		value => v,
		range_max => maxv,
		range_min => minv,
		result => res
	);

	process
	begin
		v <= x"ABCD";
		maxv <= x"EEEE";
		minv <= x"AAAA"; -- true
		wait for 20 ns;
		maxv <= x"EEEE";
		minv <= x"BBBB"; -- under (false)
		wait for 20 ns;
		maxv <= x"AAAA"; -- above (false)
		minv <= x"8888";
		wait for 20 ns;
		maxv <= x"ABCD"; -- max = value (true)
		minv <= x"8888";
		wait for 20 ns;
		maxv <= x"CCCC";
		minv <= x"ABCD"; -- min = value (true)
		wait for 20 ns;
		wait;
	end process;
end rtl;
