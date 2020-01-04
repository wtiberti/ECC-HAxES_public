-- Component: Math_Sub_modN
-- Desc: A subtractor modulo N which can also invert resulting negative values
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Sub_modN is
generic (
	nbits : integer := 16
);
port (
	borrow_in : in std_logic;
	a : in std_logic_vector(nbits-1 downto 0);
	b : in std_logic_vector(nbits-1 downto 0);
	n : in std_logic_vector(nbits-1 downto 0);
	borrow_out : out std_logic;
	diff : out std_logic_vector(nbits-1 downto 0)
);
end Math_Sub_modN;

architecture rtl of Math_Sub_modN is
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
	signal sub_a : std_logic_vector(nbits-1 downto 0);
	signal sub_b : std_logic_vector(nbits-1 downto 0);
	signal sub_bi : std_logic;
	signal sub_diff : std_logic_vector(nbits-1 downto 0);
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
	signal adder_carryin : std_logic;
	signal adder_a : std_logic_vector(nbits-1 downto 0);
	signal adder_b : std_logic_vector(nbits-1 downto 0);
	signal adder_sum : std_logic_vector(nbits-1 downto 0);
	signal adder_carryout : std_logic;

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
	sub : Math_Sub generic map (nbits => nbits)
	port map (
		A => sub_a,
		B => sub_b,
		Borrow_in => sub_bi,
		Diff => sub_diff,
		Borrow_out => sub_bo
	);
	adder : Math_Add generic map (nbits => nbits)
	port map (
		carryin => adder_carryin,
		a => adder_a,
		b => adder_b,
		sum => adder_sum,
		carryout => adder_carryout
	);
	mux : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_in0,
		input1 => mux_in1,
		sel => mux_sel,
		output => mux_out
	);
	-- ================================================
	sub_a <= a;
	sub_b <= b;
	sub_bi <= borrow_in;
	adder_a <= sub_diff;
	adder_b <= n;
	adder_carryin <= '0';
	mux_in0 <= sub_diff;
	mux_in1 <= adder_sum;
	mux_sel <= sub_bo;
	borrow_out <= sub_bo;
	diff <= mux_out;
end rtl;
