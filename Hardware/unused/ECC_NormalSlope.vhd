-- Component: ECC_NormalSlope
-- Desc: A slope calculator for different points
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity ECC_NormalSlope is
generic (
	nbits : integer := 128
);
port (
	P : in std_logic_vector((2*nbits)-1 downto 0);
	Q : in std_logic_vector((2*nbits)-1 downto 0);
	n : in std_logic_vector(nbits-1 downto 0);
	slope : out std_logic_vector(nbits-1 downto 0);
	start : in std_logic;
	clk : in std_logic;
	done : out std_logic;
	inf : out std_logic;
	moderror : out std_logic
);
end ECC_NormalSlope;

architecture rtl of ECC_NormalSlope is
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
	signal dx_input : std_logic_vector(nbits-1 downto 0);
	signal dx_clk : std_logic;
	signal dx_output : std_logic_vector(nbits-1 downto 0);
	signal dy_input : std_logic_vector(nbits-1 downto 0);
	signal dy_clk : std_logic;
	signal dy_output : std_logic_vector(nbits-1 downto 0);
	signal invdx_input : std_logic_vector(nbits-1 downto 0);
	signal invdx_clk : std_logic;
	signal invdx_output : std_logic_vector(nbits-1 downto 0);
	signal s_input : std_logic_vector(nbits-1 downto 0);
	signal s_clk : std_logic;
	signal s_output : std_logic_vector(nbits-1 downto 0);

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
	signal subdx_ci : std_logic;
	signal subdx_co : std_logic;
	signal subdx_a : std_logic_vector(nbits-1 downto 0);
	signal subdx_b : std_logic_vector(nbits-1 downto 0);
	signal subdx_n : std_logic_vector(nbits-1 downto 0);
	signal subdx_diff : std_logic_vector(nbits-1 downto 0);
	signal subdy_ci : std_logic;
	signal subdy_co : std_logic;
	signal subdy_a : std_logic_vector(nbits-1 downto 0);
	signal subdy_b : std_logic_vector(nbits-1 downto 0);
	signal subdy_n : std_logic_vector(nbits-1 downto 0);
	signal subdy_diff : std_logic_vector(nbits-1 downto 0);

	component Math_ZeroCheck is
	generic (
		nbits : integer := 8
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		result : out std_logic
	);
	end component;
	signal dx_iszero_in : std_logic_vector(nbits-1 downto 0);
	signal dx_iszero_out : std_logic;

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
	signal dx_inv_a : std_logic_vector(nbits-1 downto 0);
	signal dx_inv_n : std_logic_vector(nbits-1 downto 0);
	signal dx_inv_out : std_logic_vector(nbits-1 downto 0);
	signal dx_inv_clk : std_logic;
	signal dx_inv_start : std_logic;
	signal dx_inv_done : std_logic;
	signal dx_inv_err : std_logic;

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
	signal mul_prod : std_logic_vector(nbits-1 downto 0);
	signal mul_start : std_logic;
	signal mul_clk : std_logic;
	signal mul_done : std_logic;
	signal mul_moderror : std_logic;

	type state_t is (
		SLEEP,
		LOAD_DIFFS,
		INVERTING_DX,
		LOAD_INVDX,
		MULTIPLING,
		SLOPE_READY,
		INFINITY,
		DONE_ERROR
	);
	signal state : state_t := SLEEP;
begin
	reg_dx : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => dx_input,
		clk => dx_clk,
		rst => '0',
		output => dx_output
	);
	reg_dy : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => dy_input,
		clk => dy_clk,
		rst => '0',
		output => dy_output
	);
	reg_invdx : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => invdx_input,
		clk => invdx_clk,
		rst => '0',
		output => invdx_output
	);
	reg_s : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => s_input,
		clk => s_clk,
		rst => '0',
		output => s_output
	);
	sub_x : Math_Sub_modN generic map (nbits => nbits)
	port map (
		borrow_in => subdx_ci,
		a => subdx_a,
		b => subdx_b,
		n => subdx_n,
		borrow_out => subdx_co,
		diff => subdx_diff
	);
	sub_y : Math_Sub_modN generic map (nbits => nbits)
	port map (
		borrow_in => subdy_ci,
		a => subdy_a,
		b => subdy_b,
		n => subdy_n,
		borrow_out => subdy_co,
		diff => subdy_diff
	);
	dx_iszero : Math_ZeroCheck generic map (nbits => nbits)
	port map (
		input => dx_iszero_in,
		result => dx_iszero_out
	);
	invert_dx : Math_Invert_modN generic map (nbits => nbits)
	port map (
		a => dx_inv_a,
		n => dx_inv_n,
		inv_a => dx_inv_out,
		clk => dx_inv_clk,
		start => dx_inv_start,
		done => dx_inv_done,
		inv_err => dx_inv_err
	);
	muldxdy : Math_Mul_modN generic map (nbits => nbits)
	port map (
		a => mul_a,
		b => mul_b,
		n => mul_n,
		start => mul_start,
		clk => mul_clk,
		product => mul_prod,
		done => mul_done,
		moderror => mul_moderror
	);
	-- ================================================
	subdx_ci <= '0';
	subdx_a <= Q((2*nbits)-1 downto nbits);
	subdx_b <= P((2*nbits)-1 downto nbits);
	subdx_n <= n;
	dx_input <= subdx_diff;
	subdy_ci <= '0';
	subdy_a <= Q(nbits-1 downto 0);
	subdy_b <= P(nbits-1 downto 0);
	subdy_n <= n;
	dy_input <= subdy_diff;
	dx_iszero_in <= dx_output;
	dx_inv_a <= dx_output;
	dx_inv_n <= n;
	dx_inv_clk <= clk;
	invdx_input <= dx_inv_out;
	mul_a <= dy_output;
	mul_b <= invdx_output;
	mul_n <= n;
	mul_clk <= clk;
	s_input <= mul_prod;
	slope <= s_output;
	-- ================================================
	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if (start = '1') then
					state <= LOAD_DIFFS;
				else
					state <= SLEEP;
				end if;
			when LOAD_DIFFS =>
				if (dx_iszero_out = '1') then
					state <= INFINITY;
				else
					state <= INVERTING_DX;
				end if;
			when INVERTING_DX =>
				if (dx_inv_done = '1') then
					if (dx_inv_err = '1') then
						state <= DONE_ERROR;
					else
						state <= LOAD_INVDX;
					end if;
				else
					state <= INVERTING_DX;
				end if;
			when LOAD_INVDX =>
				state <= MULTIPLING;
			when MULTIPLING =>
				if (mul_done = '1') then
					if (mul_moderror = '1') then
						state <= DONE_ERROR;
					else
						state <= SLOPE_READY;
					end if;
				else
					state <= MULTIPLING;
				end if;
			when SLOPE_READY =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= SLOPE_READY;
				end if;
			when INFINITY =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= INFINITY;
				end if;
			when DONE_ERROR =>
				if (start = '0') then
					state <= SLEEP;
				else
					state <= DONE_ERROR;
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
		dx_clk <= '0';
		dy_clk <= '0';
		invdx_clk <= '0';
		s_clk <= '0';
		dx_inv_start <= '0';
		mul_start <= '0';
		done <= '0';
		inf <= '0';
		moderror <= '0';
	when LOAD_DIFFS =>
		dx_clk <= '1';
		dy_clk <= '1';
		invdx_clk <= '0';
		s_clk <= '0';
		dx_inv_start <= '0';
		mul_start <= '0';
		done <= '0';
		inf <= '0';
		moderror <= '0';
	when INVERTING_DX =>
		dx_clk <= '0';
		dy_clk <= '0';
		invdx_clk <= '0';
		s_clk <= '0';
		dx_inv_start <= '1';
		mul_start <= '0';
		done <= '0';
		inf <= '0';
		moderror <= '0';
	when LOAD_INVDX =>
		dx_clk <= '0';
		dy_clk <= '0';
		invdx_clk <= '1';
		s_clk <= '0';
		dx_inv_start <= '0';
		mul_start <= '0';
		done <= '0';
		inf <= '0';
		moderror <= '0';
	when MULTIPLING =>
		dx_clk <= '0';
		dy_clk <= '0';
		invdx_clk <= '0';
		s_clk <= '0';
		dx_inv_start <= '0';
		mul_start <= '1';
		done <= '0';
		inf <= '0';
		moderror <= '0';
	when SLOPE_READY =>
		dx_clk <= '0';
		dy_clk <= '0';
		invdx_clk <= '0';
		s_clk <= '1';
		dx_inv_start <= '0';
		mul_start <= '0';
		done <= '1';
		inf <= '0';
		moderror <= '0';
	when INFINITY =>
		dx_clk <= '0';
		dy_clk <= '0';
		invdx_clk <= '0';
		s_clk <= '0';
		dx_inv_start <= '0';
		mul_start <= '0';
		done <= '1';
		inf <= '1';
		moderror <= '0';
	when DONE_ERROR =>
		dx_clk <= '0';
		dy_clk <= '0';
		invdx_clk <= '0';
		s_clk <= '0';
		dx_inv_start <= '0';
		mul_start <= '0';
		done <= '1';
		inf <= '0';
		moderror <= '1';
	when others =>
		dx_clk <= '0';
		dy_clk <= '0';
		invdx_clk <= '0';
		s_clk <= '0';
		dx_inv_start <= '0';
		mul_start <= '0';
		done <= '0';
		inf <= '0';
		moderror <= '1';
	end case;
	end process;
end rtl;
