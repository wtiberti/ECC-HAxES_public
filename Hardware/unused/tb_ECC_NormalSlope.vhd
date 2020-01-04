-- Component: tb_ECC_NormalSlope
-- Desc: testbench for ECC_NormalSlope
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_ECC_NormalSlope is
end tb_ECC_NormalSlope;

architecture rtl of tb_ECC_NormalSlope is
	component ECC_NormalSlope is
	generic (
		nbits : integer := 128
	);
	port (
		P : in std_logic_vector((2*nbits)-1 downto 0);
		Q : in std_logic_vector((2*nbits)-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		slope : out std_logic_vector(nbits-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		inf : out std_logic;
		moderror : out std_logic
	);
	end component;
	signal slope_P : std_logic_vector(15 downto 0);
	signal slope_Q : std_logic_vector(15 downto 0);
	signal slope_n : std_logic_vector(7 downto 0);
	signal slope_slope : std_logic_vector(7 downto 0);
	signal slope_start : std_logic;
	signal slope_clk : std_logic;
	signal slope_done : std_logic;
	signal slope_inf : std_logic;
	signal slope_moderror : std_logic;
begin
	uut : ECC_NormalSlope generic map (nbits => 8)
	port map (
		P => slope_P,
		Q => slope_Q,
		n => slope_n,
		slope => slope_slope,
		start => slope_start,
		clk => slope_clk,
		done => slope_done,
		inf => slope_inf,
		moderror => slope_moderror
	);

	clockproc : process
	begin
		slope_clk <= '0';
		wait for 10 ns;
		slope_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		slope_P <= x"0606"; -- (6,6)
		slope_Q <= x"0303"; -- (3,3)
		slope_n <= x"0B"; -- mod 11
		slope_start <= '0';
		wait for 30 ns;
		slope_start <= '1';
		wait until slope_done = '1'; -- = 3^-1 = 4, 4 * 3 = 12 = 1
		wait for 10 ns;
		slope_start <= '0';
		wait for 20 ns;
		wait for 20 ns;
		slope_P <= x"0606"; -- (6,6)
		slope_Q <= x"0303"; -- (3,3)
		slope_n <= x"47"; -- mod 71
		slope_start <= '0';
		wait for 30 ns;
		slope_start <= '1';
		wait until slope_done = '1'; -- = 12
		wait for 10 ns;
		slope_start <= '0';
		wait for 20 ns;
	end process;
end rtl;
