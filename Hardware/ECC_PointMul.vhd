-- Component: ECC_PointMul
-- Desc: Affine Coordinate Scalar Point Multiplication
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity ECC_PointMul is
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
end ECC_PointMul;

architecture rtl of ECC_PointMul is
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
	signal reg_point_input : std_logic_vector((2*nbits)-1 downto 0);
	signal reg_point_clk : std_logic;
	signal reg_point_output : std_logic_vector((2*nbits)-1 downto 0);
	signal reg_result_input : std_logic_vector((2*nbits)-1 downto 0);
	signal reg_result_clk : std_logic;
	signal reg_result_output : std_logic_vector((2*nbits)-1 downto 0);

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
	signal reg_k_input : std_logic_vector(nbits-1 downto 0);
	signal reg_k_clk : std_logic;
	signal reg_k_mode : std_logic;
	signal reg_k_output : std_logic_vector(nbits-1 downto 0);
	signal reg_k_serial_input : std_logic;
	signal reg_k_serial_output : std_logic;
	signal reg_mark_input : std_logic_vector(nbits-1 downto 0);
	signal reg_mark_clk : std_logic;
	signal reg_mark_mode : std_logic;
	signal reg_mark_output : std_logic_vector(nbits-1 downto 0);
	signal reg_mark_serial_input : std_logic;
	signal reg_mark_serial_output : std_logic;

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
	signal mux_point_input0 : std_logic_vector((2*nbits)-1 downto 0);
	signal mux_point_input1 : std_logic_vector((2*nbits)-1 downto 0);
	signal mux_point_sel : std_logic;
	signal mux_point_output : std_logic_vector((2*nbits)-1 downto 0);
	signal mux_q_input0 : std_logic_vector((2*nbits)-1 downto 0);
	signal mux_q_input1 : std_logic_vector((2*nbits)-1 downto 0);
	signal mux_q_sel : std_logic;
	signal mux_q_output : std_logic_vector((2*nbits)-1 downto 0);

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
		op : in std_logic; -- 0 = add, 1 = double
		start : in std_logic;
		clk : in std_logic;
		done : out std_logic;
		err : out std_logic;
		inf : out std_logic
	);
	end component;
	signal PDA_P : std_logic_vector((2*nbits)-1 downto 0);
	signal PDA_Q : std_logic_vector((2*nbits)-1 downto 0);
	signal PDA_mod_p : std_logic_vector(nbits-1 downto 0);
	signal PDA_a : std_logic_vector(nbits-1 downto 0);
	signal PDA_R : std_logic_vector((2*nbits)-1 downto 0);
	signal PDA_op : std_logic; -- 0 = add, 1 = double
	signal PDA_start : std_logic;
	signal PDA_clk : std_logic;
	signal PDA_done : std_logic;
	signal PDA_err : std_logic;
	signal PDA_inf : std_logic;

	signal manual_result_clk : std_logic;

	type state_t is (
		SLEEP,
		LOAD_OPERANDS,
		SETOP_SHIFT,
		SEARCH_BIT,
		INIT_RESULT,
		SETOP_ADD,
		DO_POINTADD,
		SETOP_DOUBLE,
		DO_POINTDOUBLE,
		NEXT_BIT,
		COMPLETED,
		INFINITE
	);
	signal state : state_t := SLEEP;
begin
	reg_point : Reg_PIPO generic map (nbits => 2*nbits)
	port map (
		input => reg_point_input,
		clk => reg_point_clk,
		rst => '0',
		output => reg_point_output
	);
	reg_result : Reg_PIPO generic map (nbits => 2*nbits)
	port map (
		input => reg_result_input,
		clk => reg_result_clk,
		rst => '0',
		output => reg_result_output
	);
	reg_k : Reg_PIxO generic map (nbits => nbits, shift_direction => 'l', shift_step => 1)
	port map (
		input => reg_k_input,
		clk => reg_k_clk,
		mode => reg_k_mode,
		output => reg_k_output,
		serial_input => reg_k_serial_input,
		serial_output => reg_k_serial_output
	);
	reg_mark : Reg_PIxO generic map (nbits => nbits, shift_direction => 'l', shift_step => 1)
	port map (
		input => reg_mark_input,
		clk => reg_mark_clk,
		mode => reg_mark_mode,
		output => reg_mark_output,
		serial_input => reg_mark_serial_input,
		serial_output => reg_mark_serial_output
	);
	mux_point : Mux_2to1 generic map (nbits => 2*nbits)
	port map (
		input0 => mux_point_input0,
		input1 => mux_point_input1,
		sel => mux_point_sel,
		output => mux_point_output
	);
	mux_q : Mux_2to1 generic map (nbits => 2*nbits)
	port map (
		input0 => mux_q_input0,
		input1 => mux_q_input1,
		sel => mux_q_sel,
		output => mux_q_output
	);
	PDA : ECC_DoublerAdder generic map (nbits => nbits)
	port map (
		P => PDA_P,
		Q => PDA_Q,
		mod_p => PDA_mod_p,
		a => PDA_a,
		R => PDA_R,
		op => PDA_op,
		start => PDA_start,
		clk => PDA_clk,
		done => PDA_done,
		err => PDA_err,
		inf => PDA_inf
	);
	-- ================================================
	reg_point_input <= Point;
	reg_result_input <= mux_point_output;
	reg_k_serial_input <= '0';
	reg_k_input <= k;
	reg_mark_serial_input <= '0';
	reg_mark_input(nbits-1 downto 1) <= (others => '0'); reg_mark_input(0) <= '1';

	mux_point_input0 <= Point;
	mux_point_input1 <= PDA_R;

	reg_result_clk <= manual_result_clk or PDA_done;

	mux_q_input0 <= reg_point_output;
	mux_q_input1 <= reg_result_output;
	mux_q_sel <= PDA_op;

	PDA_clk <= clk;
	PDA_mod_p <= p;
	PDA_a <= a;
	PDA_P <= reg_result_output;
	--PDA_Q <= reg_point_output;
	PDA_Q <= mux_q_output;

	Result <= reg_result_output;
	-- ================================================
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
				state <= SETOP_SHIFT;
			when SETOP_SHIFT =>
				state <= SEARCH_BIT;
			when SEARCH_BIT =>
				if (reg_k_serial_output = '1') then
					state <= INIT_RESULT;
				else
					if (reg_mark_serial_output = '1') then
						state <= COMPLETED;
					else
						state <= SETOP_SHIFT;
					end if;
				end if;
			when INIT_RESULT =>
				if (reg_mark_serial_output = '1') then
					state <= COMPLETED;
				else
					state <= SETOP_DOUBLE;
				end if;
			when SETOP_ADD =>
				state <= DO_POINTADD;
			when DO_POINTADD =>
				if (PDA_done = '1') then
					if (reg_mark_serial_output = '1') then
						state <= COMPLETED;
					else
						state <= SETOP_DOUBLE;
					end if;
				else
					state <= DO_POINTADD;
				end if;
			when SETOP_DOUBLE =>
				state <= DO_POINTDOUBLE;
			when DO_POINTDOUBLE =>
				if (PDA_done = '1') then
					state <= NEXT_BIT;
				else
					state <= DO_POINTDOUBLE;
				end if;
			when NEXT_BIT =>
				if (reg_k_serial_output = '1') then
					state <= SETOP_ADD;
				else
					if (reg_mark_serial_output = '1') then
						state <= COMPLETED;
					else
						state <= SETOP_DOUBLE;
					end if;
				end if;
			when COMPLETED =>
				if (start = '1') then
					state <= COMPLETED;
				else
					state <= SLEEP;
				end if;
			when INFINITE =>
				if (start = '1') then
					state <= COMPLETED;
				else
					state <= SLEEP;
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
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '0'; reg_k_clk <= '0';
			reg_mark_mode <= '0'; reg_mark_clk <= '0';
			mux_point_sel <= '0';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '0'; inf <= '0';
		when LOAD_OPERANDS =>
			reg_point_clk <= '1'; manual_result_clk <= '0';
			reg_k_mode <= '0'; reg_k_clk <= '1';
			reg_mark_mode <= '0'; reg_mark_clk <= '1';
			mux_point_sel <= '0';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '0'; inf <= '0';
		when SETOP_SHIFT =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '0';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '0'; inf <= '0';
		when SEARCH_BIT =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '1';
			reg_mark_mode <= '1'; reg_mark_clk <= '1';
			mux_point_sel <= '0';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '0'; inf <= '0';
		when INIT_RESULT =>
			reg_point_clk <= '0'; manual_result_clk <= '1';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '0';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '0'; inf <= '0';
		when SETOP_ADD =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '1';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '0'; inf <= '0';
		when DO_POINTADD =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '1';
			PDA_op <= '0'; PDA_start <= '1';
			done <= '0'; inf <= '0';
		when SETOP_DOUBLE =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '1';
			PDA_op <= '1'; PDA_start <= '0';
			done <= '0'; inf <= '0';
		when DO_POINTDOUBLE =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '1';
			PDA_op <= '1'; PDA_start <= '1';
			done <= '0'; inf <= '0';
		when NEXT_BIT =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '1';
			reg_mark_mode <= '1'; reg_mark_clk <= '1';
			mux_point_sel <= '1';
			PDA_op <= '1'; PDA_start <= '0';
			done <= '0'; inf <= '0';
		when COMPLETED =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '1';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '1'; inf <= '0';
		when INFINITE =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '1';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '1'; inf <= '1';
		when others =>
			reg_point_clk <= '0'; manual_result_clk <= '0';
			reg_k_mode <= '1'; reg_k_clk <= '0';
			reg_mark_mode <= '1'; reg_mark_clk <= '0';
			mux_point_sel <= '1';
			PDA_op <= '0'; PDA_start <= '0';
			done <= '0'; inf <= '1';
		end case;
	end process;
end rtl;
