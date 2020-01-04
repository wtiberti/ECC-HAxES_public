-- Component: Mux_4to1
-- Desc: A standard 4 input to 1 output mux
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Mux_4to1 is
generic (
	nbits : integer := 16
);
port (
	input0 : in std_logic_vector(nbits-1 downto 0);
	input1 : in std_logic_vector(nbits-1 downto 0);
	input2 : in std_logic_vector(nbits-1 downto 0);
	input3 : in std_logic_vector(nbits-1 downto 0);
	sel : in std_logic_vector(1 downto 0);
	output : out std_logic_vector(nbits-1 downto 0)
);
end Mux_4to1;

architecture rtl of Mux_4to1 is

begin
	output <= input0 when sel = "00" else
		  input1 when sel = "01" else
		  input2 when sel = "10" else
		  input3;
end rtl;
