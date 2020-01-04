-- Component: ECC_DoubleSlope
-- Desc: A slope calculator for affine coordinates point doubling ((3*x^2+a)/(2y))
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity ECC_DoubleSlope is
generic (
	nbits : integer := 128
);
port (
	P : in std_logic_vector((2*nbits)-1 downto 0);
	a : in std_logic_vector(nbits-1 downto 0);
	mod_p : in std_logic_vector(nbits-1 downto 0);
	slope : out std_logic_vector(nbits-1 downto 0);
	start : in std_logic;
	clk : in std_logic;
	done : out std_logic;
	inf : out std_logic;
	moderror : out std_logic
);
end ECC_DoubleSlope;

architecture rtl of ECC_DoubleSlope is
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
	signal reg_x_in : std_logic_vector(nbits-1 downto 0);
	signal reg_x_clk : std_logic;
	signal reg_x_out : std_logic_vector(nbits-1 downto 0);
	signal reg_a_in : std_logic_vector(nbits-1 downto 0);
	signal reg_a_clk : std_logic;
	signal reg_a_out : std_logic_vector(nbits-1 downto 0);
	signal reg_n_in : std_logic_vector(nbits-1 downto 0);
	signal reg_n_clk : std_logic;
	signal reg_n_out : std_logic_vector(nbits-1 downto 0);
	signal reg_x2_in : std_logic_vector((2*nbits)-1 downto 0);
	signal reg_x2_clk : std_logic;
	signal reg_x2_out : std_logic_vector((2*nbits)-1 downto 0);
	signal reg_purenum_in : std_logic_vector((2*nbits)+1 downto 0);
	signal reg_purenum_clk : std_logic;
	signal reg_purenum_out : std_logic_vector((2*nbits)+1 downto 0);
	signal reg_y_in : std_logic_vector(nbits-1 downto 0);
	signal reg_y_clk : std_logic;
	signal reg_y_out : std_logic_vector(nbits-1 downto 0);
	signal reg_2y_in : std_logic_vector(nbits-1 downto 0);
	signal reg_2y_clk : std_logic;
	signal reg_2y_out : std_logic_vector(nbits-1 downto 0);
	signal reg_inv2y_in : std_logic_vector(nbits-1 downto 0);
	signal reg_inv2y_clk : std_logic;
	signal reg_inv2y_out : std_logic_vector(nbits-1 downto 0);
	signal reg_s_in : std_logic_vector(nbits-1 downto 0);
	signal reg_s_clk : std_logic;
	signal reg_s_out : std_logic_vector(nbits-1 downto 0);

	component Math_Mul is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		product : out std_logic_vector((2*nbits)-1 downto 0)
	);
	end component;
	signal mul_x2_a : std_logic_vector(nbits-1 downto 0);
	signal mul_x2_b : std_logic_vector(nbits-1 downto 0);
	signal mul_x2_prod : std_logic_vector((2*nbits)-1 downto 0);

	component Math_ZeroCheck is
	generic (
		nbits : integer := 8
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		result : out std_logic
	);
	end component;
	signal zerocheck_y_in : std_logic_vector(nbits-1 downto 0);
	signal is_y_zero : std_logic;


	component Math_Invert_modN is
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
	end component;
	signal inv2y_a : std_logic_vector(nbits-1 downto 0);
	signal inv2y_n : std_logic_vector(nbits-1 downto 0);
	signal inv2y_result : std_logic_vector(nbits-1 downto 0);
	signal inv2y_clk : std_logic;
	signal inv2y_start : std_logic;
	signal inv2y_done : std_logic;
	signal inv2y_inv_err : std_logic;

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
	signal mod2y_a : std_logic_vector(nbits downto 0);
	signal mod2y_p : std_logic_vector(nbits downto 0);
	signal mod2y_r : std_logic_vector(nbits downto 0);
	signal mod2y_start : std_logic;
	signal mod2y_clk : std_logic;
	signal mod2y_done : std_logic;
	signal mod2y_div_error : std_logic;

	component Math_Add is
	generic (
		nbits : integer := 16
	);
	port (
		carryin : in std_logic;
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		sum : out std_logic_vector(nbits-1 downto 0);
		carryout : out std_logic
	);
	end component;
	signal add_x2a_carryin : std_logic;
	signal add_x2a_a : std_logic_vector((2*nbits)-1 downto 0);
	signal add_x2a_b : std_logic_vector((2*nbits)-1 downto 0);
	signal add_x2a_sum : std_logic_vector((2*nbits)-1 downto 0);
	signal add_x2a_carryout : std_logic;
	signal add_num_carryin : std_logic;
	signal add_num_a : std_logic_vector(2*nbits downto 0);
	signal add_num_b : std_logic_vector(2*nbits downto 0);
	signal add_num_sum : std_logic_vector(2*nbits downto 0);
	signal add_num_carryout : std_logic;

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
	signal lastmul_a : std_logic_vector((2*nbits)+1 downto 0);
	signal lastmul_b : std_logic_vector((2*nbits)+1 downto 0);
	signal lastmul_n : std_logic_vector((2*nbits)+1 downto 0);
	signal lastmul_start : std_logic;
	signal lastmul_clk : std_logic;
	signal lastmul_product : std_logic_vector((2*nbits)+1 downto 0);
	signal lastmul_done : std_logic;
	signal lastmul_moderror : std_logic;

	type state_t is (
		SLEEP,
		LOAD_XYAN,
		MOD_START,
		LOAD_X22Y,
		INV_START,
		LOAD_INV_PN,
		S_MUL_START,
		LOAD_S,
		SLOPE_DONE,
		SLOPE_INF,
		SLOPE_ERROR
	);
	signal state : state_t := SLEEP;
begin
	reg_x : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_x_in,
		clk => reg_x_clk,
		rst => '0',
		output => reg_x_out
	);
	reg_a : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_a_in,
		clk => reg_a_clk,
		rst => '0',
		output => reg_a_out
	);
	reg_n : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_n_in,
		clk => reg_n_clk,
		rst => '0',
		output => reg_n_out
	);
	reg_s : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_s_in,
		clk => reg_s_clk,
		rst => '0',
		output => reg_s_out
	);
	reg_x2 : Reg_PIPO generic map (nbits => 2*nbits)
	port map (
		input => reg_x2_in,
		clk => reg_x2_clk,
		rst => '0',
		output => reg_x2_out
	);
	reg_purenum : Reg_PIPO generic map (nbits => 2*nbits+2)
	port map (
		input => reg_purenum_in,
		clk => reg_purenum_clk,
		rst => '0',
		output => reg_purenum_out
	);
	reg_y : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_y_in,
		clk => reg_y_clk,
		rst => '0',
		output => reg_y_out
	);
	reg_2y : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_2y_in,
		clk => reg_2y_clk,
		rst => '0',
		output => reg_2y_out
	);
	reg_inv2y : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_inv2y_in,
		clk => reg_inv2y_clk,
		rst => '0',
		output => reg_inv2y_out
	);

	zerocheck_y : Math_ZeroCheck generic map (nbits => nbits)
	port map (
		input => zerocheck_y_in,
		result => is_y_zero
	);

	mul_x2 : Math_Mul generic map (nbits => nbits)
	port map (
		a => mul_x2_a,
		b => mul_x2_b,
		product => mul_x2_prod
	);

	inv_2y : Math_Invert_modN generic map (nbits => nbits)
	port map (
		a => inv2y_a,
		n => inv2y_n,
		inv_a => inv2y_result,
		clk => inv2y_clk,
		start => inv2y_start,
		done => inv2y_done,
		inv_err => inv2y_inv_err
	);

	mod_2y : Math_Mod generic map (nbits => nbits+1)
	port map (
		a => mod2y_a,
		p => mod2y_p,
		r => mod2y_r,
		start => mod2y_start,
		clk => mod2y_clk,
		done => mod2y_done,
		div_error => mod2y_div_error
	);

	add_x2a : Math_Add generic map (nbits => 2*nbits)
	port map (
		carryin => add_x2a_carryin,
		a => add_x2a_a,
		b => add_x2a_b,
		sum => add_x2a_sum,
		carryout => add_x2a_carryout
	);
	add_num : Math_Add generic map (nbits => 2*nbits+1)
	port map (
		carryin => add_num_carryin,
		a => add_num_a,
		b => add_num_b,
		sum => add_num_sum,
		carryout => add_num_carryout
	);

	lastmul : Math_Mul_modN generic map (nbits => 2*nbits+2)
	port map (
		a => lastmul_a,
		b => lastmul_b,
		n => lastmul_n,
		start => lastmul_start,
		clk => lastmul_clk,
		product => lastmul_product,
		done => lastmul_done,
		moderror => lastmul_moderror
	);
	-- ================================================
	reg_x_in <= P((2*nbits)-1 downto nbits);
	reg_a_in <= a;
	reg_n_in <= mod_p;
	reg_x2_in <= mul_x2_prod;
	reg_purenum_in <= add_num_carryout & add_num_sum;
	reg_y_in <= P(nbits-1 downto 0);
	reg_2y_in <= mod2y_r(nbits-1 downto 0);
	reg_inv2y_in <= inv2y_result;
	reg_s_in <= lastmul_product(nbits-1 downto 0);
	zerocheck_y_in <= reg_y_out;
	mul_x2_a <= reg_x_out;
	mul_x2_b <= reg_x_out;
	mod2y_a <= reg_y_out & '0'; -- shifted
	mod2y_p <= '0' & reg_n_out;
	mod2y_clk <= clk;
	inv2y_a <= reg_2y_out;
	inv2y_n <= reg_n_out;
	inv2y_clk <= clk;
	--
	add_x2a_carryin <= '0';
	add_x2a_a(nbits-1 downto 0) <= reg_a_out;
	add_x2a_a((2*nbits)-1 downto 0) <= (others => '0');
	add_x2a_b <= reg_x2_out;
	add_num_carryin <= '0';
	add_num_a(2*nbits) <= add_x2a_carryout;
	add_num_a((2*nbits)-1 downto 0) <= add_x2a_sum;
	add_num_b((2*nbits) downto 1) <= reg_x2_out; -- shift
	add_num_b(0) <= '0';
	lastmul_a <= reg_purenum_out;
	lastmul_b(nbits-1 downto 0) <= inv2y_result;
	lastmul_b((2*nbits)+1 downto nbits) <= (others => '0');
	lastmul_n(nbits-1 downto 0) <= reg_n_out;
	lastmul_n((2*nbits)+1 downto nbits) <= (others => '0');
	lastmul_clk <= clk;
	--
	slope <= reg_s_out;
	-- ================================================
	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if (start = '1') then
					state <= LOAD_XYAN;
				else
					state <= SLEEP;
				end if;
			when LOAD_XYAN =>
				if (is_y_zero = '1') then
					state <= SLOPE_INF;
				else
					state <= MOD_START;
				end if;
			when MOD_START =>
				if (mod2y_done = '1') then
					if (mod2y_div_error = '1') then
						state <= SLOPE_ERROR;
					else
						state <= LOAD_X22Y;
					end if;
				else
					state <= MOD_START;
				end if;
			when LOAD_X22Y =>
				state <= INV_START;
			when INV_START =>
				if (inv2y_done = '1') then
					if (inv2y_inv_err = '1') then
						state <= SLOPE_ERROR;
					else
						state <= LOAD_INV_PN;
					end if;
				else
					state <= INV_START;
				end if;
			when LOAD_INV_PN =>
				state <= S_MUL_START;
			when S_MUL_START =>
				if (lastmul_done = '1') then
					if (lastmul_moderror = '1') then
						state <= SLOPE_ERROR;
					else
						state <= LOAD_S;
					end if;
				else
					state <= S_MUL_START;
				end if;
			when LOAD_S =>
				state <= SLOPE_DONE;
			when SLOPE_DONE =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= SLOPE_DONE;
				end if;
			when SLOPE_INF =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= SLOPE_INF;
				end if;
			when SLOPE_ERROR =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= SLOPE_ERROR;
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
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '0';
			inf <= '0';
			moderror <= '0';
		when LOAD_XYAN =>
			reg_x_clk <= '1';
			reg_a_clk <= '1';
			reg_n_clk <= '1';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '1';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '0';
			inf <= '0';
			moderror <= '0';
		when MOD_START =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '1';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '0';
			inf <= '0';
			moderror <= '0';
		when LOAD_X22Y =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '1';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '1';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '0';
			inf <= '0';
			moderror <= '0';
		when INV_START =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '1';
			lastmul_start <= '0';
			done <= '0';
			inf <= '0';
			moderror <= '0';
		when LOAD_INV_PN =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '1';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '1';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '0';
			inf <= '0';
			moderror <= '0';
		when S_MUL_START =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '1';
			done <= '0';
			inf <= '0';
			moderror <= '0';
		when LOAD_S =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '1';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '0';
			inf <= '0';
			moderror <= '0';
		when SLOPE_DONE =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '1';
			inf <= '0';
			moderror <= '0';
		when SLOPE_INF =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '1';
			inf <= '1';
			moderror <= '0';
		when SLOPE_ERROR =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '1';
			inf <= '0';
			moderror <= '1';
		when others =>
			reg_x_clk <= '0';
			reg_a_clk <= '0';
			reg_n_clk <= '0';
			reg_x2_clk <= '0';
			reg_purenum_clk <= '0';
			reg_y_clk <= '0';
			reg_2y_clk <= '0';
			reg_inv2y_clk <= '0';
			reg_s_clk <= '0';
			mod2y_start <= '0';
			inv2y_start <= '0';
			lastmul_start <= '0';
			done <= '0';
			inf <= '0';
			moderror <= '1';
		end case;
	end process;
end rtl;
