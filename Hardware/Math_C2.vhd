-- Component: Math_C2
-- Desc: A 2-Complement calculator (combinatorial, no adder)
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_C2 is
generic (
	nbits : integer := 32
);
port (
	input : in std_logic_vector(nbits-1 downto 0);
	output : out std_logic_vector(nbits-1 downto 0)
);
end Math_C2;

architecture rtl of Math_C2 is
	signal result : std_logic_vector(nbits-1 downto 0);
	signal was_there_an_invertion : std_logic_vector(nbits-1 downto 0);
begin
	was_there_an_invertion(0) <= '0';
	result(0) <= input(0);
	c2gen: for i in 1 to nbits-1 generate
		was_there_an_invertion(i) <= input(i-1) or result(i-1);
		result(i) <= input(i) xor was_there_an_invertion(i);
	end generate;
	output <= result;
end rtl;
