-- Component: tb_CombComparator
-- Desc: testbench for CombComparator
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_CombComparator is
end tb_CombComparator;

architecture rtl of tb_CombComparator is
	component CombComparator is
	generic (
		nbits : integer := 32
	);
	port (
		op1 : in std_logic_vector(nbits-1 downto 0);
		op2 : in std_logic_vector(nbits-1 downto 0);
		gt : out std_logic;
		eq : out std_logic;
		lt : out std_logic
	);
	end component;
	signal uut_op1 : std_logic_vector(31 downto 0);
	signal uut_op2 : std_logic_vector(31 downto 0);
	signal uut_gt : std_logic;
	signal uut_eq : std_logic;
	signal uut_lt : std_logic;
begin
	cmp : CombComparator generic map (nbits => 32) port map (uut_op1, uut_op2, uut_gt, uut_eq, uut_lt);
	stimproc: process
	begin
		uut_op1 <= x"00123456";
		uut_op2 <= x"00567890";
		wait for 10 ns; -- lt
		uut_op2 <= x"00012121";
		wait for 10 ns; -- gt
		uut_op2 <= x"00123456";
		wait for 10 ns; -- eq
		wait;
	end process;
end rtl;
