-- Component: tb_Math_AddSub_modN
-- Desc: testbench for Math_AddSub_modN
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_AddSub_modN is
end tb_Math_AddSub_modN;

architecture rtl of tb_Math_AddSub_modN is
	component Math_AddSub_modN is
	generic (
		nbits : integer := 16
	);
	port (
		cbi : in std_logic;
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		op : in std_logic; -- 0 = add, 1 = sub
		start : in std_logic;
		clk : in std_logic;
		result : out std_logic_vector(nbits-1 downto 0);
		done : out std_logic
	);
	end component;
	signal uut_cbi : std_logic;
	signal uut_a : std_logic_vector(191 downto 0);
	signal uut_b : std_logic_vector(191 downto 0);
	signal uut_n : std_logic_vector(191 downto 0);
	signal uut_op : std_logic; -- 0 = add, 1 = sub
	signal uut_start : std_logic;
	signal uut_clk : std_logic;
	signal uut_result : std_logic_vector(191 downto 0);
	signal uut_done : std_logic;
begin
	uut : Math_AddSub_modN generic map (nbits => 192)
	port map (
		cbi => uut_cbi,
		a => uut_a,
		b => uut_b,
		n => uut_n,
		op => uut_op,
		start => uut_start,
		clk => uut_clk,
		result => uut_result,
		done => uut_done
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
		uut_cbi <= '0';
		uut_start <= '0';
		uut_n <= x"fffffffffffffffffffffffffffffffffffffffeffffee37";

		-- case 1: A + B < P
		uut_op <= '0';
		uut_a <= x"db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d";
		uut_b <= x"111111111111111111111111111111111111111111111111";
		-- expected: 0xec61021fd168fabf37c18e1391c905452eb6e2c2fbf17d8e
		wait for 20 ns; uut_start <= '1'; wait until uut_done = '1'; wait for 20 ns; uut_start <= '0';

		-- case 2: A + B > P
		uut_op <= '0';
		uut_a <= x"db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d";
		uut_b <= x"eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
		-- expected: 0xca3edffdaf46d89d159f6bf16fa6e3230c94c0a1d9cf6d34
		wait for 20 ns; uut_start <= '1'; wait until uut_done = '1'; wait for 20 ns; uut_start <= '0';

		-- case 3: A - B > 0
		uut_op <= '1';
		uut_a <= x"eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
		uut_b <= x"db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d";
		-- expected: 0x139efde02e970540c83e71ec6e36fabad1491d3d040e8271
		wait for 20 ns; uut_start <= '1'; wait until uut_done = '1'; wait for 1 ns; uut_start <= '0';

		-- case 4: A - B < 0
		uut_op <= '1';
		uut_a <= x"db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d";
		uut_b <= x"eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
		-- expected: 0xec61021fd168fabf37c18e1391c905452eb6e2c1fbf16bc6
		wait for 20 ns; uut_start <= '1'; wait until uut_done = '1'; wait for 1 ns; uut_start <= '0';
		wait;
	end process;
end rtl;
