-- Component: tb_Counter
-- Desc: testbench for Counter
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Counter is
end tb_Counter;

architecture rtl of tb_Counter is
	component Counter is
	generic (
		nbits : integer := 16;
		increment : integer := -1
	);
	port (
		pr_value : in std_logic_vector(nbits-1 downto 0);
		value : out std_logic_vector(nbits-1 downto 0);
		clk : in std_logic;
		rst : in std_logic
	);
	end component;
	signal tb_pr_value : std_logic_vector(15 downto 0);
	signal tb_value1 : std_logic_vector(15 downto 0);
	signal tb_value2 : std_logic_vector(15 downto 0);
	signal tb_enable : std_logic;
	signal tb_async_reset : std_logic;
	signal tb_clk : std_logic;
begin
	uut1 : Counter generic map (nbits => 16, increment => 1)
	port map (
		pr_value => tb_pr_value,
		value => tb_value1,
		clk => tb_clk,
		rst => tb_async_reset
	);
	uut2 : Counter generic map (nbits => 16, increment => -2)
	port map (
		pr_value => tb_pr_value,
		value => tb_value2,
		clk => tb_clk,
		rst => tb_async_reset
	);

	clkproc : process
	begin
		tb_clk <= '0';
		wait for 10 ns;
		tb_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		tb_pr_value <= x"0080";
		tb_enable <= '0';
		tb_async_reset <= '1';
		wait for 5 ns;
		tb_async_reset <= '0';
		wait for 20 ns;
		tb_enable <= '1';
		wait for 100 ns;
		wait;
	end process;
end rtl;
