-- Component: tb_Math_Sub_modN
-- Desc: Testbed for the Math_Sub_modN component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Sub_modN is
end tb_Math_Sub_modN;

architecture rtl of tb_Math_Sub_modN is
	component Math_Sub_modN is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		diff : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal a : std_logic_vector(15 downto 0);
	signal b : std_logic_vector(15 downto 0);
	signal n : std_logic_vector(15 downto 0);
	signal diff : std_logic_vector(15 downto 0);
begin
	uut : Math_Sub_modN generic map (nbits => 16)
	port map (
		a => a,
		b => b,
		n => n,
		diff => diff
	);

	stim: process
	begin
		n <= x"007F"; -- 127
		-- case 1: normal subtraction
		a <= x"0100";
		b <= x"00EE"; -- result = 0x100-0xEE = 0x12
		wait for 20 ns;
		-- case 2: underflow + addition
		a <= x"0000";
		b <= x"0060"; -- result = 0x0-0x60 = -0x60 = 0xFFA0, 0xFFA0 + 0x7F = 0x6F
		wait for 20 ns;
		wait;
	end process;
end rtl;
