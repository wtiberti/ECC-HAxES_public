-- Component: FullAddSub
-- Desc: A standard 1-bit Full Adder/Subtractor
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity FullAddSub is
port (
	a : in std_logic;
	b : in std_logic;
	op : in std_logic; -- 0 = add, 1 = sub
	cbi : in std_logic;
	y : out std_logic;
	cbo : out std_logic
);
end FullAddSub;

architecture rtl of FullAddSub is
begin
	y <= a xor b xor cbi;
	--
	--	opcbi\ab|00  01  11  10
	--	-----------------------
	--	00	| 0   0   1   0
	--	-----------------------
	--	01	| 0   1   1   1
	--	-----------------------
	--	11	| 1   1   1   0
	--	-----------------------
	--	10	| 0   1   0   0
	--	-----------------------
	--
	-- Note: (b and cbi) or ((a xor op) and b) or ((a xor op) and cbi)
	cbo <= (b and cbi) or
	       ((not a) and op and b) or
	       ((not a) and op and cbi) or
	       (a and (not op) and b) or
	       (a and (not op) and cbi);
end rtl;
