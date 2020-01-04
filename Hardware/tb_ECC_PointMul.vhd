-- Component: tb_ECC_PointMul
-- Desc: testbench for ECC_PointMul
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_ECC_PointMul is
end tb_ECC_PointMul;

architecture rtl of tb_ECC_PointMul is
	component ECC_PointMul is
	generic (
		nbits : integer := 128
	);
	port (
		Point : in std_logic_vector((2*nbits)-1 downto 0);
		k : in std_logic_vector(nbits-1 downto 0);
		Result : out std_logic_vector((2*nbits)-1 downto 0);
		p : in std_logic_vector(nbits-1 downto 0);
		a : in std_logic_vector(nbits-1 downto 0);
		clk : in std_logic;
		start : in std_logic;
		done : out std_logic;
		inf : out std_logic
	);
	end component;
	signal PM_Point : std_logic_vector((2*192)-1 downto 0);
	signal PM_k : std_logic_vector(192-1 downto 0);
	signal PM_Result : std_logic_vector((2*192)-1 downto 0);
	signal PM_p : std_logic_vector(192-1 downto 0);
	signal PM_a : std_logic_vector(192-1 downto 0);
	signal PM_clk : std_logic;
	signal PM_start : std_logic;
	signal PM_done : std_logic;
	signal PM_inf : std_logic;
begin
	uut : ECC_PointMul generic map (nbits => 192)
	port map (
		Point => PM_Point,
		k => PM_k,
		Result => PM_Result,
		p => PM_p,
		a => PM_a,
		clk => PM_clk,
		start => PM_start,
		done => PM_done,
		inf => PM_inf
	);

	clockproc : process
	begin
		PM_clk <= '0';
		wait for 10 ns;
		PM_clk <= '1';
		wait for 10 ns;
	end process;

	stimproc : process
	begin
		PM_start <= '0';
		PM_a <= (others => '0');
		PM_p <= x"fffffffffffffffffffffffffffffffffffffffeffffee37";
		PM_Point(2*192-1 downto 192) <= x"db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d";
		PM_Point(192-1 downto 0) <=     x"9b2f2f6d9c5628a7844163d015be86344082aa88d95e2f9d";
		--

		-- PM_k <= x"000000000000000000000000000000000000000000000003"; -- G*3
		-- Expected result:
		-- x:0x6e43b7dcae2fd5e0bf2a1ba7615ca3b9065487c9a67b4583	
		-- y:0xc48dcea47ae08e84d5fedc3d09e4c19606a290f7a19a6a58

		PM_k <= x"00000000000000000000000000000000000000000000000D"; -- G*13
		-- Expected result:
		-- x:0xafc6c0d8c291f69576f5e67f3c8ada23252e5fb8a287ffcb
		-- y:0x772f7a0e23bb6a18f5ab6de6390710b844b04145c84e41cc

		--PM_k <= x"0102030405060708090a0b0c0d0e0f101112131415161718";
		-- Expected result:
		-- x:0x4f66169b52c55aaef02abf5d5ab1be9228fb139fe7449b2f	
		-- y:0xb48c15a085346510aaafaf7704dc6a2d077cc25ffeb30008

		wait for 30 ns;
		PM_start <= '1';
		wait until PM_done = '1';
		report "kG: k = 0x" & to_hstring(PM_k);
		report "kG: Result.x = 0x" & to_hstring(PM_Result((2*192)-1 downto 192));
		report "kG: Result.y = 0x" & to_hstring(PM_Result(191 downto 0));
		wait for 5 ns;
		PM_start <= '0';
		wait for 5 ns;
		wait;
	end process;
end rtl;
