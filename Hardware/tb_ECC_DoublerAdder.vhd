-- Component: tb_ECC_DoublerAdder
-- Desc: testbench for ECC_DoublerAdder
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_ECC_DoublerAdder is
end tb_ECC_DoublerAdder;

architecture rtl of tb_ECC_DoublerAdder is
	component ECC_DoublerAdder is
	generic (
		nbits : integer := 128
	);
	port (
		P : in std_logic_vector((2*nbits)-1 downto 0);
		Q : in std_logic_vector((2*nbits)-1 downto 0);
		mod_p : in std_logic_vector(nbits-1 downto 0);
		a : in std_logic_vector(nbits-1 downto 0);
		R : out std_logic_vector((2*nbits)-1 downto 0);
		op : in std_logic;
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		err : out std_logic;
		inf : out std_logic
	);
	end component;
	signal uut_P : std_logic_vector((2*192)-1 downto 0);
	signal uut_Q : std_logic_vector((2*192)-1 downto 0);
	signal uut_mod_p : std_logic_vector(192-1 downto 0);
	signal uut_a : std_logic_vector(192-1 downto 0);
	signal uut_R : std_logic_vector((2*192)-1 downto 0);
	signal uut_op : std_logic;
	signal uut_start : std_logic;
	signal uut_clk : std_logic;
	signal uut_done : std_logic;
	signal uut_done_error : std_logic;
	signal uut_done_inf : std_logic;
begin
	uut : ECC_DoublerAdder generic map (nbits => 192)
	port map (
		P => uut_P,
		Q => uut_Q,
		mod_p => uut_mod_p,
		a => uut_a,
		R => uut_R,
		op => uut_op,
		start => uut_start,
		clk => uut_clk,
		done => uut_done,
		err => uut_done_error,
		inf => uut_done_inf
	);

	clkproc : process
	begin
		uut_clk <= '0';
		wait for 10 ns;
		uut_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		uut_start <= '0';
		-- input data:
		-- prime
		uut_mod_p <= x"fffffffffffffffffffffffffffffffffffffffeffffee37";
		-- curve.a
		uut_a <= x"000000000000000000000000000000000000000000000000";
		-- P = Curve.G
		uut_P((2*192)-1 downto 192) <= x"db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d";
		uut_P(192-1 downto 0) <= x"9b2f2f6d9c5628a7844163d015be86344082aa88d95e2f9d";
		-- Q = P = Curve.G
		uut_Q((2*192)-1 downto 192) <= x"db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d";
		uut_Q(192-1 downto 0) <= x"9b2f2f6d9c5628a7844163d015be86344082aa88d95e2f9d";

		-- start
		wait for 30 ns;
		uut_op <= '1'; -- double G
		wait for 30 ns;
		uut_start <= '1';
		wait until uut_done = '1';
		wait for 30 ns;
		uut_start <= '0';
		uut_Q((2*192)-1 downto 192) <= x"f091cf6331b1747684f5d2549cd1d4b3a8bed93b94f93cb6";
		uut_Q(192-1 downto 0) <= x"fd7af42e1e7565a02e6268661c5e42e603da2d98a18f2ed5";
		uut_op <= '0'; -- compute 2G+G
		wait for 30 ns;
		uut_start <= '1';
		wait until uut_done = '1';
		wait;
	end process;
end rtl;
