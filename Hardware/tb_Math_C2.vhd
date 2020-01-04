-- Component: tb_Math_C2
-- Desc: testbench for Math_C2
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Math_C2 is
end tb_Math_C2;

architecture rtl of tb_Math_C2 is
	component Math_C2 is
	generic (
		nbits : integer := 32
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal uut_in : std_logic_vector(7 downto 0);
	signal uut_out : std_logic_vector(7 downto 0);
begin
	uut : Math_C2 generic map (nbits => 8) port map (uut_in, uut_out);
	stimproc : process
	begin
		for i in 0 to 255 loop
			uut_in <= std_logic_vector(to_unsigned(i, 8));
			wait for 10 ns;
		end loop;
	end process;
end rtl;
