-- Component: Math_SerialMul
-- Desc: serial unsigned multiplier
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Math_SerialMul is
generic (
	nbits : integer := 16
);
port (
	a : in std_logic_vector(nbits-1 downto 0);
	b : in std_logic_vector(nbits-1 downto 0);
	clk : in std_logic;
	start : in std_logic;
	y : out std_logic_vector((2*nbits)-1 downto 0);
	done : out std_logic
);
end Math_SerialMul;

architecture serialarch of Math_SerialMul is
	-- Taken from "Digital Design from Zero to One, pp. 545
	component Reg_PIPO is
	generic (
		nbits : integer := 16
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		clk : in std_logic;
		rst : in std_logic;
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal reg_a_input : std_logic_vector(nbits-1 downto 0);
	signal reg_a_clk : std_logic;
	--signal reg_a_rst : std_logic; -- not used
	signal reg_a_output : std_logic_vector(nbits-1 downto 0);
	-- Note: accumulator has nbits+1, the MSb is used to store the carryout of the adder
	signal reg_acc_input : std_logic_vector(nbits downto 0);
	signal reg_acc_clk : std_logic;
	signal reg_acc_rst : std_logic;
	signal reg_acc_output : std_logic_vector(nbits downto 0);

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
	signal reg_b_input : std_logic_vector(nbits-1 downto 0);
	signal reg_b_clk : std_logic;
	signal reg_b_mode : std_logic;
	signal reg_b_output : std_logic_vector(nbits-1 downto 0);
	--signal reg_b_si : std_logic; -- not used, set to 0
	signal reg_b_so : std_logic;
	signal reg_reslsb_input : std_logic_vector(nbits-1 downto 0); -- not used, set to 0
	signal reg_reslsb_clk : std_logic;
	--signal reg_reslsb_mode : std_logic; -- not used, set to 1 (shift)
	signal reg_reslsb_output : std_logic_vector(nbits-1 downto 0);
	signal reg_reslsb_si : std_logic;
	signal reg_reslsb_so : std_logic;
	signal reg_flag_input : std_logic_vector(nbits-1 downto 0);
	signal reg_flag_clk : std_logic;
	signal reg_flag_mode : std_logic;
	signal reg_flag_output : std_logic_vector(nbits-1 downto 0);
	--signal reg_flag_si : std_logic; -- not used, set to 1
	signal reg_flag_so : std_logic;

	component Math_RippleFAS is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		op : in std_logic; -- 0 = add, 1 = sub
		cbi : in std_logic;
		y : out std_logic_vector(nbits-1 downto 0);
		cbo : out std_logic
	);
	end component;
	signal adder_a : std_logic_vector(nbits-1 downto 0);
	signal adder_b : std_logic_vector(nbits-1 downto 0);
	--signal adder_op : std_logic; -- not used, set to 0 (add)
	--signal adder_cbi : std_logic; -- not used, set to 0 (no carry)
	signal adder_y : std_logic_vector(nbits-1 downto 0);
	signal adder_cbo : std_logic;

	component Mux_2to1 is
	generic (
		nbits : integer := 16
	);
	port (
		input0 : in std_logic_vector(nbits-1 downto 0);
		input1 : in std_logic_vector(nbits-1 downto 0);
		sel : in std_logic;
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	--signal mux_in0 : std_logic_vector(nbits-1 downto 0); -- not used, set to 0
	signal mux_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_sel : std_logic;
	signal mux_out : std_logic_vector(nbits-1 downto 0);

	type state_t is (
		SLEEP,
		LOAD_OPERANDS,
		SET_MODE,
		DO_SUM,
		SHIFT_B,
		MUL_DONE
	);
	signal state : state_t := SLEEP;
begin
	reg_a : Reg_PIPO generic map (nbits => nbits) port map (reg_a_input, reg_a_clk, '0', reg_a_output);
	reg_acc : Reg_PIPO generic map (nbits => nbits+1) port map (reg_acc_input, reg_acc_clk, reg_acc_rst, reg_acc_output);
	reg_b : Reg_PIxO generic map (nbits => nbits, shift_direction => 'r') port map (reg_b_input, reg_b_clk, reg_b_mode, reg_b_output, '0', reg_b_so);
	reg_reslsb : Reg_PIxO generic map (nbits => nbits, shift_direction => 'r') port map (reg_reslsb_input, reg_reslsb_clk, '1', reg_reslsb_output, reg_reslsb_si, reg_reslsb_so);
	reg_flag : Reg_PIxO generic map (nbits => nbits, shift_direction => 'r') port map (reg_flag_input, reg_flag_clk, reg_flag_mode, reg_flag_output, '1', reg_flag_so);
	adder : Math_RippleFAS generic map (nbits => nbits) port map (adder_a, adder_b, '0', '0', adder_y, adder_cbo);
	mult_mux : Mux_2to1 generic map (nbits => nbits) port map ((others => '0'), mux_in1, mux_sel, mux_out);
	
	reg_a_input <= a;
	reg_b_input <= b;
	reg_reslsb_input <= (others => '0');
	--reg_flag_input(nbits-1) <= '1';
	--reg_flag_input(nbits-2 downto 0) <= (others => '0');
	reg_flag_input <= (others => '0');
	reg_acc_input <= adder_cbo & adder_y;
	reg_reslsb_si <= reg_acc_output(0);
	mux_in1 <= reg_a_output;
	mux_sel <= reg_b_so;
	adder_a <= mux_out;
	adder_b <= reg_acc_output(nbits downto 1);

	y <= reg_acc_output(nbits downto 1) & reg_reslsb_output;

	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if (start = '1') then
					state <= LOAD_OPERANDS;
				else
					state <= SLEEP;
				end if;
			when LOAD_OPERANDS =>
				state <= SET_MODE;
			when SET_MODE =>
				if (reg_flag_so = '1') then
					state <= MUL_DONE;
				else
					state <= DO_SUM;
				end if;
			when DO_SUM =>
				state <= SHIFT_B;
			when SHIFT_B =>
				state <= SET_MODE;
			when MUL_DONE =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= MUL_DONE;
				end if;
			when others =>
				state <= SLEEP;
			end case;
		end if;
	end process;

	datapath : process(state)
	begin
		case state is
		when SLEEP => 
			reg_a_clk <= '0';
			reg_b_clk <= '0';
			reg_b_mode <= '0';
			reg_acc_clk <= '0';
			reg_acc_rst <= '0';
			reg_reslsb_clk <= '0';
			reg_flag_clk <= '0';
			reg_flag_mode <= '0';
			done <= '0';
		when LOAD_OPERANDS => 
			reg_a_clk <= '1';
			reg_b_clk <= '1';
			reg_b_mode <= '0';
			reg_acc_clk <= '0';
			reg_acc_rst <= '1';
			reg_reslsb_clk <= '0';
			reg_flag_clk <= '1';
			reg_flag_mode <= '0';
			done <= '0';
		when SET_MODE => 
			reg_a_clk <= '0';
			reg_b_clk <= '0';
			reg_b_mode <= '1';
			reg_acc_clk <= '0';
			reg_acc_rst <= '0';
			reg_reslsb_clk <= '0';
			reg_flag_clk <= '0';
			reg_flag_mode <= '1';
			done <= '0';
		when DO_SUM => 
			reg_a_clk <= '0';
			reg_b_clk <= '0';
			reg_b_mode <= '1';
			reg_acc_clk <= '1';
			reg_acc_rst <= '0';
			reg_reslsb_clk <= '1';
			reg_flag_clk <= '1';
			reg_flag_mode <= '1';
			done <= '0';
		when SHIFT_B => 
			reg_a_clk <= '0';
			reg_b_clk <= '1';
			reg_b_mode <= '1';
			reg_acc_clk <= '1';
			reg_acc_rst <= '0';
			reg_reslsb_clk <= '0';
			reg_flag_clk <= '0';
			reg_flag_mode <= '1';
			done <= '0';
		when MUL_DONE =>
			reg_a_clk <= '0';
			reg_b_clk <= '0';
			reg_b_mode <= '1';
			reg_acc_clk <= '0';
			reg_acc_rst <= '0';
			reg_reslsb_clk <= '1';
			reg_flag_clk <= '0';
			reg_flag_mode <= '1';
			done <= '1';
		when others =>
			reg_a_clk <= '0';
			reg_b_clk <= '0';
			reg_b_mode <= '0';
			reg_acc_clk <= '0';
			reg_acc_rst <= '0';
			reg_reslsb_clk <= '0';
			reg_flag_clk <= '0';
			reg_flag_mode <= '0';
			done <= '0';
		end case;
	end process;
end serialarch;
