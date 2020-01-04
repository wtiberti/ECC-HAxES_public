-- Component: tb_Math_Invert_modN
-- Desc: testbench for Math_Invert_modN
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Invert_modN is
end tb_Math_Invert_modN;

architecture rtl of tb_Math_Invert_modN is
	component Math_Invert_modN is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		inv_a : out std_logic_vector(nbits-1 downto 0);
		clk : in std_logic;
		start : in std_logic;
		done : out std_logic;
		inv_err : out std_logic
	);
	end component;

	signal i_a : std_logic_vector(191 downto 0);
	signal i_n : std_logic_vector(191 downto 0);
	signal i_result : std_logic_vector(191 downto 0);
	signal i_clk : std_logic;
	signal i_start : std_logic;
	signal i_done : std_logic;
	signal i_err : std_logic;
begin
	uut : Math_Invert_modN generic map (nbits => 192)
	port map (
		a => i_a,
		n => i_n,
		inv_a => i_result,
		clk => i_clk,
		start => i_start,
		done => i_done,
		inv_err => i_err
	);

	clockproc: process
	begin
		i_clk <= '0';
		wait for 10 ns;
		i_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		i_start <= '0';
		i_a <= x"365e5edb38ac514f0882c7a02b7d0c6881055512b2bc7103";
		i_n <= x"fffffffffffffffffffffffffffffffffffffffeffffee37";
		wait for 10 ns; -- = -11 = 116 = 0x74
		i_start <= '1';
		wait until i_done = '1';
		i_start <= '0';
		wait for 30 ns;
		wait;
	end process;
end rtl;
