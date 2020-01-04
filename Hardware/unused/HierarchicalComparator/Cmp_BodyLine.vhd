-- Component: Cmp_BodyLine
-- Desc: Represent a single level (line) of Cmp_BodyBlock, so
--       that it is possible to stack different levels
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Cmp_BodyLine is
generic (
	level : natural := 1
);
port (
	in_gt : in std_logic_vector(2**level-1 downto 0);
	in_eq : in std_logic_vector(2**level-1 downto 0);
	out_gt : out std_logic_vector(2**(level-1)-1 downto 0);
	out_eq : out std_logic_vector(2**(level-1)-1 downto 0)
);
end Cmp_BodyLine;

architecture rtl of Cmp_BodyLine is
	component Cmp_BodyBlock is
	port (
		gt1 : in std_logic;
		eq1 : in std_logic;
		gt2 : in std_logic;
		eq2 : in std_logic;
		gt : out std_logic;
		eq : out std_logic
	);
	end component;
	signal igt : std_logic_vector(2**level-1 downto 0);
	signal ieq : std_logic_vector(2**level-1 downto 0);
	signal ogt : std_logic_vector(2**(level-1)-1 downto 0);
	signal oeq : std_logic_vector(2**(level-1)-1 downto 0);
begin
	igt <= in_gt;
	ieq <= in_eq;
	cmpline : for i in 2**(level-1)-1 downto 0 generate
		blk : Cmp_BodyBlock
		port map (
			gt1 => igt(2*i+1),
			eq1 => ieq(2*i+1),
			gt2 => igt(2*i),
			eq2 => ieq(2*i),
			gt => ogt(i),
			eq => oeq(i)
		);
	end generate;
	out_gt <= ogt;
	out_eq <= oeq;
end rtl;
