-- Component: ORreduce
-- Desc: A tree-shaped OR/NOR reduce
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity ORreduce is
generic (
	nbits : integer := 32;
	do_invert : boolean := false
);
port (
	input : in std_logic_vector(nbits-1 downto 0);
	output : out std_logic
);
end ORreduce;

architecture rtl of ORreduce is
	component ORreduce_Line is
	generic (
		level : natural := 1
	);
	port (
		input : in std_logic_vector((2**level)-1 downto 0);
		output : out std_logic_vector((2**(level-1))-1 downto 0)
	);
	end component;
	signal lines_io : std_logic_vector((2*nbits)-1 downto 0);
	constant levels : integer := positive(ceil(log2(real(nbits))));
	signal function_selected : natural;
begin
	lines_io((2*nbits)-1 downto nbits) <= input;
	gen_lines : for i in levels downto 1 generate
		level_line : ORreduce_Line generic map (level => i)
		port map (
			input => lines_io((2**(i+1))-1 downto 2**i),
			output => lines_io((2**i)-1 downto (2**(i-1)))
		);
	end generate;
	lines_io(0) <= not lines_io(1);
	function_selected <= 0 when do_invert = true else 1;
	output <= lines_io(function_selected);
end rtl;
