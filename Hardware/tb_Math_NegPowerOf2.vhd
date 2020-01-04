-- Component: tb_Math_NegPowerOf2
-- Desc: testbench for Math_NegPowerOf2
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_NegPowerOf2 is
end tb_Math_NegPowerOf2;

architecture rtl of tb_Math_NegPowerOf2 is
	component Math_NegPowerOf2 is
	generic (
		nbits : integer := 32
	);
	port (
		power_of_2 : in std_logic_vector(nbits-1 downto 0);
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal uut_in : std_logic_vector(31 downto 0);
	signal uut_out : std_logic_vector(31 downto 0);
begin
	uut : Math_NegPowerOf2 generic map (32) port map (uut_in, uut_out);
	stimproc : process
	begin
		uut_in <= x"00000000";
		wait for 1 ns;
		uut_in <= x"00000001";
		wait for 1 ns;
		uut_in <= x"00008000";
		wait for 1 ns;
		uut_in <= x"40000000";
		wait for 1 ns;
		uut_in <= x"FFFFFFFF"; -- already negative: no action
		wait for 1 ns;
		wait;
	end process;
end rtl;
