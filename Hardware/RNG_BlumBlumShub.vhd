-- Component: RNG_BlumBlumShub
-- Desc: An implementantion on the BlumBlumShub CSPRNG
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity RNG_BlumBlumShub is
generic (
	nbits : integer := 192
);
port (
	seed : in std_logic_vector(nbits-1 downto 0);
	n : in std_logic_vector(nbits-1 downto 0);
	new_run : in std_logic;
	clk : in std_logic;
	start : in std_logic;
	done : out std_logic;
	moderror : out std_logic;
	result : out std_logic_vector(nbits-1 downto 0)
);
end RNG_BlumBlumShub;

architecture rtl of RNG_BlumBlumShub is
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
	signal mul_a : std_logic_vector(15 downto 0);
	signal mul_b : std_logic_vector(15 downto 0);
	signal mul_n : std_logic_vector(15 downto 0);
	signal mul_start : std_logic;
	signal mul_clk : std_logic;
	signal mul_product : std_logic_vector(15 downto 0);
	signal mul_done : std_logic;
	signal mul_moderror : std_logic;

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
	signal mux_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_sel : std_logic;
	signal mux_out : std_logic_vector(nbits-1 downto 0);

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
	signal reg_x_out : std_logic_vector(nbits-1 downto 0);
	signal reg_x_clk : std_logic;
	signal reg_n_in : std_logic_vector(nbits-1 downto 0);
	signal reg_n_out : std_logic_vector(nbits-1 downto 0);
	signal reg_n_clk : std_logic;
	signal reg_x2_in : std_logic_vector(nbits-1 downto 0);
	signal reg_x2_out : std_logic_vector(nbits-1 downto 0);
	signal reg_x2_clk : std_logic;

	signal mux_sel_enable : std_logic;
	signal x_clk_enable : std_logic;
	signal n_clk_enable : std_logic;

	type state_t is (
		SLEEP,
		LOAD_X_N,
		START_MUL,
		LOAD_X2,
		RNG_DONE,
		DONE_ERROR
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
	reg_n : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_n_in,
		clk => reg_n_clk,
		rst => '0',
		output => reg_n_out
	);
	reg_x2 : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_x2_in,
		clk => reg_x2_clk,
		rst => '0',
		output => reg_x2_out
	);
	mux_x2 : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_in0,
		input1 => mux_in1,
		sel => mux_sel,
		output => mux_out
	);
	multiplier : Math_Mul_modN generic map (nbits => nbits)
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
	-- ================================================
	reg_x_in <= seed;
	reg_x_clk <= new_run and x_clk_enable;
	reg_n_in <= n;
	reg_n_clk <= new_run and n_clk_enable;
	reg_x2_in <= mux_out;
	mul_a <= reg_x_out;
	mul_b <= reg_x2_out;
	mul_n <= reg_n_out;
	mul_clk <= clk;
	result <= reg_x2_out;
	mux_in0 <= mul_product;
	mux_in1(nbits-1 downto 1) <= (others => '0');
	mux_in1(0) <= '1';
	mux_sel <= new_run and mux_sel_enable;
	-- ================================================
	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if start = '1' then
					state <= LOAD_X_N;
				else
					state <= SLEEP;
				end if;
			when LOAD_X_N =>
				state <= START_MUL;
			when START_MUL =>
				if (mul_done = '1') then
					state <= LOAD_X2;
				else
					state <= START_MUL;
				end if;
			when LOAD_X2 =>
				state <= RNG_DONE;
			when RNG_DONE =>
				if start = '1' then
					state <= RNG_DONE;
				else
					state <= SLEEP;
				end if;
			when DONE_ERROR =>
				if start = '1' then
					state <= DONE_ERROR;
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
			mul_start <= '0';
			reg_x2_clk <= '0';
			mux_sel_enable <= '1';
			x_clk_enable <= '0';
			n_clk_enable <= '0';
			done <= '0';
			moderror <= '0';
		when LOAD_X_N =>
			mul_start <= '0';
			reg_x2_clk <= '1';
			mux_sel_enable <= '1';
			x_clk_enable <= '1';
			n_clk_enable <= '1';
			done <= '0';
			moderror <= '0';
		when START_MUL =>
			mul_start <= '1';
			reg_x2_clk <= '0';
			mux_sel_enable <= '0';
			x_clk_enable <= '0';
			n_clk_enable <= '0';
			done <= '0';
			moderror <= '0';
		when LOAD_X2 =>
			mul_start <= '0';
			reg_x2_clk <= '1';
			mux_sel_enable <= '0';
			x_clk_enable <= '0';
			n_clk_enable <= '0';
			done <= '0';
			moderror <= '0';
		when RNG_DONE =>
			mul_start <= '0';
			reg_x2_clk <= '0';
			mux_sel_enable <= '0';
			x_clk_enable <= '0';
			n_clk_enable <= '0';
			done <= '1';
			moderror <= '0';
		when DONE_ERROR =>
			mul_start <= '0';
			reg_x2_clk <= '0';
			mux_sel_enable <= '0';
			x_clk_enable <= '0';
			n_clk_enable <= '0';
			done <= '1';
			moderror <= '1';
		when others =>
			mul_start <= '0';
			reg_x2_clk <= '0';
			mux_sel_enable <= '0';
			x_clk_enable <= '0';
			n_clk_enable <= '0';
			done <= '0';
			moderror <= '0';
		end case;
	end process;

end rtl;
