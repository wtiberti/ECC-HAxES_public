-- Component: RangeCheck
-- Desc: Determine whether the input value lies in a certain range
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity RangeCheck is
generic (
	nbits : integer := 16
);
port (
	value : in std_logic_vector(nbits-1 downto 0);
	range_max : in std_logic_vector(nbits-1 downto 0);
	range_min : in std_logic_vector(nbits-1 downto 0);
	result : out std_logic
);
end RangeCheck;

architecture rtl of RangeCheck is
	component HierComparator is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		gt : out std_logic;
		eq : out std_logic
	);
	end component;
	signal h1_a : std_logic_vector(nbits-1 downto 0);
	signal h1_b : std_logic_vector(nbits-1 downto 0);
	signal h1_gt : std_logic;
	signal h1_eq : std_logic;
	signal h2_a : std_logic_vector(nbits-1 downto 0);
	signal h2_b : std_logic_vector(nbits-1 downto 0);
	signal h2_gt : std_logic;
	signal h2_eq : std_logic;
begin
	max_cmp : HierComparator generic map (nbits => nbits)
	port map (
		a => h1_a,
		b => h1_b,
		gt => h1_gt,
		eq => h1_eq
	);
	min_cmp : HierComparator generic map (nbits => nbits)
	port map (
		a => h2_a,
		b => h2_b,
		gt => h2_gt,
		eq => h2_eq
	);
	h1_a <= value;
	h1_b <= range_max;
	h2_a <= value;
	h2_b <= range_min;
	-- The result is 1 only when the max_cmp has gt = 0 AND the min_cmp has (gt = 1 or eq = 1)
	result <= (not h1_gt) and (h2_gt or h2_eq);
end rtl;
