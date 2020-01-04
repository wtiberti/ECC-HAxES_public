-- Component: tb_Reg_PIPO
-- Desc: Testbed for the Reg_PIPO component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Reg_PIPO is
end tb_Reg_PIPO;

architecture sim of tb_Reg_PIPO is
	component Reg_PIPO is
	generic (
		nbits : integer := 16
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		clk : in std_logic;
		rst : in std_logic;
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;

	signal reg_in : std_logic_vector(7 downto 0);
	signal reg_out : std_logic_vector(7 downto 0);
	signal sim_clk : std_logic;
begin
	uut : Reg_PIPO generic map (
		nbits => 8
	) port map (
		input => reg_in,
		output => reg_out,
		rst => '0',
		clk => sim_clk
	);

	clock_stim : process
	begin
		sim_clk <= '0';
		wait for 10 ns;
		sim_clk <= '1';
		wait for 10 ns;
	end process;

	stim : process
	begin
		reg_in <= x"AA";
		wait for 30 ns;
		reg_in <= x"11";
		wait for 15 ns;
		reg_in <= x"FF";
		wait;
	end process;
end sim;
