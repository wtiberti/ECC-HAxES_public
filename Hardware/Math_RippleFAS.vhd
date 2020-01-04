-- Component: Math_RippleFAS
-- Desc: Ripple n bit adder/subtractor
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_RippleFAS is
generic (
	nbits : integer := 16
);
port (
	a : in std_logic_vector(nbits-1 downto 0);
	b : in std_logic_vector(nbits-1 downto 0);
	op : in std_logic; -- 0 = add, 1 = sub
	cbi : in std_logic;
	y : out std_logic_vector(nbits-1 downto 0);
	cbo : out std_logic
);
end Math_RippleFAS;

architecture rtl of Math_RippleFAS is
	component FullAddSub is
	port (
		a : in std_logic;
		b : in std_logic;
		op : in std_logic; -- 0 = add, 1 = sub
		cbi : in std_logic;
		y : out std_logic;
		cbo : out std_logic
	);
	end component;
	signal ripple_a : std_logic_vector(nbits-1 downto 0);
	signal ripple_b : std_logic_vector(nbits-1 downto 0);
	signal ripple_cbi : std_logic_vector(nbits-1 downto 0);
	signal ripple_y : std_logic_vector(nbits-1 downto 0);
	signal ripple_cbo : std_logic_vector(nbits-1 downto 0);
begin
	ripple_cbi(0) <= cbi;
	ripple_a <= a;
	ripple_b <= b;
	ripples : for i in 0 to nbits-1 generate
		fas : FullAddSub
		port map (
			a => ripple_a(i),
			b => ripple_b(i),
			op => op,
			cbi => ripple_cbi(i),
			y => ripple_y(i),
			cbo => ripple_cbo(i)
		);
	end generate;

	carries : for i in 1 to nbits-1 generate
		ripple_cbi(i) <= ripple_cbo(i-1);
	end generate;

	y <= ripple_y;
	cbo <= ripple_cbo(nbits-1);
end rtl;
