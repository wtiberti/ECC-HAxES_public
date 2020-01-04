-- Component: Math_Add_modN
-- Desc: Adder mod N
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Add_modN is
generic (
	nbits : integer := 16
);
port (
	carry_in : in std_logic;
	a : in std_logic_vector(nbits-1 downto 0);
	b : in std_logic_vector(nbits-1 downto 0);
	n : in std_logic_vector(nbits-1 downto 0);
	sum : out std_logic_vector(nbits-1 downto 0);
	carry_out : out std_logic
);
end Math_Add_modN;

architecture rtl of Math_Add_modN is
	component Math_Sub is
	generic (
		nbits : integer := 16
	);
	port (
		A : in std_logic_vector(nbits-1 downto 0);
		B : in std_logic_vector(nbits-1 downto 0);
		Borrow_in : in std_logic;
		Diff : out std_logic_vector(nbits-1 downto 0);
		Borrow_out : out std_logic
	);
	end component;
	signal sub_a : std_logic_vector(nbits downto 0);
	signal sub_b : std_logic_vector(nbits downto 0);
	signal sub_diff : std_logic_vector(nbits downto 0);
	signal sub_bi : std_logic;
	signal sub_bo : std_logic;

	component Math_Add is
	generic (
		nbits : integer := 16
	);
	port (
		carryin : in std_logic;
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		sum : out std_logic_vector(nbits-1 downto 0);
		carryout : out std_logic
	);
	end component;
	signal add_ci : std_logic;
	signal add_co : std_logic;
	signal add_a : std_logic_vector(nbits-1 downto 0);
	signal add_b : std_logic_vector(nbits-1 downto 0);
	signal add_sum : std_logic_vector(nbits-1 downto 0);

	component Mux_2to1 is
	generic (
		nbits : integer := 16
	);
	port (
		input0 : in std_logic_vector(nbits-1 downto 0);
		input1 : in std_logic_vector(nbits-1 downto 0);
		sel : in std_logic;
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal mux_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_sel : std_logic;
	signal mux_out : std_logic_vector(nbits-1 downto 0);

begin
	adder : Math_Add generic map (nbits => nbits)
	port map (
		carryin => add_ci,
		a => add_a,
		b => add_b,
		sum => add_sum,
		carryout => add_co
	);
	sub : Math_Sub generic map (nbits => nbits+1)
	port map (
		A => sub_a,
		B => sub_b,
		Borrow_in => sub_bi,
		Diff => sub_diff,
		Borrow_out => sub_bo
	);
	mux : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_in0,
		input1 => mux_in1,
		sel => mux_sel,
		output => mux_out
	);
	-- ================================================
	add_a <= a;
	add_b <= b;
	add_ci <= '0';
	sub_a <= add_co & add_sum;
	sub_b <= '0' & n;
	sub_bi <= '0';
	mux_in0 <= sub_diff(nbits-1 downto 0);
	mux_in1 <= add_sum;
	mux_sel <= sub_bo;
	sum <= mux_out;

	-- Trick : if sub_bo is 1, the carry is the carryout of the adder
	-- else, it's just '0'
	carry_out <= sub_bo and add_co;
end rtl;
