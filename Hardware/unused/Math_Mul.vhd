-- Component: Math_Mul
-- Desc: numeric_std unsigned multiplier
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Math_Mul is
generic (
	nbits : integer := 16
);
port (
	a : in std_logic_vector(nbits-1 downto 0);
	b : in std_logic_vector(nbits-1 downto 0);
	product : out std_logic_vector((2*nbits)-1 downto 0)
);
end Math_Mul;

architecture numericstdmul of Math_Mul is
	signal a_input : std_logic_vector(nbits-1 downto 0);
	signal b_input : std_logic_vector(nbits-1 downto 0);
	signal result : std_logic_vector((2*nbits)-1 downto 0);
begin
	a_input <= a;
	b_input <= b;
	mulproc : process(a_input, b_input)
		variable p : unsigned((2*nbits)-1 downto 0);
	begin
		p := unsigned(a_input) * unsigned(b_input);
		result <= std_logic_vector(p);
	end process;
	product <= result;
end numericstdmul;
