-- Component: tb_Math_Invert_modN_RS
-- Desc: testbench for Math_Invert_modN_RS
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Invert_modN_RS is
end tb_Math_Invert_modN_RS;

architecture rtl of tb_Math_Invert_modN_RS is
	component Math_Invert_modN_RS is
	generic (
		nbits : integer := 192
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		p : in std_logic_vector(nbits-1 downto 0);
		result : out std_logic_vector(nbits-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		err : out std_logic
	);
	end component;
	signal inv_a : std_logic_vector(191 downto 0);
	signal inv_p : std_logic_vector(191 downto 0);
	signal inv_result : std_logic_vector(191 downto 0);
	signal inv_start : std_logic;
	signal inv_clk : std_logic;
	signal inv_done : std_logic;
	signal inv_err : std_logic;
begin
	uut : Math_Invert_modN_RS generic map (nbits => 192) port map (inv_a, inv_p, inv_result, inv_start, inv_clk, inv_done, inv_err);
	clkproc : process
	begin
		inv_clk <= '0';
		wait for 10 ns;
		inv_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		inv_p <= x"fffffffffffffffffffffffffffffffffffffffeffffee37";
		inv_a <= x"365e5edb38ac514f0882c7a02b7d0c6881055512b2bc7103";
		inv_start <= '0';
		wait for 5 ns;
		inv_start <= '1';
		wait until inv_done = '1';
		wait for 1 ns;
		inv_start <= '0';
		wait;
	end process;
end rtl;
