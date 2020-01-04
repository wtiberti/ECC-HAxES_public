-- Component: Reg_SIPO
-- Desc:
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Reg_SIPO is
generic (
	nbits : integer := 16
);
port (
	input : in std_logic;
	clk : in std_logic;
	rst : in std_logic;
	output : out std_logic_vector(nbits-1 downto 0)
);
end Reg_SIPO;

architecture rtl of Reg_SIPO is
signal value : std_logic_vector(nbits-1 downto 0);
begin
	main : process(clk, rst)
	begin
		if (rst = '1') then
			value <= (others => '0');
		else
			if rising_edge(clk) then
				for i in nbits-1 downto 1 loop
					value(i-1) <= value(i);
				end loop;
				value(nbits-1) <= input;
			end if;
		end if;
	end process;
	output <= value;
end rtl;
