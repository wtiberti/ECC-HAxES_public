-- Component: Reg_PIPO
-- Desc: A generic n-bit PIPO register
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Reg_PIPO is
generic (
	nbits : integer := 16
);
port (
	input : in std_logic_vector(nbits-1 downto 0);
	clk : in std_logic;
	rst : in std_logic;
	output : out std_logic_vector(nbits-1 downto 0)
);
end Reg_PIPO;

architecture rtl of Reg_PIPO is
signal reg_in : std_logic_vector(nbits-1 downto 0);
signal reg_out : std_logic_vector(nbits-1 downto 0);
begin
	reg_in <= input;
	main : process(clk, rst)
	begin
		if (rst = '1') then
			reg_out <= (others => '0');
		else
			if rising_edge(clk) then
				reg_out <= reg_in;
			end if;
		end if;
	end process;
	output <= reg_out;
end rtl;
