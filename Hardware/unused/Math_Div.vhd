-- Component: Math_Div
-- Desc: An implementation of a integer divison block
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Div is
generic (
	nbits : integer := 16
);
port (
	a : in std_logic_vector(nbits-1 downto 0);
	b : in std_logic_vector(nbits-1 downto 0);
	r : out std_logic_vector(nbits-1 downto 0);
	q : out std_logic_vector(nbits-1 downto 0);
	start : in std_logic;
	clk : in std_logic;
	done : out std_logic;
	div_error : out std_logic
);
end Math_Div;

architecture rtl of Math_Div is
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
	-- a (dividend/remainder)
	signal a_input : std_logic_vector(nbits-1 downto 0);
	signal a_clk : std_logic;
	signal a_output : std_logic_vector(nbits-1 downto 0);

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
	-- b (divisor)
	signal b_input : std_logic_vector(nbits-1 downto 0);
	signal b_clk : std_logic;
	signal b_mode : std_logic;
	signal b_output : std_logic_vector(nbits-1 downto 0);
	signal b_serial_input : std_logic;
	signal b_serial_output : std_logic;
	-- q (quotient)
	signal q_input : std_logic_vector(nbits-1 downto 0);
	signal q_clk : std_logic;
	signal q_mode : std_logic;
	signal q_output : std_logic_vector(nbits-1 downto 0);
	signal q_serial_input : std_logic;
	signal q_serial_output : std_logic;
	-- mark
	signal mark_input : std_logic_vector(nbits-1 downto 0);
	signal mark_clk : std_logic;
	signal mark_mode : std_logic;
	signal mark_output : std_logic_vector(nbits-1 downto 0);
	signal mark_serial_input : std_logic;
	signal mark_serial_output : std_logic;

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
	-- mux for a parallel input
	signal mux_a_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_a_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_a_sel : std_logic;
	signal mux_a_out : std_logic_vector(nbits-1 downto 0);
	-- mux for b parallel input
	signal mux_b_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_b_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_b_sel : std_logic;
	signal mux_b_out : std_logic_vector(nbits-1 downto 0);
	-- mux for mark parallel input
	signal mux_mark_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_mark_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_mark_sel : std_logic;
	signal mux_mark_out : std_logic_vector(nbits-1 downto 0);

	component Math_Sub is
	generic (
		nbits : integer := 16
	);
	port (
		A : in std_logic_vector(nbits-1 downto 0);
		B : in std_logic_vector(nbits-1 downto 0);
		Borrow_in : in std_logic;
		Diff : out std_logic_vector(nbits-1 downto 0);
		Borrow_out : out std_logic
	);
	end component;
	signal sub_a : std_logic_vector(nbits-1 downto 0);
	signal sub_b : std_logic_vector(nbits-1 downto 0);
	signal sub_bi : std_logic;
	signal sub_diff : std_logic_vector(nbits-1 downto 0);
	signal sub_bo : std_logic;

	component Math_ZeroCheck is
	generic (
		nbits : integer := 8
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		result : out std_logic
	);
	end component;
	signal iszero_a_in : std_logic_vector(nbits-1 downto 0);
	signal iszero_a_out : std_logic;
	signal iszero_b_in : std_logic_vector(nbits-1 downto 0);
	signal iszero_b_out : std_logic;

	signal b_clk_manual : std_logic;
	signal b_enable : std_logic;

	type state_t is (
		SLEEP,
		LOAD_AB,
		PREP_SHL,
		SHIFT_LEFT,
		UPDATE_Q,
		PREP_DIV,
		UPDATE_A,
		UPDATE_BM,
		DIVDONE,
		DIVZERO,
		RETZERO
	);
	signal state : state_t := SLEEP;
begin
	reg_a : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => a_input,
		clk => a_clk,
		rst => '0',
		output => a_output
	);
	reg_b : Reg_PIxO generic map (nbits => nbits, shift_direction => 'l', shift_step => 1)
	port map (
		input => b_input,
		clk => b_clk,
		mode => b_mode,
		output => b_output,
		serial_input => b_serial_input,
		serial_output => b_serial_output
	);
	reg_q : Reg_PIxO generic map (nbits => nbits, shift_direction => 'l', shift_step => 1)
	port map (
		input => q_input,
		clk => q_clk,
		mode => q_mode,
		output => q_output,
		serial_input => q_serial_input,
		serial_output => q_serial_output
	);
	reg_mark : Reg_PIxO generic map (nbits => nbits, shift_direction => 'l', shift_step => 1)
	port map (
		input => mark_input,
		clk => mark_clk,
		mode => mark_mode,
		output => mark_output,
		serial_input => mark_serial_input,
		serial_output => mark_serial_output
	);
	mux_a : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_a_in0,
		input1 => mux_a_in1,
		sel => mux_a_sel,
		output => mux_a_out
	);
	mux_b : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_b_in0,
		input1 => mux_b_in1,
		sel =>    mux_b_sel,
		output => mux_b_out
	);
	mux_mark : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_mark_in0,
		input1 => mux_mark_in1,
		sel => mux_mark_sel,
		output => mux_mark_out
	);
	subtractor : Math_Sub generic map (nbits => nbits)
	port map (
		a => sub_a,
		b => sub_b,
		borrow_in => sub_bi,
		diff => sub_diff,
		borrow_out => sub_bo
	);
	iszero_a : Math_ZeroCheck generic map (nbits => nbits)
	port map (
		input => iszero_a_in,
		result => iszero_a_out
	);
	iszero_b : Math_ZeroCheck generic map (nbits => nbits)
	port map (
		input => iszero_b_in,
		result => iszero_b_out
	);
	-- ================================================
	a_input <= mux_a_out;
	mux_a_in0 <= a;
	mux_a_in1 <= sub_diff;
	sub_a <= a_output;
	sub_b <= b_output;
	b_input <= mux_b_out;
	mux_b_in0 <= b;
	mux_b_in1 <= '0' & b_output(nbits-1 downto 1);
	q_input <= (others => '0');
	q <= q_output;
	r <= a_output;
	b_serial_input <= '0';
	mark_serial_input <= '0';
	mark_mode <= b_mode;
	mark_input <= mux_mark_out;
	mux_mark_in0(nbits-1 downto 1) <= (others => '0');
	mux_mark_in0(0) <= '1';
	mux_mark_in1 <= '0' & mark_output(nbits-1 downto 1);
	mux_mark_sel <= mux_b_sel;
	sub_bi <= '0';
	q_serial_input <= not sub_bo;
	-- shift left b
	b_clk <= b_clk_manual or (b_mode and not b_serial_output and clk and b_enable);
	mark_clk <= b_clk;
	iszero_a_in <= a_output;
	iszero_b_in <= b_output;
	-- ================================================
	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if (start = '1') then
					state <= LOAD_AB;
				else
					state <= SLEEP;
				end if;
			when LOAD_AB =>
				if (iszero_b_out = '1') then
					state <= DIVZERO;
				elsif (iszero_a_out = '1') then
					state <= RETZERO;
				else
					state <= PREP_SHL;
				end if;
			when PREP_SHL =>
				if (sub_bo = '1' or b_serial_output = '1') then
					state <= PREP_DIV;
				else
					state <= SHIFT_LEFT;
				end if;
			when SHIFT_LEFT =>
				if (sub_bo = '1' or b_serial_output = '1') then
					state <= PREP_DIV;
				else
					state <= SHIFT_LEFT;
				end if;
			when PREP_DIV =>
				state <= UPDATE_Q;
			when UPDATE_Q =>
				if (sub_bo = '1') then
					if (mark_output(0) = '1') then
						state <= DIVDONE;
					else
						state <= UPDATE_BM;
					end if;
				else
					state <= UPDATE_A;
				end if;
			when UPDATE_A =>
				if (mark_output(0) = '1') then
					state <= DIVDONE;
				else
					state <= UPDATE_BM;
				end if;
			when UPDATE_BM =>
				state <= UPDATE_Q;
			when DIVDONE =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= DIVDONE;
				end if;
			when DIVZERO =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= DIVZERO;
				end if;
			when RETZERO =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= RETZERO;
				end if;
			end case;
		end if;
	end process;

	-- ================================================
	datapath : process(state)
	begin
		case state is
		when SLEEP =>
			mux_a_sel <= '0';
			mux_b_sel <= '0';
			b_mode <= '0';
			q_mode <= '0';
			b_enable <= '0';
			a_clk <= '0';
			b_clk_manual <= '0';
			q_clk <= '0';
			done <= '0';
			div_error <= '0';
		when LOAD_AB =>
			mux_a_sel <= '0';
			mux_b_sel <= '0';
			b_mode <= '0';
			q_mode <= '0';
			b_enable <= '0';
			a_clk <= '1';
			b_clk_manual <= '1';
			q_clk <= '1';
			done <= '0';
			div_error <= '0';
		when PREP_SHL =>
			mux_a_sel <= '0';
			mux_b_sel <= '0';
			b_mode <= '1';
			q_mode <= '0';
			b_enable <= '0';
			a_clk<= '0';
			b_clk_manual <= '0';
			q_clk <= '0';
			done <= '0';
			div_error <= '0';
		when SHIFT_LEFT =>
			mux_a_sel <= '0';
			mux_b_sel <= '0';
			b_mode <= '1';
			q_mode <= '1';
			b_enable <= '1';
			a_clk <= '0';
			b_clk_manual <= '0';
			q_clk <= '0';
			done <= '0';
			div_error <= '0';
		when PREP_DIV =>
			mux_a_sel <= '1';
			mux_b_sel <= '1';
			b_mode <= '0';
			q_mode <= '1';
			b_enable <= '0';
			a_clk <= '0';
			b_clk_manual <= '0';
			q_clk <= '0';
			done <= '0';
			div_error <= '0';
		when UPDATE_Q =>
			mux_a_sel <= '1';
			mux_b_sel <= '1';
			b_mode <= '0';
			q_mode <= '1';
			b_enable <= '0';
			a_clk <= '0';
			b_clk_manual <= '0';
			q_clk <= '1';
			done <= '0';
			div_error <= '0';
		when UPDATE_A =>
			mux_a_sel <= '1';
			mux_b_sel <= '1';
			b_mode <= '0';
			q_mode <= '1';
			b_enable <= '0';
			a_clk <= '1';
			b_clk_manual <= '0';
			q_clk <= '0';
			done <= '0';
			div_error <= '0';
		when UPDATE_BM =>
			mux_a_sel <= '1';
			mux_b_sel <= '1';
			b_mode <= '0';
			q_mode <= '1';
			b_enable <= '0';
			a_clk <= '0';
			b_clk_manual <= '1';
			q_clk <= '0';
			done <= '0';
			div_error <= '0';
		when DIVDONE =>
			mux_a_sel <= '1';
			mux_b_sel <= '1';
			b_mode <= '0';
			q_mode <= '1';
			b_enable <= '0';
			a_clk <= '0';
			b_clk_manual <= '0';
			q_clk <= '0';
			done <= '1';
			div_error <= '0';
		when DIVZERO =>
			mux_a_sel <= '0';
			mux_b_sel <= '0';
			b_mode <= '1';
			q_mode <= '0';
			b_enable <= '0';
			a_clk <= '0';
			b_clk_manual <= '0';
			q_clk <= '0';
			done <= '1';
			div_error <= '1';
		when RETZERO =>
			mux_a_sel <= '0';
			mux_b_sel <= '0';
			b_mode <= '1';
			q_mode <= '0';
			b_enable <= '0';
			a_clk <= '0';
			b_clk_manual <= '0';
			q_clk <= '0';
			done <= '1';
			div_error <= '0';
		end case;
	end process;
end rtl;
