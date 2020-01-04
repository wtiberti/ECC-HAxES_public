-- Component: tb_Math_RippleFAS
-- Desc: Testbed for the Math_Add component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_RippleFAS is
end tb_Math_RippleFAS;

architecture rtl of tb_Math_RippleFAS is
	component Math_RippleFAS is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		op : in std_logic; -- 0 = add, 1 = sub
		cbi : in std_logic;
		y : out std_logic_vector(nbits-1 downto 0);
		cbo : out std_logic
	);
	end component;
	signal uut_a : std_logic_vector(31 downto 0);
	signal uut_b : std_logic_vector(31 downto 0);
	signal uut_op : std_logic;
	signal uut_y : std_logic_vector(31 downto 0);
	signal uut_cbo : std_logic;
	signal uut_cbi : std_logic;

begin
	uut : Math_RippleFAS generic map (nbits => 32)
	port map (
		a => uut_a,
		b => uut_b,
		op => uut_op,
		cbi => uut_cbi,
		y => uut_y,
		cbo => uut_cbo
	);

	stim: process
	begin
		uut_op <= '0';
		uut_cbi <= '0';
		uut_a <= x"44556677";
		uut_b <= x"11223344";
		wait for 10 ns;
		uut_cbi <= '1';
		wait for 10 ns;
		uut_cbi <= '0';
		uut_op <= '1';
		wait for 10 ns;
		uut_cbi <= '1';
		wait for 10 ns;
		wait;
	end process;
end rtl;
