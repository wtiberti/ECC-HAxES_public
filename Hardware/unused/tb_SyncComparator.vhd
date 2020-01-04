-- Component: tb_SyncComparator
-- Desc: Testbed for the SyncComparator component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_SyncComparator is
end tb_SyncComparator;

architecture rtl of tb_SyncComparator is
	component SyncComparator is
	generic (
		nbits : integer := 16
	);
	port (
		op1 : in std_logic_vector(nbits-1 downto 0);
		op2 : in std_logic_vector(nbits-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		greater_than : out std_logic;
		done : out std_logic
	);
	end component;

	signal v1 : std_logic_vector(15 downto 0);
	signal v2 : std_logic_vector(15 downto 0);
	signal comp_start : std_logic;
	signal comp_gt : std_logic;
	signal comp_done : std_logic;
	signal sim_clk : std_logic;
begin
	uut : SyncComparator
	generic map (
		nbits => 16
	)
	port map (
		op1 => v1,
		op2 => v2,
		start => comp_start,
		clk => sim_clk,
		greater_than => comp_gt,
		done => comp_done
	);

	clk_proc : process
	begin
		sim_clk <= '0';
		wait for 1 ns;
		sim_clk <= '1';
		wait for 1 ns;
	end process;

	stim_proc : process
	begin
		comp_start <= '0';

		v1 <= x"1234";
		v2 <= x"1235";
		wait for 2 ns;
		
		comp_start <= '1';
		wait for 4 ns;
		comp_start <= '0';
		wait until comp_done = '1';

		wait for 4 ns;

		v1 <= x"1244";
		v2 <= x"1235";
		wait for 2 ns;
		
		comp_start <= '1';
		wait for 4 ns;
		comp_start <= '0';
		wait;
	end process;
end rtl;
