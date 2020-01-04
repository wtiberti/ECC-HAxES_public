-- Component: Math_AddSub_modN
-- Desc: Adder/Subtractor mod N
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_AddSub_modN is
generic (
	nbits : integer := 16
);
port (
	cbi : in std_logic;
	a : in std_logic_vector(nbits-1 downto 0);
	b : in std_logic_vector(nbits-1 downto 0);
	n : in std_logic_vector(nbits-1 downto 0);
	op : in std_logic; -- 0 = add, 1 = sub
	start : in std_logic;
	clk : in std_logic;
	result : out std_logic_vector(nbits-1 downto 0);
	done : out std_logic
);
end Math_AddSub_modN;

architecture rtl of Math_AddSub_modN is
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
	signal reg_res_input : std_logic_vector(nbits downto 0);
	signal reg_res_clk : std_logic;
	signal reg_res_output : std_logic_vector(nbits downto 0);

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
	signal rfas_a : std_logic_vector(nbits downto 0);
	signal rfas_b : std_logic_vector(nbits downto 0);
	signal rfas_y : std_logic_vector(nbits downto 0);
	signal rfas_op : std_logic;
	signal rfas_cbo : std_logic;

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
	signal mux_a_input0 : std_logic_vector(nbits downto 0);
	signal mux_a_input1 : std_logic_vector(nbits downto 0);
	signal mux_a_output : std_logic_vector(nbits downto 0);
	signal mux_a_sel : std_logic;
	signal mux_b_input0 : std_logic_vector(nbits downto 0);
	signal mux_b_input1 : std_logic_vector(nbits downto 0);
	signal mux_b_output : std_logic_vector(nbits downto 0);
	signal mux_b_sel : std_logic;

	signal enable : std_logic;
	signal localop : std_logic;

	type state_t is (
		SLEEP,
		PRELOAD_RESULT,
		SETMUX_PLUS_P,
		SETMUX_MINUS_P,
		LOAD_PLUS_P,
		LOAD_MINUS_P,
		COMPLETED
	);
	signal state : state_t := SLEEP;
begin
	rfas : Math_RippleFAS generic map (nbits => nbits+1)
	port map (
		a => rfas_a,
		b => rfas_b,
		op => rfas_op,
		cbi => cbi,
		y => rfas_y,
		cbo => rfas_cbo
	);

	mux_a : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_a_input0,
		input1 => mux_a_input1,
		sel => mux_a_sel,
		output => mux_a_output
	);

	mux_b : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_b_input0,
		input1 => mux_b_input1,
		sel => mux_b_sel,
		output => mux_b_output
	);

	reg_result : Reg_PIPO generic map (nbits => nbits+1)
	port map (
		input => reg_res_input,
		clk => reg_res_clk,
		rst => '0',
		output => reg_res_output
	);
	-- ================================================
	mux_a_input0 <= '0' & a;
	mux_a_input1 <= reg_res_output;
	mux_b_input0 <= '0' & b;
	mux_b_input1 <= '0' & n;
	rfas_a <= mux_a_output;
	rfas_b <= mux_b_output;
	rfas_op <= (op and not enable) or (localop and enable);
	reg_res_input <= rfas_y;
	result <= reg_res_output(nbits-1 downto 0);
	-- ================================================
	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if (start = '1') then
					state <= PRELOAD_RESULT;
				else
					state <= SLEEP;
				end if;
			when PRELOAD_RESULT =>
				if (op = '1') then
					if (rfas_cbo = '1') then
						-- A-B, A < B
						state <= SETMUX_PLUS_P;
					else
						-- A-B, A >= B
						state <= COMPLETED;
					end if;
				else
					state <= SETMUX_MINUS_P;
				end if;
			when SETMUX_PLUS_P =>
				state <= LOAD_PLUS_P;
			when SETMUX_MINUS_P =>
				if (rfas_cbo = '1') then
					-- A+B < P
					state <= COMPLETED;
				else
					-- A+B >= P
					state <= LOAD_MINUS_P;
				end if;
			when LOAD_PLUS_P =>
				state <= COMPLETED;
			when LOAD_MINUS_P =>
				state <= COMPLETED;
			when COMPLETED =>
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
			mux_a_sel <= '0'; mux_b_sel <= '0';
			enable <= '0'; localop <= '0';
			reg_res_clk <= '0';
			done <= '0';
		when PRELOAD_RESULT =>
			mux_a_sel <= '0'; mux_b_sel <= '0';
			enable <= '0'; localop <= '0';
			reg_res_clk <= '1';
			done <= '0';
		when SETMUX_PLUS_P =>
			mux_a_sel <= '1'; mux_b_sel <= '1';
			enable <= '1'; localop <= '0';
			reg_res_clk <= '0';
			done <= '0';
		when SETMUX_MINUS_P =>
			mux_a_sel <= '1'; mux_b_sel <= '1';
			enable <= '1'; localop <= '1';
			reg_res_clk <= '0';
			done <= '0';
		when LOAD_PLUS_P =>
			mux_a_sel <= '1'; mux_b_sel <= '1';
			enable <= '1'; localop <= '0';
			reg_res_clk <= '1';
			done <= '0';
		when LOAD_MINUS_P =>
			mux_a_sel <= '1'; mux_b_sel <= '1';
			enable <= '1'; localop <= '1';
			reg_res_clk <= '1';
			done <= '0';
		when COMPLETED =>
			mux_a_sel <= '0'; mux_b_sel <= '0';
			enable <= '0'; localop <= '0';
			reg_res_clk <= '0';
			done <= '1';
		when others =>
			mux_a_sel <= '0'; mux_b_sel <= '0';
			enable <= '0'; localop <= '0';
			reg_res_clk <= '0';
			done <= '1';
		end case;
	end process;
end rtl;
