-- Component: Math_Invert_modN
-- Desc: Compute modular inversion modulo n via a simple EEA-based algorithm
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Invert_modN is
generic (
	nbits : integer := 16
);
port (
	a : in std_logic_vector(nbits-1 downto 0);
	n : in std_logic_vector(nbits-1 downto 0);
	inv_a : out std_logic_vector(nbits-1 downto 0);
	clk : in std_logic;
	start : in std_logic;
	done : out std_logic;
	inv_err : out std_logic
);
end Math_Invert_modN;

architecture rtl of Math_Invert_modN is
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
	-- the modulo
	signal n_input : std_logic_vector(nbits-1 downto 0);
	signal n_clk : std_logic;
	signal n_output : std_logic_vector(nbits-1 downto 0);
	-- current remainder
	signal r_input : std_logic_vector(nbits-1 downto 0);
	signal r_clk : std_logic;
	signal r_output : std_logic_vector(nbits-1 downto 0);
	-- old remainder
	signal oldr_input : std_logic_vector(nbits-1 downto 0);
	signal oldr_clk : std_logic;
	signal oldr_output : std_logic_vector(nbits-1 downto 0);
	-- current quotient
	signal q_input : std_logic_vector(nbits-1 downto 0);
	signal q_clk : std_logic;
	signal q_output : std_logic_vector(nbits-1 downto 0);
	-- current s
	signal s_input : std_logic_vector(nbits-1 downto 0);
	signal s_clk : std_logic;
	signal s_output : std_logic_vector(nbits-1 downto 0);
	-- current s1
	signal olds_input : std_logic_vector(nbits-1 downto 0);
	signal olds_clk : std_logic;
	signal olds_output : std_logic_vector(nbits-1 downto 0);
	-- temp storage for s*q
	signal sq_input : std_logic_vector(nbits-1 downto 0);
	signal sq_clk : std_logic;
	signal sq_output : std_logic_vector(nbits-1 downto 0);
	-- temp storage for the new value of s
	signal nexts_input : std_logic_vector(nbits-1 downto 0);
	signal nexts_clk : std_logic;
	signal nexts_output : std_logic_vector(nbits-1 downto 0);

	component Math_ZeroCheck is
	generic (
		nbits : integer := 8
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		result : out std_logic
	);
	end component;
	signal iszero_r_input : std_logic_vector(nbits-2 downto 0);
	signal iszero_r_result : std_logic;

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
	signal mux_r_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_r_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_r_out : std_logic_vector(nbits-1 downto 0);
	signal mux_r_sel : std_logic;
	signal mux_oldr_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_oldr_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_oldr_out : std_logic_vector(nbits-1 downto 0);
	signal mux_oldr_sel : std_logic;
	signal mux_s_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_s_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_s_out : std_logic_vector(nbits-1 downto 0);
	signal mux_s_sel : std_logic;
	signal mux_olds_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_olds_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_olds_out : std_logic_vector(nbits-1 downto 0);
	signal mux_olds_sel : std_logic;

	component Math_Div is
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
	end component;
	signal div_a : std_logic_vector(nbits-1 downto 0);
	signal div_b : std_logic_vector(nbits-1 downto 0);
	signal div_r : std_logic_vector(nbits-1 downto 0);
	signal div_q : std_logic_vector(nbits-1 downto 0);
	signal div_start : std_logic;
	signal div_clk : std_logic;
	signal div_done : std_logic;
	signal div_div_error : std_logic;

	component Math_Mul_modN is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		start : in std_logic;
		clk : in std_logic;
		product : out std_logic_vector(nbits-1 downto 0);
		done : out std_logic;
		moderror : out std_logic
	);
	end component;
	signal mul_a : std_logic_vector(nbits-1 downto 0);
	signal mul_b : std_logic_vector(nbits-1 downto 0);
	signal mul_n : std_logic_vector(nbits-1 downto 0);
	signal mul_start : std_logic;
	signal mul_clk : std_logic;
	signal mul_product : std_logic_vector(nbits-1 downto 0);
	signal mul_done : std_logic;
	signal mul_moderror : std_logic;

	component Math_Sub_modN is
	generic (
		nbits : integer := 16
	);
	port (
		borrow_in : in std_logic;
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		borrow_out : out std_logic;
		diff : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal sub_a : std_logic_vector(nbits-1 downto 0);
	signal sub_b : std_logic_vector(nbits-1 downto 0);
	signal sub_n : std_logic_vector(nbits-1 downto 0);
	signal sub_borrow_in : std_logic;
	signal sub_diff : std_logic_vector(nbits-1 downto 0);
	signal sub_borrow_out : std_logic;

	signal r_is_zero : std_logic;
	signal r_is_one : std_logic;

	type state_t is (
		SLEEP,
		INIT_REGS,
		START_DIV,
		LOAD_Q,
		START_MUL,
		LOAD_SQ_OR,
		LOAD_NS,
		LOAD_OS_R,
		LOAD_S,
		INV_DONE,
		INV_ERROR
	);
	signal state : state_t := SLEEP;
begin
	reg_n : Reg_PIPO generic map (nbits => nbits)
	port map (
		input =>  n_input,
		clk =>    n_clk,
		rst => '0',
		output => n_output
	);
	reg_r : Reg_PIPO generic map (nbits => nbits)
	port map (
		input =>  r_input,
		clk =>    r_clk,
		rst => '0',
		output => r_output
	);
	reg_oldr : Reg_PIPO generic map (nbits => nbits)
	port map (
		input =>  oldr_input,
		clk =>    oldr_clk,
		rst => '0',
		output => oldr_output
	);
	reg_q : Reg_PIPO generic map (nbits => nbits)
	port map (
		input =>  q_input,
		clk =>    q_clk,
		rst => '0',
		output => q_output
	);
	reg_s : Reg_PIPO generic map (nbits => nbits)
	port map (
		input =>  s_input,
		clk =>    s_clk,
		rst => '0',
		output => s_output
	);
	reg_olds : Reg_PIPO generic map (nbits => nbits)
	port map (
		input =>  olds_input,
		clk =>    olds_clk,
		rst => '0',
		output => olds_output
	);
	reg_sq : Reg_PIPO generic map (nbits => nbits)
	port map (
		input =>  sq_input,
		clk =>    sq_clk,
		rst => '0',
		output => sq_output
	);
	reg_next_s : Reg_PIPO generic map (nbits => nbits)
	port map (
		input =>  nexts_input,
		clk =>    nexts_clk,
		rst => '0',
		output => nexts_output
	);
	iszero_r : Math_ZeroCheck generic map (nbits => nbits-1)
	port map (
		input => iszero_r_input,
		result => iszero_r_result
	);
	mux_r : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_r_in0,
		input1 => mux_r_in1,
		sel =>    mux_r_sel,
		output => mux_r_out
	);
	mux_oldr : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_oldr_in0,
		input1 => mux_oldr_in1,
		sel =>    mux_oldr_sel,
		output => mux_oldr_out
	);
	mux_s : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_s_in0,
		input1 => mux_s_in1,
		sel =>    mux_s_sel,
		output => mux_s_out
	);
	mux_olds : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_olds_in0,
		input1 => mux_olds_in1,
		sel =>    mux_olds_sel,
		output => mux_olds_out
	);
	mul : Math_Mul_modN generic map (nbits => nbits)
	port map (
		a => mul_a,
		b => mul_b,
		n => mul_n,
		start => mul_start,
		clk => mul_clk,
		product => mul_product,
		done => mul_done,
		moderror => mul_moderror
	);
	divider : Math_Div generic map (nbits => nbits)
	port map (
		a => div_a,
		b => div_b,
		r => div_r,
		q => div_q,
		start => div_start,
		clk => div_clk,
		done => div_done,
		div_error => div_div_error
	);
	sub : Math_Sub_modN generic map (nbits => nbits)
	port map (
		borrow_in => sub_borrow_in,
		a => sub_a,
		b => sub_b,
		n => sub_n,
		borrow_out => sub_borrow_out,
		diff => sub_diff
	);
	-- ================================================
	inv_a <= s_output;
	-- Regs
	n_input <= n;
	r_input <= mux_r_out;
	oldr_input <= mux_oldr_out;
	s_input <= mux_s_out;
	olds_input <= mux_olds_out;
	q_input <= div_q;
	sq_input <= mul_product;
	nexts_input <= sub_diff(nbits-1 downto 0);
	-- Muxs
	mux_r_in0 <= a;
	mux_r_in1 <= div_r;
	mux_oldr_in0 <= n;
	mux_oldr_in1 <= r_output;
	mux_s_in0(nbits-1 downto 1) <= (others => '0');
	mux_s_in0(0) <= '1';
	mux_s_in1 <= nexts_output;
	mux_olds_in0 <= (others => '0');
	mux_olds_in1 <= s_output;
	-- iszero
	iszero_r_input <= r_output(nbits-1 downto 1);
	-- divider
	div_a <= oldr_output;
	div_b <= r_output;
	div_clk <= clk;
	-- mul
	mul_a <= q_output;
	mul_b <= s_output;
	mul_n <= n_output;
	mul_clk <= clk;
	-- sub
	sub_a <= olds_output;
	sub_b <= sq_output;
	sub_n <= n_output;
	sub_borrow_in <= '0';
	-- others	
	r_is_zero <= iszero_r_result and (not r_output(0));
	r_is_one <= iszero_r_result and r_output(0);
	-- ================================================
	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if (start = '1') then
					state <= INIT_REGS;
				else
					state <= SLEEP;
				end if;
			when INIT_REGS =>
				if (r_is_zero = '1') then
					state <= INV_ERROR;
				else
					state <= START_DIV;
				end if;
			when START_DIV =>
				if (div_done = '1') then
					if (div_div_error = '1') then
						state <= INV_ERROR;
					else
						state <= LOAD_Q;
					end if;
				else
					state <= START_DIV;
				end if;
			when LOAD_Q =>
				state <= START_MUL;
			when START_MUL =>
				if (mul_done = '1') then
					if (mul_moderror = '1') then
						state <= INV_ERROR;
					else
						state <= LOAD_SQ_OR;
					end if;
				else
					state <= START_MUL;
				end if;
			when LOAD_SQ_OR =>
				state <= LOAD_NS;
			when LOAD_NS =>
				state <= LOAD_OS_R;
			when LOAD_OS_R =>
				state <= LOAD_S;
			when LOAD_S =>
				if (r_is_one = '1') then
					state <= INV_DONE;
				else
					state <= START_DIV;
				end if;
			when INV_DONE =>
				if (start = '1') then
					state <= INV_DONE;
				else
					state <= SLEEP;
				end if;
			when INV_ERROR =>
				if (start = '1') then
					state <= INV_ERROR;
				else
					state <= SLEEP;
				end if;
			when others =>
				state <= SLEEP;
			end case;
		end if;
	end process;
	-- ================================================
	datapath : process(state)
	begin
		case state is
		when SLEEP =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '0';
			mux_oldr_sel <= '0';
			mux_s_sel <= '0';
			mux_olds_sel <= '0';
			div_start <= '0';
			mul_start <= '0';
		when INIT_REGS =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '1';
			r_clk <= '1';
			oldr_clk <= '1';
			s_clk <= '1';
			olds_clk <= '1';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '0';
			mux_oldr_sel <= '0';
			mux_s_sel <= '0';
			mux_olds_sel <= '0';
			div_start <= '0';
			mul_start <= '0';
		when START_DIV =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '1';
			mux_oldr_sel <= '1';
			mux_s_sel <= '1';
			mux_olds_sel <= '1';
			div_start <= '1';
			mul_start <= '0';
		when LOAD_Q =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '1';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '1';
			mux_oldr_sel <= '1';
			mux_s_sel <= '1';
			mux_olds_sel <= '1';
			div_start <= '1';
			mul_start <= '0';
		when START_MUL =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '1';
			mux_oldr_sel <= '1';
			mux_s_sel <= '1';
			mux_olds_sel <= '1';
			div_start <= '0';
			mul_start <= '1';
		when LOAD_SQ_OR =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '1';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '1';
			nexts_clk <= '0';
			mux_r_sel <= '1';
			mux_oldr_sel <= '1';
			mux_s_sel <= '1';
			mux_olds_sel <= '1';
			div_start <= '0';
			mul_start <= '0';
		when LOAD_NS =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '1';
			mux_r_sel <= '1';
			mux_oldr_sel <= '1';
			mux_s_sel <= '1';
			mux_olds_sel <= '1';
			div_start <= '0';
			mul_start <= '0';
		when LOAD_OS_R =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '1';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '1';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '1';
			mux_oldr_sel <= '1';
			mux_s_sel <= '1';
			mux_olds_sel <= '1';
			div_start <= '0';
			mul_start <= '0';
		when LOAD_S =>
			done <= '0';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '1';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '1';
			mux_oldr_sel <= '1';
			mux_s_sel <= '1';
			mux_olds_sel <= '1';
			div_start <= '0';
			mul_start <= '0';
		when INV_DONE =>
			done <= '1';
			inv_err <= '0';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '0';
			mux_oldr_sel <= '0';
			mux_s_sel <= '0';
			mux_olds_sel <= '0';
			div_start <= '0';
			mul_start <= '0';
		when INV_ERROR =>
			done <= '1';
			inv_err <= '1';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '0';
			mux_oldr_sel <= '0';
			mux_s_sel <= '0';
			mux_olds_sel <= '0';
			div_start <= '0';
			mul_start <= '0';
		when others =>
			done <= '0';
			inv_err <= '1';
			n_clk <= '0';
			r_clk <= '0';
			oldr_clk <= '0';
			s_clk <= '0';
			olds_clk <= '0';
			q_clk <= '0';
			sq_clk <= '0';
			nexts_clk <= '0';
			mux_r_sel <= '0';
			mux_oldr_sel <= '0';
			mux_s_sel <= '0';
			mux_olds_sel <= '0';
			div_start <= '0';
			mul_start <= '0';
		end case;
	end process;
end rtl;
