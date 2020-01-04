-- Component: ORreduce_Line
-- Desc: a single level of OR reduce
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity ORreduce_Line is
generic (
	level : natural := 1
);
port (
	input : in std_logic_vector((2**level)-1 downto 0);
	output : out std_logic_vector((2**(level-1))-1 downto 0)
);
end ORreduce_Line;

architecture rtl of ORreduce_Line is
begin
	or_ports: for i in 0 to ((2**(level-1))-1) generate
		output(i) <= input(i*2) or input(i*2+1);
	end generate;
end rtl;
