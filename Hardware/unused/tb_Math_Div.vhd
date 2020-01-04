-- Component: tb_Math_Div
-- Desc: Testbench for Math_Div
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Div is
end tb_Math_Div;

architecture rtl of tb_Math_Div is
	component Math_Div is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		r : out std_logic_vector(nbits-1 downto 0);
		q : out std_logic_vector(nbits-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		div_error : out std_logic
	);
	end component;
	signal div_a : std_logic_vector(15 downto 0);
	signal div_b : std_logic_vector(15 downto 0);
	signal div_r : std_logic_vector(15 downto 0);
	signal div_q : std_logic_vector(15 downto 0);
	signal div_start : std_logic;
	signal div_clk : std_logic;
	signal div_done : std_logic;
	signal div_err : std_logic;
begin
	uut : Math_Div generic map (nbits => 16)
	port map (
		a => div_a,
		b => div_b,
		r => div_r,
		q => div_q,
		start => div_start,
		clk => div_clk,
		done => div_done,
		div_error => div_err
	);

	clkproc : process
	begin
		div_clk <= '0';
		wait for 10 ns;
		div_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		div_start <= '0';
		div_a <= x"0000";
		div_b <= x"0100";
		wait for 15 ns;
		div_start <= '1';
		wait for 20 ns;
		wait until div_done = '1';
		div_start <= '0';
		wait for 20 ns;
		div_a <= x"7777";
		div_b <= x"0000";
		wait for 20 ns;
		div_start <= '1';
		wait for 20 ns;
		wait until div_done = '1';
		div_start <= '0';
		wait for 20 ns;
		div_a <= x"0077";
		div_b <= x"000F";
		wait for 20 ns;
		div_start <= '1';
		wait for 20 ns;
		wait until div_done = '1';
		div_start <= '0';
		wait for 20 ns;
		div_a <= x"2477";
		div_b <= x"010F";
		wait for 20 ns;
		div_start <= '1';
		wait for 20 ns;
		wait until div_done = '1';
		div_start <= '0';
		wait for 20 ns;
		wait for 20 ns;
		wait;
	end process;
end rtl;
