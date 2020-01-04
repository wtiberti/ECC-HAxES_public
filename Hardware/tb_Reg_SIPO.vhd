-- Component: tb_Reg_SIPO
-- Desc: testbench for Reg_SIPO
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Reg_SIPO is
end tb_Reg_SIPO;

architecture rtl of tb_Reg_SIPO is
	component Reg_SIPO is
	generic (
		nbits : integer := 16
	);
	port (
		input : in std_logic;
		clk : in std_logic;
		rst : in std_logic;
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal reg_in : std_logic;
	signal sim_clk : std_logic;
	signal reg_rst : std_logic;
	signal reg_out : std_logic_vector(7 downto 0);
begin
	uut : Reg_SIPO generic map (nbits => 8) port map (reg_in, sim_clk, reg_rst, reg_out);

	clock_stim : process
	begin
		sim_clk <= '0';
		wait for 10 ns;
		sim_clk <= '1';
		wait for 10 ns;
	end process;

	stim : process
	begin
		reg_in <= '0';

		reg_rst <= '1';
		wait for 30 ns;
		reg_rst <= '0';

		reg_in <= '1';
		wait for 60 ns;

		reg_in <= '0';
		wait for 60 ns;
		wait;
	end process;
end rtl;
