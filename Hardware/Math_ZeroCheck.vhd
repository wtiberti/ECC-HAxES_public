-- Component: Math_ZeroCheck
-- Desc: Check whether a signal is 0
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_ZeroCheck is
generic (
	nbits : integer := 8
);
port (
	input : in std_logic_vector(nbits-1 downto 0);
	result : out std_logic
);
end Math_ZeroCheck;

architecture rtl of Math_ZeroCheck is
	function nor_reduce(arg : std_logic_vector(nbits-1 downto 0)) return std_logic is
		variable ret : std_logic;
	begin
		ret := arg(0);
		for i in nbits-1 downto 1 loop
			ret := ret or arg(i);
		end loop;
		return not ret;
	end nor_reduce;
	signal nx :  std_logic;
begin
	-- NOR
	--	A	B	Y
	-------------------------
	--	0	0	1
	--	0	1	0
	--	1	0	0
	--	1	1	0
	result <= nor_reduce(input);
end rtl;
