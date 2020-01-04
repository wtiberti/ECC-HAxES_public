-- Component: Math_Sub
-- Desc: A n-bit ripple subtractor
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Sub is
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
end Math_Sub;

architecture ripple of Math_Sub is
	component FullSubtractor is
	port (
		A : in std_logic;
		B : in std_logic;
		Borrow_in : in std_logic;
		Diff : out std_logic;
		Borrow_out : out std_logic
	);
	end component;

	signal vect_of_A : std_logic_vector(nbits-1 downto 0);
	signal vect_of_B : std_logic_vector(nbits-1 downto 0);
	signal vect_of_Result : std_logic_vector(nbits-1 downto 0);
	signal vect_of_Borrow_in : std_logic_vector(nbits-1 downto 0);
	signal vect_of_Borrow_out : std_logic_vector(nbits-1 downto 0);
begin
	vect_of_A <= A;
	vect_of_B <= B;
	Diff <= vect_of_Result;

	subtractors: for i in 0 to nbits-1 generate
		sub_x : FullSubtractor
		port map (
			A => vect_of_A(i),
			B => vect_of_B(i),
			Borrow_in => vect_of_Borrow_in(i),
			Diff => vect_of_Result(i),
			Borrow_out => vect_of_Borrow_out(i)
		);
	end generate;

	vect_of_Borrow_in(0) <= Borrow_in;
	borrow_propagation: for i in 1 to nbits-1 generate
		vect_of_Borrow_in(i) <= vect_of_Borrow_out(i-1);
	end generate;
	Borrow_out <= vect_of_Borrow_out(nbits-1);
end ripple;
