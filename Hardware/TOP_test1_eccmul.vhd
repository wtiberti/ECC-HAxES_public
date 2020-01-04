-- Component: TOP_test1_eccmul
-- Desc: A top-level for testing (i.e implementation/portmap/etc) ECC_PointMul
--	on FPGA board
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity TOP_test1_eccmul is
port (
	data : in std_logic;
	data_clk : in std_logic;
	data_sel : std_logic_vector(1 downto 0); -- 2 bit => Point, k, p, a
	result : out std_logic;
	result_mode : in std_logic;
	result_clk : out std_logic;
	start : in std_logic;
	clk : in std_logic;
	done : out std_logic;
	inf : out std_logic
);
end TOP_test1_eccmul;

architecture rtl of TOP_test1_eccmul is
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

	component Reg_PIxO is
	generic (
		nbits : integer := 16;
		shift_direction : character := 'l';
		shift_step : integer := 1
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		clk : in std_logic;
		mode : in std_logic; -- 0 = parallel load, 1 = shift
		output : out std_logic_vector(nbits-1 downto 0);
		serial_input : in std_logic;
		serial_output : out std_logic
	);
	end component;
	signal result_piso_input : std_logic_vector((2*192)-1 downto 0);
	signal result_piso_clk : std_logic;
	signal result_piso_output : std_logic;
	signal result_piso_pout : std_logic_vector((2*192)-1 downto 0);

	component Reg_SIPO is
	generic (
		nbits : integer := 16
	);
	port (
		input : in std_logic;
		clk : in std_logic;
		rst : in std_logic;
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal point_sipo_input : std_logic;
	signal point_sipo_clk : std_logic;
	signal point_sipo_output : std_logic_vector((2*192)-1 downto 0);
	signal k_sipo_input : std_logic;
	signal k_sipo_clk : std_logic;
	signal k_sipo_output : std_logic_vector(192-1 downto 0);
	signal a_sipo_input : std_logic;
	signal a_sipo_clk : std_logic;
	signal a_sipo_output : std_logic_vector(192-1 downto 0);
	signal p_sipo_input : std_logic;
	signal p_sipo_clk : std_logic;
	signal p_sipo_output : std_logic_vector(192-1 downto 0);
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

	point_sipo : Reg_SIPO generic map (nbits => 192*2)
	port map (
		input => point_sipo_input,
		clk => point_sipo_clk,
		rst => '0',
		output => point_sipo_output
	);
	k_sipo : Reg_SIPO generic map (nbits => 192)
	port map (
		input => k_sipo_input,
		clk => k_sipo_clk,
		rst => '0',
		output => k_sipo_output
	);
	a_sipo : Reg_SIPO generic map (nbits => 192)
	port map (
		input => a_sipo_input,
		clk => a_sipo_clk,
		rst => '0',
		output => a_sipo_output
	);
	p_sipo : Reg_SIPO generic map (nbits => 192)
	port map (
		input => p_sipo_input,
		clk => p_sipo_clk,
		rst => '0',
		output => p_sipo_output
	);

	result_piso : Reg_PIxO
	generic map (
		nbits => 192*2,
		shift_direction => 'l',
		shift_step => 1
	) port map (
		input => result_piso_input,
		clk => result_piso_clk,
		mode => result_mode,
		output => result_piso_pout,
		serial_input => '0',
		serial_output => result_piso_output
	);

	point_sipo_input <= data;
	k_sipo_input <= data;
	a_sipo_input <= data;
	p_sipo_input <= data;

	-- demux-ed clocks
	point_sipo_clk  <= '1' when data_sel="00" and data_clk='1' else '0';
	k_sipo_clk	<= '1' when data_sel="01" and data_clk='1' else '0';
	a_sipo_clk	<= '1' when data_sel="10" and data_clk='1' else '0';
	p_sipo_clk	<= '1' when data_sel="11" and data_clk='1' else '0';

	PM_Point <= point_sipo_output;
	PM_k <= k_sipo_output;
	PM_p <= p_sipo_output;
	PM_a <= a_sipo_output;

	result_piso_input <= PM_Result;
	result_piso_clk <= result_clk;
	result <= result_piso_output;

	PM_start <= start;
	done <= PM_done;
	inf <= PM_inf;
end rtl;
