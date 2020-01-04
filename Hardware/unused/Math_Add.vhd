-- Component: Math_Add
-- Desc: Simple n bit adder
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Add is
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
end Math_Add;

architecture rtl of Math_Add is
	component FullAdder is
	port (
		A : in std_logic;
		B : in std_logic;
		Carry_in : in std_logic;
		Sum : out std_logic;
		Carry_out : out std_logic
	);
	end component;
	signal ripple_a : std_logic_vector(nbits-1 downto 0);
	signal ripple_b : std_logic_vector(nbits-1 downto 0);
	signal ripple_cin : std_logic_vector(nbits-1 downto 0);
	signal ripple_sum : std_logic_vector(nbits-1 downto 0);
	signal ripple_cout : std_logic_vector(nbits-1 downto 0);
begin
	ripple_cin(0) <= carryin;
	ripple_a <= a;
	ripple_b <= b;
	ripples : for i in 0 to nbits-1 generate
		adder : FullAdder
		port map (
			A => ripple_a(i),
			B => ripple_b(i),
			Carry_in => ripple_cin(i),
			Sum => ripple_sum(i),
			Carry_out => ripple_cout(i)
		);
	end generate;

	carries : for i in 1 to nbits-1 generate
		ripple_cin(i) <= ripple_cout(i-1);
	end generate;

	sum <= ripple_sum;
	carryout <= ripple_cout(nbits-1);
end rtl;
