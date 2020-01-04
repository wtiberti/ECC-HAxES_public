-- Component: tb_ECC_PointAdder
-- Desc: testbench for ECC_PointAdder
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_ECC_PointAdder is
end tb_ECC_PointAdder;

architecture rtl of tb_ECC_PointAdder is
	component ECC_PointAdder is
	generic (
		nbits : integer := 128
	);
	port (
		P : in std_logic_vector((2*nbits)-1 downto 0);
		Q : in std_logic_vector((2*nbits)-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		R : out std_logic_vector((2*nbits)-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		add_error : out std_logic;
		inf : out std_logic
	);
	end component;
	signal t_P : std_logic_vector(383 downto 0);
	signal t_Q : std_logic_vector(383 downto 0);
	signal t_n : std_logic_vector(191 downto 0);
	signal t_R : std_logic_vector(383 downto 0);
	signal t_start : std_logic;
	signal t_clk : std_logic;
	signal t_done : std_logic;
	signal t_ae : std_logic;
	signal t_inf : std_logic;
begin
	uut : ECC_PointAdder generic map (nbits => 192)
	port map (
		P => t_P,
		Q => t_Q,
		n => t_n,
		R => t_R,
		start => t_start,
		clk => t_clk,
		done => t_done,
		add_error => t_ae,
		inf => t_inf
	);

	clockproc : process
	begin
		t_clk <= '0';
		wait for 10 ns;
		t_clk <= '1';
		wait for 10 ns;
	end process;

	-- Test vector : 
	stimproc : process
	begin
		t_start <= '0';
		t_n <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFEE37";
		t_P <= x"DB4FF10EC057E9AE26B07D0280B7F4341DA5D1B1EAE06C7D9B2F2F6D9C5628A7844163D015BE86344082AA88D95E2F9D";
		t_Q <= (others => '0');
		t_start <= '1';
		wait until t_done = '1';
		t_start <= '0';
		wait for 20 ns;
		t_Q <= x"DB4FF10EC057E9AE26B07D0280B7F4341DA5D1B1EAE06C7D9B2F2F6D9C5628A7844163D015BE86344082AA88D95E2F9D";
		t_start <= '1';
		wait until t_done = '1';
		wait;
	end process;
end rtl;
