-- Component: tb_ECC_DoubleSlope
-- Desc: testbench for ECC_DoubleSlope
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;
-- use std.textio.all;
-- use ieee.std_logic_textio.all;

entity tb_ECC_DoubleSlope is
end tb_ECC_DoubleSlope;

architecture rtl of tb_ECC_DoubleSlope is
	component ECC_DoubleSlope is
	generic (
		nbits : integer := 128
	);
	port (
		P : in std_logic_vector((2*nbits)-1 downto 0);
		a : in std_logic_vector(nbits-1 downto 0);
		mod_p : in std_logic_vector(nbits-1 downto 0);
		slope : out std_logic_vector(nbits-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		inf : out std_logic;
		moderror : out std_logic
	);
	end component;

	signal ds_P : std_logic_vector((2*192)-1 downto 0);
	signal ds_a : std_logic_vector(192-1 downto 0);
	signal ds_n : std_logic_vector(192-1 downto 0);
	signal ds_slope : std_logic_vector(192-1 downto 0);
	signal ds_start : std_logic;
	signal ds_clk : std_logic;
	signal ds_done : std_logic;
	signal ds_inf : std_logic;
	signal ds_moderror : std_logic;
begin
	uut: ECC_DoubleSlope generic map (nbits => 192)
	port map (
		P => ds_P,
		a => ds_a,
		mod_p => ds_n,
		slope => ds_slope,
		start => ds_start,
		clk => ds_clk,
		done => ds_done,
		inf => ds_inf,
		moderror => ds_moderror
	);

	clkoproc : process
	begin
		ds_clk <= '0';
		wait for 10 ns;
		ds_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		ds_P(383 downto 192) <= x"DB4FF10EC057E9AE26B07D0280B7F4341DA5D1B1EAE06C7D";
		ds_P(192-1 downto 0) <= x"9B2F2F6D9C5628A7844163D015BE86344082AA88D95E2F9D";
		ds_a <= x"000000000000000000000000000000000000000000000000";
		ds_n <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFEE37";
		ds_start <= '0';
		wait for 20 ns;
		ds_start <= '1';
		wait until ds_done = '1';
		wait for 5 ns;
		ds_start <= '0';
		wait;
	end process;
end rtl;
