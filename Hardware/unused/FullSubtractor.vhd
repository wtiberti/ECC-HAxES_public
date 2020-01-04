-- Component: FullSubtractor
-- Desc: A standard 1-bit Full Subtractor
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity FullSubtractor is
port (
	A : in std_logic;
	B : in std_logic;
	Borrow_in : in std_logic;
	Diff : out std_logic;
	Borrow_out : out std_logic
);
end FullSubtractor;

architecture rtl of FullSubtractor is
begin
	Diff <= A xor B xor Borrow_in;
	Borrow_out <= '1' when Borrow_in = '0' and A = '0' and B = '1' else
		      '1' when Borrow_in = '1' and A = '0' else
		      '1' when Borrow_in = '1' and A = '1' and B = '1' else
		      '0';
end rtl;
