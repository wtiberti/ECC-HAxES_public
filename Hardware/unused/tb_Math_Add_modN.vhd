-- Component: tb_Math_Add_modN
-- Desc: testbench for Math_Add_modN
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Add_modN is
end tb_Math_Add_modN;

architecture rtl of tb_Math_Add_modN is
	component Math_Add_modN is
	generic (
		nbits : integer := 16
	);
	port (
		carry_in : in std_logic;
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		sum : out std_logic_vector(nbits-1 downto 0);
		carry_out : out std_logic
	);
	end component;
	signal tb_carry_in : std_logic;
	signal tb_a : std_logic_vector(15 downto 0);
	signal tb_b : std_logic_vector(15 downto 0);
	signal tb_sum : std_logic_vector(15 downto 0);
	signal tb_carry_out : std_logic;
	signal tb_n : std_logic_vector(15 downto 0);
begin
	uut : Math_Add_modN generic map (nbits => 16)
	port map (
		carry_in => tb_carry_in,
		a => tb_a,
		b => tb_b,
		sum => tb_sum,
		n => tb_n,
		carry_out => tb_carry_out
	);
	-- ================================================
	tb_carry_in <= '0';
	-- ================================================

	stimproc : process
	begin
		tb_a <= x"0BCD";
		tb_b <= x"1000";
		tb_n <= x"4000";
		wait for 10 ns;
		tb_a <= x"ABCD";
		tb_b <= x"ABCE";
		tb_n <= x"4000";
		wait for 10 ns;
		wait;
	end process;
end rtl;
