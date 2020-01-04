-- Component: tb_FullSubtractor
-- Desc: Testbed for the FullSubtractor component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_FullSubtractor is
end tb_FullSubtractor;

architecture sim of tb_FullSubtractor is
	component FullSubtractor is
	port (
		A : in std_logic;
		B : in std_logic;
		Borrow_in : in std_logic;
		Diff : out std_logic;
		Borrow_out : out std_logic
	);
	end component;

	signal op1 : std_logic;
	signal op2 : std_logic;
	signal s : std_logic;
	signal bi : std_logic;
	signal b : std_logic;
	signal sim_clk : std_logic;
begin
	uut : FullSubtractor
	port map (
		A => op1,
		B => op2,
		Borrow_in => bi,
		Diff => s,
		Borrow_out => b
	);

	clock_stim : process
	begin
		sim_clk <= '0';
		wait for 1 ns;
		sim_clk <= '1';
		wait for 1 ns;
	end process;

	stim : process
	begin
		bi <= '0';
		op1 <= '0';
		op2 <= '0';
		wait for 1 ns;

		op1 <= '1';
		op2 <= '0';
		wait for 1 ns;

		op1 <= '1';
		op2 <= '1';
		wait for 1 ns;

		op1 <= '0';
		op2 <= '1';
		wait for 1 ns;

		bi <= '1';
		op1 <= '0';
		op2 <= '0';
		wait for 1 ns;

		op1 <= '1';
		op2 <= '0';
		wait for 1 ns;

		op1 <= '1';
		op2 <= '1';
		wait for 1 ns;

		op1 <= '0';
		op2 <= '1';
		wait for 1 ns;

		wait;
	end process;
end sim;
