-- Component: Math_Comparator.vhd
-- Desc: Check whether two signals are equal
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Comparator is
generic (
	nbits : integer := 8
);
port (
	input0 : in std_logic_vector(nbits-1 downto 0);
	input1 : in std_logic_vector(nbits-1 downto 0);
	result : out std_logic

);
end Math_Comparator;

architecture rtl of Math_Comparator is
	signal xored : std_logic_vector(nbits-1 downto 0);

	component Math_ZeroCheck is
	generic (
		nbits : integer := 8
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		result : out std_logic
	);
	end component;
	signal zc_in : std_logic_vector(nbits-1 downto 0);
	signal zc_out : std_logic;
begin
	zc : Math_ZeroCheck generic map (nbits => nbits)
	port map (
		input => zc_in,
		result => zc_out
	);

	xors : for i in 0 to nbits-1 generate
		xored(i) <= input0(i) xor input1(i);
	end generate xors;

	zc_in <= xored;
	result <= zc_out;
end rtl;
