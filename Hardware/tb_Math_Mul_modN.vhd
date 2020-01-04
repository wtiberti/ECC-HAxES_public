-- Component: tb_Math_Mul_modN
-- Desc: testbench for Math_Mul_modN
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Mul_modN is
end tb_Math_Mul_modN;

architecture rtl of tb_Math_Mul_modN is
	component Math_Mul_modN is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		product : out std_logic_vector(nbits-1 downto 0);
		done : out std_logic;
		moderror : out std_logic
	);
	end component;
	signal mul_a : std_logic_vector(31 downto 0);
	signal mul_b : std_logic_vector(31 downto 0);
	signal mul_n : std_logic_vector(31 downto 0);
	signal mul_start : std_logic;
	signal clk : std_logic;
	signal mul_product : std_logic_vector(31 downto 0);
	signal mul_done : std_logic;
	signal mul_moderror : std_logic;
begin
	uut : Math_Mul_modN generic map (nbits => 32)
	port map (
		a => mul_a,
		b => mul_b,
		n => mul_n,
		start => mul_start,
		clk => clk,
		product => mul_product,
		done => mul_done,
		moderror => mul_moderror
	);

	clockproc : process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		mul_start <= '0';
		mul_a <= x"11223344";
		mul_b <= x"55667788";
		mul_n <= x"1F2F3F4F";
		wait for 30 ns;
		mul_start <= '1';
		wait until mul_done = '1';
		wait for 10 ns;
		mul_start <= '0';
		wait for 50 ns;
		wait;
	end process;
end rtl;
