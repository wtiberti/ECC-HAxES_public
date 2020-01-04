-- Component: tb_Math_Mod
-- Desc: Testbed for the Math_Mod component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Mod is
end tb_Math_Mod;

architecture rtl of tb_Math_Mod is
	component Math_Mod is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		p : in std_logic_vector(nbits-1 downto 0);
		r : out std_logic_vector(nbits-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		div_error : out std_logic
	);
	end component;
	signal mod_a : std_logic_vector(191 downto 0);
	signal mod_p : std_logic_vector(191 downto 0);
	signal mod_r : std_logic_vector(191 downto 0);
	signal mod_start : std_logic;
	signal mod_done : std_logic;
	signal mod_diverr : std_logic;
	signal sim_clk : std_logic;

	constant testdata_size : integer := 2;
	type TestData_t is array(0 to testdata_size-1) of
			std_logic_vector(191 downto 0);
	constant test_data : TestData_t := (
	x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFEE37",
	x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFEE37"
	);
begin
	uut : Math_Mod generic map (nbits => 192)
	port map (
		a => mod_a,
		p => mod_p,
		r => mod_r,
		start => mod_start,
		done => mod_done,
		div_error => mod_diverr,
		clk => sim_clk
	);

	clk_proc : process
	begin
		sim_clk <= '0';
		wait for 1 ns;
		sim_clk <= '1';
		wait for 1 ns;
	end process;

	mod_p <= x"FFFFFFFFFFFFFFFFFFFFFFFE26F2FC170F69466A74DEFD8D";
	stim_proc : process
	begin
		for i in 0 to testdata_size-1 loop
			mod_a <= test_data(i);
			wait for 1 ns;
			mod_start <= '1';
			wait for 2 ns;
			mod_start <= '0';
			wait until mod_done = '1';
			wait for 5 ns;
		end loop;
		--wait;
	end process;
end rtl;
