-- Component: HierComparator
-- Desc: The first block in the heirarchical comparator
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity HierComparator is
generic (
	nbits : integer := 16
);
port (
	a : in std_logic_vector(nbits-1 downto 0);
	b : in std_logic_vector(nbits-1 downto 0);
	gt : out std_logic;
	eq : out std_logic
);
end HierComparator;

architecture rtl of HierComparator is
	component Cmp_InputBlock is
	port (
		a : in std_logic;
		b : in std_logic;
		gt : out std_logic;
		eq : out std_logic
	);
	end component;
	signal ib_a : std_logic_vector(nbits-1 downto 0);
	signal ib_b : std_logic_vector(nbits-1 downto 0);
	signal ib_gt : std_logic_vector(nbits-1 downto 0);
	signal ib_eq : std_logic_vector(nbits-1 downto 0);

	-- component Cmp_BodyBlock is
	-- port (
	-- 	gt1 : in std_logic;
	-- 	eq1 : in std_logic;
	-- 	gt2 : in std_logic;
	-- 	eq2 : in std_logic;
	-- 	gt : out std_logic;
	-- 	eq : out std_logic
	-- );
	-- end component;

	component Cmp_BodyLine is
	generic (
		level : natural := 1
	);
	port (
		in_gt : in std_logic_vector(2**level-1 downto 0);
		in_eq : in std_logic_vector(2**level-1 downto 0);
		out_gt : out std_logic_vector(2**(level-1)-1 downto 0);
		out_eq : out std_logic_vector(2**(level-1)-1 downto 0)
	);
	end component;
	constant levels : integer := positive(ceil(log2(real(nbits))));

	signal sgt : std_logic_vector(2*nbits-1 downto 0);
	signal seq : std_logic_vector(2*nbits-1 downto 0);
begin
	inputblocks : for i in nbits-1 downto 0 generate
		ib : Cmp_InputBlock
		port map (
			a => ib_a(i),
			b => ib_b(i),
			gt => ib_gt(i),
			eq => ib_eq(i)
		);
	end generate;
	ib_a <= a;
	ib_b <= b;

	bodyblocks : for i in levels downto 1 generate
	begin
		blockline : Cmp_BodyLine generic map (level => i)
		port map (
			in_gt  => sgt((2**(i+1))-1 downto 2**i),
			in_eq  => seq((2**(i+1))-1 downto 2**i),
			out_gt => sgt((2**i)-1 downto 2**(i-1)),
			out_eq => seq((2**i)-1 downto 2**(i-1))
		);
	end generate;

	gt <= sgt(1);
	eq <= seq(1);
	-- lastblock : Cmp_BodyBlock
	-- port map (
	-- 	gt1 => sgt(2),
	-- 	eq1 => seq(2),
	-- 	gt2 => sgt(1),
	-- 	eq2 => seq(1),
	-- 	gt => gt,
	-- 	eq => eq
	-- );
	sgt(2*nbits-1 downto nbits) <= ib_gt;
	seq(2*nbits-1 downto nbits) <= ib_eq;
end rtl;
