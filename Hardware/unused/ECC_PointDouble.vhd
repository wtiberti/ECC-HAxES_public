-- Component: ECC_PointDouble
-- Desc: A affine-coordinate Point Doubling component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity ECC_PointDouble is
generic (
	nbits : integer := 128
);
port (
	P : in std_logic_vector((2*nbits)-1 downto 0);
	a : in std_logic_vector(nbits-1 downto 0);
	mod_p : in std_logic_vector(nbits-1 downto 0);
	R : out std_logic_vector((2*nbits)-1 downto 0);
	start : in std_logic;
	clk : in std_logic;
	done : out std_logic;
	inf : out std_logic;
	double_error : out std_logic
);
end ECC_PointDouble;

architecture rtl of ECC_PointDouble is
	component ECC_DoubleSlope is
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
	end component;
	signal s_P : std_logic_vector((2*nbits)-1 downto 0);
	signal s_a : std_logic_vector(nbits-1 downto 0);
	signal s_modp : std_logic_vector(nbits-1 downto 0);
	signal s_slope : std_logic_vector(nbits-1 downto 0);
	signal s_start : std_logic;
	signal s_clk : std_logic;
	signal s_done : std_logic;
	signal s_inf : std_logic;
	signal s_moderror : std_logic;

	component Math_Add_modN is
	generic (
		nbits : integer := 16
	);
	port (
		carry_in : in std_logic;
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		n : in std_logic_vector(nbits-1 downto 0);
		sum : out std_logic_vector(nbits-1 downto 0);
		carry_out : out std_logic
	);
	end component;
	signal add_pxqx_ci : std_logic;
	signal add_pxqx_a : std_logic_vector(nbits-1 downto 0);
	signal add_pxqx_b : std_logic_vector(nbits-1 downto 0);
	signal add_pxqx_n : std_logic_vector(nbits-1 downto 0);
	signal add_pxqx_sum : std_logic_vector(nbits-1 downto 0);
	signal add_pxqx_co : std_logic;
	signal add_c1c3_ci : std_logic;
	signal add_c1c3_a : std_logic_vector(nbits-1 downto 0);
	signal add_c1c3_b : std_logic_vector(nbits-1 downto 0);
	signal add_c1c3_n : std_logic_vector(nbits-1 downto 0);
	signal add_c1c3_sum : std_logic_vector(nbits-1 downto 0);
	signal add_c1c3_co : std_logic;
	signal add_s3py_ci : std_logic;
	signal add_s3py_a : std_logic_vector(nbits-1 downto 0);
	signal add_s3py_b : std_logic_vector(nbits-1 downto 0);
	signal add_s3py_n : std_logic_vector(nbits-1 downto 0);
	signal add_s3py_sum : std_logic_vector(nbits-1 downto 0);
	signal add_s3py_co : std_logic;

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
	signal P_input : std_logic_vector((2*nbits)-1 downto 0);
	signal P_clk : std_logic;
	signal P_output : std_logic_vector((2*nbits)-1 downto 0);
	signal a_input : std_logic_vector(nbits-1 downto 0);
	signal a_clk : std_logic;
	signal a_output : std_logic_vector(nbits-1 downto 0);
	signal sx_input : std_logic_vector(nbits-1 downto 0);
	signal sx_clk : std_logic;
	signal sx_output : std_logic_vector(nbits-1 downto 0);
	signal c3_input : std_logic_vector(nbits-1 downto 0);
	signal c3_clk : std_logic;
	signal c3_output : std_logic_vector(nbits-1 downto 0);
	signal c1_input : std_logic_vector(nbits-1 downto 0);
	signal c1_clk : std_logic;
	signal c1_output : std_logic_vector(nbits-1 downto 0);
	signal s2_input : std_logic_vector(nbits-1 downto 0);
	signal s2_clk : std_logic;
	signal s2_output : std_logic_vector(nbits-1 downto 0);
	signal rx_input : std_logic_vector(nbits-1 downto 0);
	signal rx_clk : std_logic;
	signal rx_output : std_logic_vector(nbits-1 downto 0);
	signal ry_input : std_logic_vector(nbits-1 downto 0);
	signal ry_clk : std_logic;
	signal ry_output : std_logic_vector(nbits-1 downto 0);
	signal c1c3_input : std_logic_vector(nbits-1 downto 0);
	signal c1c3_clk : std_logic;
	signal c1c3_output : std_logic_vector(nbits-1 downto 0);
	signal s3_input : std_logic_vector(nbits-1 downto 0);
	signal s3_clk : std_logic;
	signal s3_output : std_logic_vector(nbits-1 downto 0);

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
	signal rxsub_bi : std_logic;
	signal rxsub_a : std_logic_vector(nbits-1 downto 0);
	signal rxsub_b : std_logic_vector(nbits-1 downto 0);
	signal rxsub_n : std_logic_vector(nbits-1 downto 0);
	signal rxsub_bo : std_logic;
	signal rxsub_diff : std_logic_vector(nbits-1 downto 0);
	signal rysub_bi : std_logic;
	signal rysub_a : std_logic_vector(nbits-1 downto 0);
	signal rysub_b : std_logic_vector(nbits-1 downto 0);
	signal rysub_n : std_logic_vector(nbits-1 downto 0);
	signal rysub_bo : std_logic;
	signal rysub_diff : std_logic_vector(nbits-1 downto 0);

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
	signal muls2_a : std_logic_vector(nbits-1 downto 0);
	signal muls2_b : std_logic_vector(nbits-1 downto 0);
	signal muls2_n : std_logic_vector(nbits-1 downto 0);
	signal muls2_start : std_logic;
	signal muls2_clk :  std_logic;
	signal muls2_product : std_logic_vector(nbits-1 downto 0);
	signal muls2_done : std_logic;
	signal muls2_moderror : std_logic;
	signal mulsxc3_a : std_logic_vector(nbits-1 downto 0);
	signal mulsxc3_b : std_logic_vector(nbits-1 downto 0);
	signal mulsxc3_n : std_logic_vector(nbits-1 downto 0);
	signal mulsxc3_start : std_logic;
	signal mulsxc3_clk :  std_logic;
	signal mulsxc3_product : std_logic_vector(nbits-1 downto 0);
	signal mulsxc3_done : std_logic;
	signal mulsxc3_moderror : std_logic;
	signal mulsc1_a : std_logic_vector(nbits-1 downto 0);
	signal mulsc1_b : std_logic_vector(nbits-1 downto 0);
	signal mulsc1_n : std_logic_vector(nbits-1 downto 0);
	signal mulsc1_start : std_logic;
	signal mulsc1_clk :  std_logic;
	signal mulsc1_product : std_logic_vector(nbits-1 downto 0);
	signal mulsc1_done : std_logic;
	signal mulsc1_moderror : std_logic;
	signal muls3_a : std_logic_vector(nbits-1 downto 0);
	signal muls3_b : std_logic_vector(nbits-1 downto 0);
	signal muls3_n : std_logic_vector(nbits-1 downto 0);
	signal muls3_start : std_logic;
	signal muls3_clk :  std_logic;
	signal muls3_product : std_logic_vector(nbits-1 downto 0);
	signal muls3_done : std_logic;
	signal muls3_moderror : std_logic;

	type state_t is (
		SLEEP,
		LOAD_PQ,
		COMPUTE_S_AND_LOAD_SUMX,
		COMPUTE_S2_C1_C3,
		LOAD_S2_C1_C3,
		LOAD_RX_C1C3_AND_COMPUTE_S3,
		LOAD_S3,
		LOAD_RY,
		PA_DONE,
		DONE_INF,
		DONE_ERROR
	);
	signal state : state_t := SLEEP;
	signal debug : integer := 0;

begin
	slopeCalculator : ECC_DoubleSlope generic map (nbits => nbits)
	port map (
		P => s_P,
		a => s_a,
		mod_p => s_modp,
		slope => s_slope,
		start => s_start,
		clk => s_clk,
		done => s_done,
		inf => s_inf,
		moderror => s_moderror
	);
	-- Q.x + P.x - TODO - we can shift since P=Q
	adder_pxqx : Math_Add_modN generic map (nbits => nbits)
	port map (
		carry_in => add_pxqx_ci,
		a => add_pxqx_a,
		b => add_pxqx_b,
		n => add_pxqx_n,
		sum => add_pxqx_sum,
		carry_out => add_pxqx_co
	);
	-- s*P.x + s(Q.x + P.x)
	adder_c1c3 : Math_Add_modN generic map (nbits => nbits)
	port map (
		carry_in => add_c1c3_ci,
		a => add_c1c3_a,
		b => add_c1c3_b,
		n => add_c1c3_n,
		sum => add_c1c3_sum,
		carry_out => add_c1c3_co
	);
	adder_s3py : Math_Add_modN generic map (nbits => nbits)
	port map (
		carry_in => add_s3py_ci,
		a => add_s3py_a,
		b => add_s3py_b,
		n => add_s3py_n,
		sum => add_s3py_sum,
		carry_out => add_s3py_co
	);
	-- reg for Px + Q.x
	reg_sum_x : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => sx_input,
		clk => sx_clk,
		rst => '0',
		output => sx_output
	);
	-- reg for c3 = s * (Q.x + P.x)
	reg_c3 : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => c3_input,
		clk => c3_clk,
		rst => '0',
		output => c3_output
	);
	-- reg for c1 = s * P.x
	reg_c1 : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => c1_input,
		clk => c1_clk,
		rst => '0',
		output => c1_output
	);
	-- reg for s^2
	reg_s2 : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => s2_input,
		clk => s2_clk,
		rst => '0',
		output => s2_output
	);
	-- reg for s^3
	reg_s3 : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => s3_input,
		clk => s3_clk,
		rst => '0',
		output => s3_output
	);
	-- reg for R.x
	reg_rx : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => rx_input,
		clk => rx_clk,
		rst => '0',
		output => rx_output
	);
	-- reg for R.y
	reg_ry : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => ry_input,
		clk => ry_clk,
		rst => '0',
		output => ry_output
	);
	-- reg for c1+c3
	reg_c1c3 : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => c1c3_input,
		clk => c1c3_clk,
		rst => '0',
		output => c1c3_output
	);
	-- reg for P
	reg_P : Reg_PIPO generic map (nbits => 2*nbits)
	port map (
		input => P_input,
		clk => P_clk,
		rst => '0',
		output => P_output
	);
	-- reg for a
	reg_a : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => a_input,
		clk => a_clk,
		rst => '0',
		output => a_output
	);
	-- Sub for s^2 - (Q.x + P.x)
	sub_rx : Math_Sub_modN generic map (nbits => nbits)
	port map (
		borrow_in => rxsub_bi,
		a => rxsub_a,
		b => rxsub_b,
		n => rxsub_n,
		borrow_out => rxsub_bo,
		diff => rxsub_diff
	);
	-- Sub for (s^3 + P.y) - c1c3
	sub_ry : Math_Sub_modN generic map (nbits => nbits)
	port map (
		borrow_in => rysub_bi,
		a => rysub_a,
		b => rysub_b,
		n => rysub_n,
		borrow_out => rysub_bo,
		diff => rysub_diff
	);
	-- Mul for s * s = s^2
	mul_s2 : Math_Mul_modN generic map (nbits => nbits)
	port map (
		a => muls2_a,
		b => muls2_b,
		n => muls2_n,
		start => muls2_start,
		clk => muls2_clk,
		product => muls2_product,
		done => muls2_done,
		moderror => muls2_moderror
	);
	-- Mul for (Q.x + P.x) * s
	mul_sxc3 : Math_Mul_modN generic map (nbits => nbits)
	port map (
		a => mulsxc3_a,
		b => mulsxc3_b,
		n => mulsxc3_n,
		start => mulsxc3_start,
		clk => mulsxc3_clk,
		product => mulsxc3_product,
		done => mulsxc3_done,
		moderror => mulsxc3_moderror
	);
	-- Mul for s * P.x
	mul_sc1 : Math_Mul_modN generic map (nbits => nbits)
	port map (
		a => mulsc1_a,
		b => mulsc1_b,
		n => mulsc1_n,
		start => mulsc1_start,
		clk => mulsc1_clk,
		product => mulsc1_product,
		done => mulsc1_done,
		moderror => mulsc1_moderror
	);
	-- Mul for s * s^2
	mul_s3 : Math_Mul_modN generic map (nbits => nbits)
	port map (
		a => muls3_a,
		b => muls3_b,
		n => muls3_n,
		start => muls3_start,
		clk => muls3_clk,
		product => muls3_product,
		done => muls3_done,
		moderror => muls3_moderror
	);
	-- ================================================
	add_pxqx_ci <= '0';
	add_pxqx_a <= P_output((2*nbits)-1 downto nbits);
	add_pxqx_b <= P_output((2*nbits)-1 downto nbits);
	add_pxqx_n <= mod_p;
	add_c1c3_ci <= '0';
	add_c1c3_a <= c1_output;
	add_c1c3_b <= c3_output;
	add_c1c3_n <= mod_p;
	add_s3py_ci <= '0';
	add_s3py_a <= P_output(nbits-1 downto 0);
	add_s3py_b <= s3_output;
	add_s3py_n <= mod_p;
	s_P <= P_output;
	s_a <= a_output;
	s_modp <= mod_p;
	s_clk <= clk;
	P_input <= P;
	a_input <= a;
	sx_input <= add_pxqx_sum;
	c3_input <= mulsxc3_product;
	c1_input <= mulsc1_product;
	s2_input <= muls2_product;
	rx_input <= rxsub_diff;
	ry_input <= rysub_diff;
	s3_input <= muls3_product;
	c1c3_input <= add_c1c3_sum;
	rxsub_bi <= '0';
	rxsub_a <= s2_output;
	rxsub_b <= sx_output;
	rxsub_n <= mod_p;
	rysub_bi <= '0';
	rysub_a <= c1c3_output;
	rysub_b <= add_s3py_sum;
	rysub_n <= mod_p;
	muls2_a <= s_slope;
	muls2_b <= s_slope;
	muls2_n <= mod_p;
	muls2_clk <= clk;
	muls3_a <= s2_output;
	muls3_b <= s_slope;
	muls3_n <= mod_p;
	muls3_clk <= clk;
	mulsxc3_a <= sx_output;
	mulsxc3_b <= s_slope;
	mulsxc3_n <= mod_p;
	mulsxc3_clk <= clk;
	mulsc1_a <= P_output((2*nbits)-1 downto nbits);
	mulsc1_b <= s_slope;
	mulsc1_n <= mod_p;
	mulsc1_clk <= clk;
	R((2*nbits)-1 downto nbits) <= rx_output;
	R(nbits-1 downto 0) <= ry_output;
	-- ================================================
	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if (start = '1') then
					state <= LOAD_PQ;
				else
					state <= SLEEP;
				end if;
			when LOAD_PQ =>
				state <= COMPUTE_S_AND_LOAD_SUMX;
			when COMPUTE_S_AND_LOAD_SUMX =>
				if (s_done = '1') then
					if (s_moderror = '1') then
						state <= DONE_ERROR;
					elsif (s_inf = '1') then
						state <= DONE_INF;
					else
						state <= COMPUTE_S2_C1_C3;
					end if;
				else
					state <= COMPUTE_S_AND_LOAD_SUMX;
				end if;
			when COMPUTE_S2_C1_C3 =>
				if (muls2_done = '1' and mulsxc3_done = '1' and mulsc1_done = '1') then
					if (muls2_moderror = '1' or mulsxc3_moderror = '1' or mulsc1_moderror = '1') then
						state <= DONE_ERROR;
					else
						state <= LOAD_S2_C1_C3;
					end if;
				else
					state <= COMPUTE_S2_C1_C3;
				end if;
			when LOAD_S2_C1_C3 =>
				state <= LOAD_RX_C1C3_AND_COMPUTE_S3;
			when LOAD_RX_C1C3_AND_COMPUTE_S3 =>
				if (muls3_done = '1') then
					if (muls2_moderror = '1') then
						state <= DONE_ERROR;
					else
						state <= LOAD_S3;
					end if;
				else
					state <= LOAD_RX_C1C3_AND_COMPUTE_S3;
				end if;
			when LOAD_S3 =>
				state <= LOAD_RY;
			when LOAD_RY =>
				state <= PA_DONE;
			when PA_DONE =>
				if (start = '1') then
					state <= PA_DONE;
				else
					state <= SLEEP;
				end if;
			when DONE_INF =>
				if (start = '1') then
					state <= DONE_INF;
				else
					state <= SLEEP;
				end if;
			when DONE_ERROR =>
				if (start = '1') then
					state <= DONE_ERROR;
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
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '0';
			inf <= '0';
			double_error <= '0';
			debug <= 0;
		when LOAD_PQ =>
			P_clk <= '1';
			a_clk <= '1';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '0';
			inf <= '0';
			double_error <= '0';
			debug <= 1;
		when COMPUTE_S_AND_LOAD_SUMX =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '1';
			sx_clk <= '1';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '0';
			inf <= '0';
			double_error <= '0';
			debug <= 2;
		when COMPUTE_S2_C1_C3 =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '1';
			mulsc1_start <= '1';
			mulsxc3_start <= '1';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '0';
			inf <= '0';
			double_error <= '0';
			debug <= 3;
		when LOAD_S2_C1_C3 =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '1';
			c3_clk <= '1';
			s2_clk <= '1';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '0';
			inf <= '0';
			double_error <= '0';
			debug <= 4;
		when LOAD_RX_C1C3_AND_COMPUTE_S3 =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '1';
			muls3_start <= '1';
			s3_clk <= '0';
			rx_clk <= '1';
			ry_clk <= '0';
			done <= '0';
			inf <= '0';
			double_error <= '0';
			debug <= 5;
		when LOAD_S3 =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '1';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '0';
			inf <= '0';
			double_error <= '0';
			debug <= 6;
		when LOAD_RY =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '1';
			done <= '0';
			inf <= '0';
			double_error <= '0';
			debug <= 7;
		when PA_DONE =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '1';
			inf <= '0';
			double_error <= '0';
			debug <= 8;
		when DONE_INF =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '1';
			inf <= '1';
			double_error <= '0';
			debug <= 129;
		when DONE_ERROR =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '1';
			inf <= '0';
			double_error <= '1';
			debug <= 130;
		when others =>
			P_clk <= '0';
			a_clk <= '0';
			s_start <= '0';
			sx_clk <= '0';
			muls2_start <= '0';
			mulsc1_start <= '0';
			mulsxc3_start <= '0';
			c1_clk <= '0';
			c3_clk <= '0';
			s2_clk <= '0';
			c1c3_clk <= '0';
			muls3_start <= '0';
			s3_clk <= '0';
			rx_clk <= '0';
			ry_clk <= '0';
			done <= '0';
			inf <= '0';
			double_error <= '1';
			debug <= 128;
		end case;
	end process;
end rtl;
