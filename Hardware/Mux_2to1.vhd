-- Component: Mux_2to1
-- Desc: A standard 2 input to 1 output mux
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Mux_2to1 is
generic (
	nbits : integer := 16
);
port (
	input0 : in std_logic_vector(nbits-1 downto 0);
	input1 : in std_logic_vector(nbits-1 downto 0);
	sel : in std_logic;
	output : out std_logic_vector(nbits-1 downto 0)
);
end Mux_2to1;

architecture rtl of Mux_2to1 is

begin
	output <= input0 when sel = '0' else
		  input1;
end rtl;
