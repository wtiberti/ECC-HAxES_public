-- Component: tb_Cmp_BodyLine
-- Desc: Testbench for Cmp_BodyLine
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity tb_Cmp_BodyLine is
end tb_Cmp_BodyLine;

architecture rtl of tb_Cmp_BodyLine is
	component Cmp_BodyLine is
	generic (
		level : natural := 1
	);
	port (
		in_gt : in std_logic_vector(2**level-1 downto 0);
		in_eq : in std_logic_vector(2**level-1 downto 0);
		out_gt : out std_logic_vector(2**(level-1)-1 downto 0);
		out_eq : out std_logic_vector(2**(level-1)-1 downto 0)
	);
	end component;
	signal ingt : std_logic_vector(7 downto 0);
	signal ineq : std_logic_vector(7 downto 0);
	signal outgt : std_logic_vector(3 downto 0);
	signal outeq : std_logic_vector(3 downto 0);
begin
	bline : Cmp_BodyLine generic map (level => 3)
	port map (
		in_gt => ingt,
		in_eq => ineq,
		out_gt => outgt,
		out_eq => outeq
	);

	stim_proc : process 
	begin
		ingt <= "11100100";
		ineq <= "00001000";
		wait for 10 ns;
		ineq <= "00011011";
		wait for 10 ns;
		ingt <= "00100100";
		wait;
	end process;

end rtl;
