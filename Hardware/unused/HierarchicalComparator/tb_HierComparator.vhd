-- Component: tb_HierComparator
-- Desc: Testbench for HierComparator
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_HierComparator is
end tb_HierComparator;

architecture rtl of tb_HierComparator is
	component HierComparator is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		gt : out std_logic;
		eq : out std_logic
	);
	end component;
	signal cmp_a : std_logic_vector(15 downto 0);
	signal cmp_b : std_logic_vector(15 downto 0);
	signal result_gt : std_logic;
	signal result_eq : std_logic;
begin
	h : HierComparator generic map (nbits => 16)
	port map (
		a => cmp_a,
		b => cmp_b,
		gt => result_gt,
		eq => result_eq
	);

	stim_proc : process 
	begin
		cmp_a <= x"ABCD";
		cmp_b <= x"DEFF"; -- 0 0
		wait for 10 ns;
		cmp_b <= x"0BCD"; -- 1 0
		wait for 10 ns;
		cmp_b <= x"ABCD";
		wait;
	end process;

end rtl;
