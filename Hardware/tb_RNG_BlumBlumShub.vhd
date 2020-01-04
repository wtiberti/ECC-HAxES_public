-- Component: tb_RNG_BlumBlumShub
-- Desc: testbench for RNG_BlumBlumShub
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_RNG_BlumBlumShub is
end tb_RNG_BlumBlumShub;

architecture rtl of tb_RNG_BlumBlumShub is
	component RNG_BlumBlumShub is
	generic (
		nbits : integer := 192
	);
	port (
		seed : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		new_run : in std_logic;
		clk : in std_logic;
		start : in std_logic;
		done : out std_logic;
		moderror : out std_logic;
		result : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal bbs_seed : std_logic_vector(15 downto 0);
	signal bbs_n : std_logic_vector(15 downto 0);
	signal bbs_new_run : std_logic;
	signal bbs_clk : std_logic;
	signal bbs_start : std_logic;
	signal bbs_done : std_logic;
	signal bbs_moderror : std_logic;
	signal bbs_result : std_logic_vector(15 downto 0);
begin
	uut : RNG_BlumBlumShub generic map (nbits => 16)
	port map (
		seed => bbs_seed,
		n => bbs_n,
		new_run => bbs_new_run,
		clk => bbs_clk,
		start => bbs_start,
		done => bbs_done,
		moderror => bbs_moderror,
		result => bbs_result
	);

	clkproc : process
	begin
		bbs_clk <= '0';
		wait for 10 ns;
		bbs_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		-- wikipedia example
		bbs_seed <= x"0003";
		bbs_n <= x"00D1"; -- = 11 * 19 = 209
		bbs_new_run <= '1';
		bbs_start <= '0';
		wait for 5 ns;
		bbs_start <= '1';
		wait until bbs_done = '1';
		wait for 5 ns;
		bbs_start <= '0';
		bbs_new_run <= '0';
		for i in 0 to 10 loop
			wait for 20 ns;
			bbs_start <= '1';
			wait until bbs_done = '1';
			wait for 20 ns;
			bbs_start <= '0';
		end loop;
		wait;
	end process;
end rtl;
