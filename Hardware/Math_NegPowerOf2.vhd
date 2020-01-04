-- Component: Math_NegPowerOf2
-- Desc: output negative value for 2^n numbers (small area footprint)
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_NegPowerOf2 is
generic (
	nbits : integer := 32
);
port (
	power_of_2 : in std_logic_vector(nbits-1 downto 0);
	output : out std_logic_vector(nbits-1 downto 0)
);
end Math_NegPowerOf2;

architecture rtl of Math_NegPowerOf2 is
	signal result : std_logic_vector(nbits-1 downto 0);
begin
	result(0) <= power_of_2(0);
	ripplegen : for i in 1 to nbits-1 generate
		result(i) <= power_of_2(i) or result(i-1);
	end generate;
	output <= result;
end rtl;
