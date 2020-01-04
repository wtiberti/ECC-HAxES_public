-- Component: Cmp_InputBlock
-- Desc: The first block in the heirarchical comparator
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Cmp_InputBlock is
port (
	a : in std_logic;
	b : in std_logic;
	gt : out std_logic;
	eq : out std_logic
);
end Cmp_InputBlock;

architecture rtl of Cmp_InputBlock is
begin
	-- a is greater than b only if
	-- a == 1 and b == 0
	gt <= a and (not b);

	-- a is equal to b only if
	-- a xor b == 0
	eq <= a xnor b;
end rtl;
