-- Component: Math_Mod
-- Desc: An implementation of a integer divison block
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Mod is
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
end Math_Mod;

architecture rtl of Math_Mod is
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
	-- p (divisor)
	signal p_input : std_logic_vector(nbits-1 downto 0);
	signal p_clk : std_logic;
	signal p_mode : std_logic;
	signal p_output : std_logic_vector(nbits-1 downto 0);
	signal p_serial_input : std_logic;
	signal p_serial_output : std_logic;
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
	-- mux for p parallel input
	signal mux_p_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_p_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_p_sel : std_logic;
	signal mux_p_out : std_logic_vector(nbits-1 downto 0);
	-- mux for mark parallel input
	signal mux_mark_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_mark_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_mark_sel : std_logic;
	signal mux_mark_out : std_logic_vector(nbits-1 downto 0);

	--component Math_Sub is
	--generic (
	--	nbits : integer := 16
	--);
	--port (
	--	A : in std_logic_vector(nbits-1 downto 0);
	--	B : in std_logic_vector(nbits-1 downto 0);
	--	Borrow_in : in std_logic;
	--	Diff : out std_logic_vector(nbits-1 downto 0);
	--	Borrow_out : out std_logic
	--);
	--end component;
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
	signal iszero_p_in : std_logic_vector(nbits-1 downto 0);
	signal iszero_p_out : std_logic;

	signal p_clk_manual : std_logic;
	signal p_enable : std_logic;

	type state_t is (
		SLEEP,
		LOAD_AB,
		PREP_SHL,
		SHIFT_LEFT,
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
	reg_p : Reg_PIxO generic map (nbits => nbits, shift_direction => 'l', shift_step => 1)
	port map (
		input => p_input,
		clk => p_clk,
		mode => p_mode,
		output => p_output,
		serial_input => p_serial_input,
		serial_output => p_serial_output
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
	mux_p : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_p_in0,
		input1 => mux_p_in1,
		sel => mux_p_sel,
		output => mux_p_out
	);
	mux_mark : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_mark_in0,
		input1 => mux_mark_in1,
		sel => mux_mark_sel,
		output => mux_mark_out
	);

	--subtractor : Math_Sub generic map (nbits => nbits)
	--port map (
	--	a => sub_a,
	--	b => sub_b,
	--	borrow_in => sub_bi,
	--	diff => sub_diff,
	--	borrow_out => sub_bo
	--);

	subtractor : Math_RippleFAS generic map (nbits => nbits)
	port map (
		a => sub_a,
		b => sub_b,
		op => '1',
		cbi => sub_bi,
		y => sub_diff,
		cbo => sub_bo
	);
	iszero_a : Math_ZeroCheck generic map (nbits => nbits)
	port map (
		input => iszero_a_in,
		result => iszero_a_out
	);
	iszero_p : Math_ZeroCheck generic map (nbits => nbits)
	port map (
		input => iszero_p_in,
		result => iszero_p_out
	);
	-- ================================================
	a_input <= mux_a_out;
	mux_a_in0 <= a;
	mux_a_in1 <= sub_diff;
	sub_a <= a_output;
	sub_b <= p_output;
	p_input <= mux_p_out;
	mux_p_in0 <= p;
	mux_p_in1 <= '0' & p_output(nbits-1 downto 1);
	r <= a_output;
	p_serial_input <= '0';
	mark_serial_input <= '0';
	mark_mode <= p_mode;
	mark_input <= mux_mark_out;
	mux_mark_in0(nbits-1 downto 1) <= (others => '0');
	mux_mark_in0(0) <= '1';
	mux_mark_in1 <= '0' & mark_output(nbits-1 downto 1);
	mux_mark_sel <= mux_p_sel;
	sub_bi <= '0';
	-- shift left p
	p_clk <= p_clk_manual or (p_mode and not p_serial_output and clk and p_enable);
	mark_clk <= p_clk;
	iszero_a_in <= a_output;
	iszero_p_in <= p_output;
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
				if (iszero_p_out = '1') then
					state <= DIVZERO;
				elsif (iszero_a_out = '1') then
					state <= RETZERO;
				else
					state <= PREP_SHL;
				end if;
			when PREP_SHL =>
				if (p_serial_output = '1') then
					state <= PREP_DIV;
				else
					state <= SHIFT_LEFT;
				end if;
			when SHIFT_LEFT =>
				if (sub_bo  = '1' or p_serial_output = '1') then
					state <= PREP_DIV;
				else
					state <= SHIFT_LEFT;
				end if;
			when PREP_DIV =>
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
				state <= PREP_DIV;
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
			mux_p_sel <= '0';
			p_mode <= '0';
			p_enable <= '0';
			a_clk <= '0';
			p_clk_manual <= '0';
			done <= '0';
			div_error <= '0';
		when LOAD_AB =>
			mux_a_sel <= '0';
			mux_p_sel <= '0';
			p_mode <= '0';
			p_enable <= '0';
			a_clk <= '1';
			p_clk_manual <= '1';
			done <= '0';
			div_error <= '0';
		when PREP_SHL =>
			mux_a_sel <= '0';
			mux_p_sel <= '0';
			p_mode <= '1';
			p_enable <= '0';
			a_clk<= '0';
			p_clk_manual <= '0';
			done <= '0';
			div_error <= '0';
		when SHIFT_LEFT =>
			mux_a_sel <= '0';
			mux_p_sel <= '0';
			p_mode <= '1';
			p_enable <= '1';
			a_clk <= '0';
			p_clk_manual <= '0';
			done <= '0';
			div_error <= '0';
		when PREP_DIV =>
			mux_a_sel <= '1';
			mux_p_sel <= '1';
			p_mode <= '0';
			p_enable <= '0';
			a_clk <= '0';
			p_clk_manual <= '0';
			done <= '0';
			div_error <= '0';
		when UPDATE_A =>
			mux_a_sel <= '1';
			mux_p_sel <= '1';
			p_mode <= '0';
			p_enable <= '0';
			a_clk <= '1';
			p_clk_manual <= '0';
			done <= '0';
			div_error <= '0';
		when UPDATE_BM =>
			mux_a_sel <= '1';
			mux_p_sel <= '1';
			p_mode <= '0';
			p_enable <= '0';
			a_clk <= '0';
			p_clk_manual <= '1';
			done <= '0';
			div_error <= '0';
		when DIVDONE =>
			mux_a_sel <= '1';
			mux_p_sel <= '1';
			p_mode <= '0';
			p_enable <= '0';
			a_clk <= '0';
			p_clk_manual <= '0';
			done <= '1';
			div_error <= '0';
		when DIVZERO =>
			mux_a_sel <= '0';
			mux_p_sel <= '0';
			p_mode <= '1';
			p_enable <= '0';
			a_clk <= '0';
			p_clk_manual <= '0';
			done <= '1';
			div_error <= '1';
		when RETZERO =>
			mux_a_sel <= '0';
			mux_p_sel <= '0';
			p_mode <= '1';
			p_enable <= '0';
			a_clk <= '0';
			p_clk_manual <= '0';
			done <= '1';
			div_error <= '0';
		end case;
	end process;
end rtl;
