-- Component: tb_Math_SerialMul
-- Desc: testbench for Math_SerialMul
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_SerialMul is
end tb_Math_SerialMul;

architecture rtl of tb_Math_SerialMul is
	component Math_SerialMul is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		clk : in std_logic;
		start : in std_logic;
		y : out std_logic_vector((2*nbits)-1 downto 0);
		done : out std_logic
	);
	end component;
	signal uut_a : std_logic_vector(31 downto 0);
	signal uut_b : std_logic_vector(31 downto 0);
	signal uut_y : std_logic_vector(63 downto 0);
	signal uut_clk : std_logic;
	signal uut_start : std_logic;
	signal uut_done : std_logic;
begin
	uut: Math_SerialMul generic map (nbits => 32) port map (uut_a, uut_b, uut_clk, uut_start, uut_y, uut_done);

	clk_proc : process
	begin
		uut_clk <= '0';
		wait for 10 ns;
		uut_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		uut_start <= '0';
		uut_a <= x"10000000";
		uut_b <= x"11223344";
		wait for 15 ns;
		uut_start <= '1';
		wait until uut_done = '1';
		wait for 15 ns;
		uut_start <= '0';
		uut_a <= x"55667788";
		uut_b <= x"11223344";
		wait for 15 ns;
		uut_start <= '1';
		wait until uut_done = '1';
		wait for 15 ns;
		wait;
	end process;
end rtl;
