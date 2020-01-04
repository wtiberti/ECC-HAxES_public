-- Component: tb_ECC_PointDouble
-- Desc: testbench for ECC_PointDouble
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_ECC_PointDouble is
end tb_ECC_PointDouble;

architecture rtl of tb_ECC_PointDouble is
	component ECC_PointDouble is
	generic (
		nbits : integer := 128
	);
	port (
		P : in std_logic_vector((2*nbits)-1 downto 0);
		a : in std_logic_vector(nbits-1 downto 0);
		mod_p : in std_logic_vector(nbits-1 downto 0);
		R : out std_logic_vector((2*nbits)-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		inf : out std_logic;
		double_error : out std_logic
	);
	end component;
	signal pd_P : std_logic_vector((2*192)-1 downto 0);
	signal pd_a : std_logic_vector(192-1 downto 0);
	signal pd_mod_p : std_logic_vector(192-1 downto 0);
	signal pd_R : std_logic_vector((2*192)-1 downto 0);
	signal pd_start : std_logic;
	signal pd_clk : std_logic;
	signal pd_done :std_logic;
	signal pd_inf : std_logic;
	signal pd_double_error : std_logic;
begin
	uut : ECC_PointDouble generic map (nbits => 192)
	port map (
		P => pd_P,
		a => pd_a,
		mod_p => pd_mod_p,
		R => pd_R,
		start => pd_start,
		clk => pd_clk,
		done => pd_done,
		inf => pd_inf,
		double_error => pd_double_error
	);

	clkproc : process
	begin
		pd_clk <= '0';
		wait for 10 ns;
		pd_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		pd_start <= '0';
		pd_P(2*192-1 downto 192) <= x"db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d";
		pd_P(192-1 downto 0) <=     x"9b2f2f6d9c5628a7844163d015be86344082aa88d95e2f9d";
		pd_a <= (others => '0');
		pd_mod_p <= x"fffffffffffffffffffffffffffffffffffffffeffffee37";
		wait for 30 ns;
		pd_start <= '1';
		wait until pd_done = '1';
		wait for 30 ns;
		pd_start <= '0';
		wait;
	end process;
end rtl;
