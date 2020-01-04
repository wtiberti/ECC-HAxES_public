-- Component: FullAdder.vhd
-- Desc: A standard 1-bit Full Adder
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity FullAdder is
port (
	A : in std_logic;
	B : in std_logic;
	Carry_in : in std_logic;
	Sum : out std_logic;
	Carry_out : out std_logic
);
end FullAdder;

architecture rtl of FullAdder is
begin
	--	C	A	B	S	CarryOut
	--	----------------------------------------
	--	0	0	0	0	0
	--	0	0	1	1	0
	--	0	1	0	1	0
	--	0	1	1	0	1
	--	1	0	0	1	0
	--	1	0	1	0	1
	--	1	1	0	0	1
	--	1	1	1	1	1
	Sum <= A xor B xor Carry_in;
	Carry_out <= (not Carry_in and (A and B)) or 
		     (Carry_in and (A or B));
end rtl;
