-- Component: tb_Reg_PIxO
-- Desc: Testbed for the Reg_PIxO component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Reg_PIxO is
end tb_Reg_PIxO;

architecture rtl of tb_Reg_PIxO is
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
	signal reg_input1 : std_logic_vector(15 downto 0);
	signal reg_clk1 : std_logic;
	signal reg_mode1 : std_logic; -- 0 = parallel load, 1 = shift
	signal reg_output1 : std_logic_vector(15 downto 0);
	signal reg_serial_input1 : std_logic;
	signal reg_serial_output1 : std_logic;

	signal reg_input2 : std_logic_vector(15 downto 0);
	signal reg_clk2 : std_logic;
	signal reg_mode2 : std_logic; -- 0 = parallel load, 1 = shift
	signal reg_output2 : std_logic_vector(15 downto 0);
	signal reg_serial_input2 : std_logic;
	signal reg_serial_output2 : std_logic;

	signal reg_input3 : std_logic_vector(31 downto 0);
	signal reg_clk3 : std_logic;
	signal reg_mode3 : std_logic; -- 0 = parallel load, 1 = shift
	signal reg_output3 : std_logic_vector(31 downto 0);
	signal reg_serial_input3 : std_logic;
	signal reg_serial_output3 : std_logic;
	signal clk : std_logic;
begin
	uut1 : Reg_PIxO
	generic map (
		nbits => 16,
		shift_direction => 'l'
	)
	port map (
		input => reg_input1,
		clk => reg_clk1,
		mode => reg_mode1,
		output => reg_output1,
		serial_input => reg_serial_input1,
		serial_output => reg_serial_output1
	);

	uut2 : Reg_PIxO
	generic map (
		nbits => 16,
		shift_direction => 'r'
	)
	port map (
		input => reg_input2,
		clk => reg_clk2,
		mode => reg_mode2,
		output => reg_output2,
		serial_input => reg_serial_input2,
		serial_output => reg_serial_output2
	);

	uut3 : Reg_PIxO
	generic map (
		nbits => 32,
		shift_direction => 'r',
		shift_step => 4
	)
	port map (
		input => reg_input3,
		clk => reg_clk3,
		mode => reg_mode3,
		output => reg_output3,
		serial_input => reg_serial_input3,
		serial_output => reg_serial_output3
	);

	reg_serial_input1 <= '0';
	reg_serial_input2 <= '0';
	reg_serial_input3 <= '0';

	-- default values
	reg_input1 <= x"1234";
	reg_input2 <= x"ABCD";
	reg_input3 <= x"89ABCDEF";

	-- clocks
	reg_clk1 <= clk;
	reg_clk2 <= not clk;
	reg_clk3 <= clk;

	clk_proc : process
	begin
		clk <= '0';
		wait for 2 ns;
		clk <= '1';
		wait for 2 ns;
	end process;

	stim_proc : process
	begin
		reg_mode1 <= '0';
		reg_mode2 <= '0';
		reg_mode3 <= '0';
		wait for 11 ns;
		reg_mode1 <= '1';
		reg_mode2 <= '1';
		reg_mode3 <= '1';
		wait;
	end process;
end rtl;
