-- Component: Math_Invert_modN_RS
-- Desc: Modular inverter using RS algorithm
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>


-- NOTE: if 'a' is equal to zero, the result is set to be 0 with NO error


library ieee;
use ieee.std_logic_1164.all;

entity Math_Invert_modN_RS is
generic (
	nbits : integer := 192
);
port (
	a : in std_logic_vector(nbits-1 downto 0);
	p : in std_logic_vector(nbits-1 downto 0);
	result : out std_logic_vector(nbits-1 downto 0);
	start : in std_logic;
	clk : in std_logic;
	done : out std_logic;
	err : out std_logic
);
end Math_Invert_modN_RS;

architecture rtl of Math_Invert_modN_RS is
	function OR_REDUCE(ARG: STD_LOGIC_VECTOR) return UX01 is
		variable x: STD_LOGIC;
	begin
		x := '0';
		for i in ARG'range loop
			x := x or ARG(i);
		end loop;
		return x;
	end;

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
	-- reg_u
	signal reg_u_input : std_logic_vector(nbits downto 0);
	signal reg_u_clk : std_logic;
	--signal reg_u_rst : std_logic;
	signal reg_u_output : std_logic_vector(nbits downto 0);
	-- reg_v
	signal reg_v_input : std_logic_vector(nbits downto 0);
	signal reg_v_clk : std_logic;
	-- signal reg_v_rst : std_logic;
	signal reg_v_output : std_logic_vector(nbits downto 0);
	-- reg_r
	signal reg_r_input : std_logic_vector(nbits downto 0);
	signal reg_r_clk : std_logic;
	--signal reg_r_rst : std_logic;
	signal reg_r_output : std_logic_vector(nbits downto 0);
	-- reg_s
	signal reg_s_input : std_logic_vector(nbits downto 0);
	signal reg_s_clk : std_logic;
	--signal reg_s_rst : std_logic;
	signal reg_s_output : std_logic_vector(nbits downto 0);
	-- reg_result
	signal reg_result_input : std_logic_vector(nbits-1 downto 0);
	signal reg_result_clk : std_logic;
	---- signal reg_result_rst : std_logic;
	signal reg_result_output : std_logic_vector(nbits-1 downto 0);

	component Mux_4to1 is
	generic (
		nbits : integer := 16
	);
	port (
		input0 : in std_logic_vector(nbits-1 downto 0);
		input1 : in std_logic_vector(nbits-1 downto 0);
		input2 : in std_logic_vector(nbits-1 downto 0);
		input3 : in std_logic_vector(nbits-1 downto 0);
		sel : in std_logic_vector(1 downto 0);
		output : out std_logic_vector(nbits-1 downto 0)
	);
	end component;
	signal mux_u_input0 : std_logic_vector(nbits downto 0);
	signal mux_u_input1 : std_logic_vector(nbits downto 0);
	signal mux_u_input2 : std_logic_vector(nbits downto 0);
	signal mux_u_input3 : std_logic_vector(nbits downto 0);
	signal mux_u_sel : std_logic_vector(1 downto 0);
	signal mux_u_output : std_logic_vector(nbits downto 0);
	signal mux_v_input0 : std_logic_vector(nbits downto 0);
	signal mux_v_input1 : std_logic_vector(nbits downto 0);
	signal mux_v_input2 : std_logic_vector(nbits downto 0);
	signal mux_v_input3 : std_logic_vector(nbits downto 0);
	signal mux_v_sel : std_logic_vector(1 downto 0);
	signal mux_v_output : std_logic_vector(nbits downto 0);
	signal mux_r_input0 : std_logic_vector(nbits downto 0);
	signal mux_r_input1 : std_logic_vector(nbits downto 0);
	signal mux_r_input2 : std_logic_vector(nbits downto 0);
	signal mux_r_input3 : std_logic_vector(nbits downto 0);
	signal mux_r_sel : std_logic_vector(1 downto 0);
	signal mux_r_output : std_logic_vector(nbits downto 0);
	signal mux_s_input0 : std_logic_vector(nbits downto 0);
	signal mux_s_input1 : std_logic_vector(nbits downto 0);
	signal mux_s_input2 : std_logic_vector(nbits downto 0);
	signal mux_s_input3 : std_logic_vector(nbits downto 0);
	signal mux_s_sel : std_logic_vector(1 downto 0);
	signal mux_s_output : std_logic_vector(nbits downto 0);
	signal mux_res_input0 : std_logic_vector(nbits-1 downto 0);
	signal mux_res_input1 : std_logic_vector(nbits-1 downto 0);
	signal mux_res_input2 : std_logic_vector(nbits-1 downto 0);
	signal mux_res_input3 : std_logic_vector(nbits-1 downto 0);
	signal mux_res_sel : std_logic_vector(1 downto 0);
	signal mux_res_output : std_logic_vector(nbits-1 downto 0);

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
	signal mux_halfr_input0 : std_logic_vector(nbits downto 0);
	signal mux_halfr_input1 : std_logic_vector(nbits downto 0);
	signal mux_halfr_sel : std_logic;
	signal mux_halfr_output : std_logic_vector(nbits downto 0);
	signal mux_halfs_input0 : std_logic_vector(nbits downto 0);
	signal mux_halfs_input1 : std_logic_vector(nbits downto 0);
	signal mux_halfs_sel : std_logic;
	signal mux_halfs_output : std_logic_vector(nbits downto 0);
	signal mux_addp_input0 : std_logic_vector(nbits downto 0);
	signal mux_addp_input1 : std_logic_vector(nbits downto 0);
	signal mux_addp_sel : std_logic;
	signal mux_addp_output : std_logic_vector(nbits downto 0);
	signal mux_subuv1_input0 : std_logic_vector(nbits downto 0);
	signal mux_subuv1_input1 : std_logic_vector(nbits downto 0);
	signal mux_subuv1_sel : std_logic;
	signal mux_subuv1_output : std_logic_vector(nbits downto 0);
	signal mux_subuv2_input0 : std_logic_vector(nbits downto 0);
	signal mux_subuv2_input1 : std_logic_vector(nbits downto 0);
	signal mux_subuv2_sel : std_logic;
	signal mux_subuv2_output : std_logic_vector(nbits downto 0);
	signal mux_subrs1_input0 : std_logic_vector(nbits downto 0);
	signal mux_subrs1_input1 : std_logic_vector(nbits downto 0);
	signal mux_subrs1_sel : std_logic;
	signal mux_subrs1_output : std_logic_vector(nbits downto 0);
	signal mux_subrs2_input0 : std_logic_vector(nbits downto 0);
	signal mux_subrs2_input1 : std_logic_vector(nbits downto 0);
	signal mux_subrs2_sel : std_logic;
	signal mux_subrs2_output : std_logic_vector(nbits downto 0);

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
	signal subuv_a : std_logic_vector(nbits downto 0);
	signal subuv_b : std_logic_vector(nbits downto 0);
	--signal subuv_op : std_logic; -- 0 = add, 1 = sub
	--signal subuv_cbi : std_logic;
	signal subuv_y : std_logic_vector(nbits downto 0);
	signal subuv_cbo : std_logic;
	signal subrs_a : std_logic_vector(nbits downto 0);
	signal subrs_b : std_logic_vector(nbits downto 0);
	--signal subrs_op : std_logic; -- 0 = add, 1 = sub
	--signal subrs_cbi : std_logic;
	signal subrs_y : std_logic_vector(nbits downto 0);
	signal subrs_cbo : std_logic;
	signal addp_a : std_logic_vector(nbits downto 0);
	signal addp_b : std_logic_vector(nbits downto 0);
	signal addp_op : std_logic; -- 0 = add, 1 = sub
	--signal addp_cbi : std_logic;
	signal addp_y : std_logic_vector(nbits downto 0);
	signal addp_cbo : std_logic;

	component CombComparator is
	generic (
		nbits : integer := 32
	);
	port (
		op1 : in std_logic_vector(nbits-1 downto 0);
		op2 : in std_logic_vector(nbits-1 downto 0);
		gt : out std_logic;
		eq : out std_logic;
		lt : out std_logic
	);
	end component;
	signal cmp_op1 : std_logic_vector(nbits downto 0);
	signal cmp_op2 : std_logic_vector(nbits downto 0);
	signal cmp_gt : std_logic;
	signal cmp_eq : std_logic;
	signal cmp_lt : std_logic;

	-- auxiliary signals
	signal while_check : std_logic;
	signal afterloop_u_is_gt_1 : std_logic;

	-- FSM
	type state_t is (
		SLEEP,
		LOAD_OPERANDS,
		COND_CHECK,
		SETMUX_CASE1,
		SETMUX_CASE2,
		SETMUX_CASE3_1,
		SETMUX_CASE3_2,
		LOAD_CASE1,
		LOAD_CASE2,
		LOAD_CASE3_1,
		LOAD_CASE3_2,
		SETMUX_FIX_R,
		SETMUX_FIX_S,
		FIX_R,
		FIX_S,
		FIX_STAGE,
		SETMUX_RES_R,
		SETMUX_RES_PLUS_P,
		SETMUX_RES_MINUS_P,
		LOAD_RESULT,
		LOAD_RES_PLUS_P,
		LOAD_RES_MINUS_P,
		ERROR_R_GT_1,
		COMPLETED
	);
	signal state : state_t := SLEEP;
begin
	reg_u : Reg_PIPO generic map (nbits => nbits+1)
	port map (
		input => reg_u_input,
		clk => reg_u_clk,
		rst => '0',
		output => reg_u_output
	);

	reg_v : Reg_PIPO generic map (nbits => nbits+1)
	port map (
		input => reg_v_input,
		clk => reg_v_clk,
		rst => '0',
		output => reg_v_output
	);

	reg_r : Reg_PIPO generic map (nbits => nbits+1)
	port map (
		input => reg_r_input,
		clk => reg_r_clk,
		rst => '0',
		output => reg_r_output
	);

	reg_s : Reg_PIPO generic map (nbits => nbits+1)
	port map (
		input => reg_s_input,
		clk => reg_s_clk,
		rst => '0',
		output => reg_s_output
	);

	reg_result : Reg_PIPO generic map (nbits => nbits)
	port map (
		input => reg_result_input,
		clk => reg_result_clk,
		rst => '0',
		output => reg_result_output
	);

	mux_u : Mux_4to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_u_input0,
		input1 => mux_u_input1,
		input2 => mux_u_input2,
		input3 => mux_u_input3,
		sel => mux_u_sel,
		output => mux_u_output
	);

	mux_v : Mux_4to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_v_input0,
		input1 => mux_v_input1,
		input2 => mux_v_input2,
		input3 => mux_v_input3,
		sel => mux_v_sel,
		output => mux_v_output
	);

	mux_r : Mux_4to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_r_input0,
		input1 => mux_r_input1,
		input2 => mux_r_input2,
		input3 => mux_r_input3,
		sel => mux_r_sel,
		output => mux_r_output
	);

	mux_s : Mux_4to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_s_input0,
		input1 => mux_s_input1,
		input2 => mux_s_input2,
		input3 => mux_s_input3,
		sel => mux_s_sel,
		output => mux_s_output
	);

	mux_result : Mux_4to1 generic map (nbits => nbits)
	port map (
		input0 => mux_res_input0,
		input1 => mux_res_input1,
		input2 => mux_res_input2,
		input3 => mux_res_input3,
		sel => mux_res_sel,
		output => mux_res_output
	);

	mux_addp : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_addp_input0,
		input1 => mux_addp_input1,
		sel => mux_addp_sel,
		output => mux_addp_output
	);

	mux_subuv1 : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_subuv1_input0,
		input1 => mux_subuv1_input1,
		sel => mux_subuv1_sel,
		output => mux_subuv1_output
	);

	mux_subrs1 : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_subrs1_input0,
		input1 => mux_subrs1_input1,
		sel => mux_subrs1_sel,
		output => mux_subrs1_output
	);

	mux_subuv2 : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_subuv2_input0,
		input1 => mux_subuv2_input1,
		sel => mux_subuv2_sel,
		output => mux_subuv2_output
	);

	mux_subrs2 : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_subrs2_input0,
		input1 => mux_subrs2_input1,
		sel => mux_subrs2_sel,
		output => mux_subrs2_output
	);


	mux_halfs : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_halfs_input0,
		input1 => mux_halfs_input1,
		sel => mux_halfs_sel,
		output => mux_halfs_output
	);

	mux_halfr : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_halfr_input0,
		input1 => mux_halfr_input1,
		sel => mux_halfr_sel,
		output => mux_halfr_output
	);

	addp : Math_RippleFAS generic map (nbits => nbits+1)
	port map (
		a => addp_a,
		b => addp_b,
		op => addp_op,
		cbi => '0',
		y => addp_y,
		cbo => addp_cbo
	);

	subuv : Math_RippleFAS generic map (nbits => nbits+1)
	port map (
		a => subuv_a,
		b => subuv_b,
		op => '1',
		cbi => '0',
		y => subuv_y,
		cbo => subuv_cbo
	);

	subrs : Math_RippleFAS generic map (nbits => nbits+1)
	port map (
		a => subrs_a,
		b => subrs_b,
		op => '1',
		cbi => '0',
		y => subrs_y,
		cbo => subrs_cbo
	);

	cmp : CombComparator generic map (nbits => nbits+1)
	port map (
		op1 => cmp_op1,
		op2 => cmp_op2,
		gt => cmp_gt,
		eq => cmp_eq,
		lt => cmp_lt
	);

	-- static wirings ----------------------------------------------

	-- conditions
	while_check <= (not reg_v_output(nbits)) and OR_REDUCE(reg_v_output(nbits-1 downto 0));
	afterloop_u_is_gt_1 <= (not reg_u_output(nbits)) and OR_REDUCE(reg_v_output(nbits-1 downto 1));

	reg_u_input <= mux_u_output;
	reg_v_input <= mux_v_output;
	reg_r_input <= mux_r_output;
	reg_s_input <= mux_s_output;

	mux_u_input0 <= '0' & p;
	mux_u_input1 <= subuv_y;
	mux_u_input2 <= '0' & reg_u_output(nbits downto 1);
	mux_u_input3 <= '0' & reg_u_output(nbits downto 1);

	mux_v_input0 <= '0' & a;
	mux_v_input1 <= subuv_y;
	mux_v_input2 <= '0' & reg_v_output(nbits downto 1);
	mux_v_input3 <= '0' & reg_v_output(nbits downto 1);

	mux_r_input0 <= (others => '0');
	mux_r_input1 <= subrs_y;
	mux_r_input2 <= mux_halfr_output;
	mux_r_input3 <= addp_y;

	mux_s_input0(nbits downto 1) <= (others => '0'); mux_s_input0(0) <= '1';
	mux_s_input1 <= subrs_y;
	mux_s_input2 <= mux_halfs_output;
	mux_s_input3 <= addp_y;

	mux_res_input0 <= (others => '0');
	mux_res_input1 <= addp_y(nbits-1 downto 0);
	mux_res_input2 <= reg_r_output(nbits-1 downto 0);
	mux_res_input3 <= addp_y(nbits-1 downto 0);

	mux_addp_input0 <= reg_r_output;
	mux_addp_input1 <= reg_s_output;

	mux_subuv1_input0 <= reg_u_output;
	mux_subuv1_input1 <= reg_v_output;
	mux_subuv1_sel <= not cmp_gt;
	mux_subuv2_input0 <= reg_v_output;
	mux_subuv2_input1 <= reg_u_output;
	mux_subuv2_sel <= not cmp_gt;

	mux_subrs1_input0 <= reg_r_output;
	mux_subrs1_input1 <= reg_s_output;
	mux_subrs1_sel <= not cmp_gt;
	mux_subrs2_input0 <= reg_s_output;
	mux_subrs2_input1 <= reg_r_output;
	mux_subrs2_sel <= not cmp_gt;

	mux_halfr_input0 <= '0' & reg_r_output(nbits downto 1);
	mux_halfr_input1 <= addp_cbo & addp_y(nbits downto 1);
	mux_halfr_sel <= reg_r_output(0);
	mux_halfs_input0 <= '0' & reg_s_output(nbits downto 1);
	mux_halfs_input1 <= addp_cbo & addp_y(nbits downto 1);
	mux_halfs_sel <= reg_s_output(0);

	addp_a <= mux_addp_output;
	addp_b <= '0' & p;
	subuv_a <= mux_subuv1_output;
	subuv_b <= mux_subuv2_output;
	subrs_a <= mux_subrs1_output;
	subrs_b <= mux_subrs2_output;

	cmp_op1 <= reg_u_output;
	cmp_op2 <= reg_v_output;

	reg_result_input <= mux_res_output;

	result <= reg_result_output;

	-- FSM
	f_x : process(clk)
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
				if (while_check = '1') then
					if (reg_u_output(0) = '0') then
						state <= SETMUX_CASE1;
					elsif (reg_v_output(0) = '0') then
						state <= SETMUX_CASE2;
					else
						if (cmp_gt = '1') then
							state <= SETMUX_CASE3_1;
						else
							state <= SETMUX_CASE3_2;
						end if;
					end if;
				else
					state <= FIX_STAGE;
				end if;
			when COND_CHECK =>
				if (while_check = '1') then
					if (reg_u_output(0) = '0') then
						state <= SETMUX_CASE1;
					elsif (reg_v_output(0) = '0') then
						state <= SETMUX_CASE2;
					else
						if (cmp_gt = '1') then
							state <= SETMUX_CASE3_1;
						else
							state <= SETMUX_CASE3_2;
						end if;
					end if;
				else
					state <= FIX_STAGE;
				end if;
			when SETMUX_CASE1 =>
				state <= LOAD_CASE1;
			when LOAD_CASE1 =>
				state <= COND_CHECK;
			when SETMUX_CASE2 =>
				state <= LOAD_CASE2;
			when LOAD_CASE2 =>
				state <= COND_CHECK;
			when SETMUX_CASE3_1 =>
				state <= LOAD_CASE3_1;
			when SETMUX_CASE3_2 =>
				state <= LOAD_CASE3_2;
			when LOAD_CASE3_1 =>
				if (reg_r_output(nbits) = '1') then
					state <= SETMUX_FIX_R;
				else
					state <= COND_CHECK;
				end if;
			when SETMUX_FIX_R =>
				state <= FIX_R;
			when FIX_R =>
				state <= COND_CHECK;
			when LOAD_CASE3_2 =>
				if (reg_s_output(nbits) = '1') then
					state <= SETMUX_FIX_S;
				else
					state <= COND_CHECK;
				end if;
			when SETMUX_FIX_S =>
				state <= FIX_S;
			when FIX_S =>
				state <= COND_CHECK;
			when FIX_STAGE =>
				if (afterloop_u_is_gt_1 = '1') then
					state <= ERROR_R_GT_1;
				else
					if (addp_cbo = '1') then -- do we have borrow?
						-- ok r is lt p, let's check for negativity
						if (reg_r_output(nbits) = '1') then
							state <= SETMUX_RES_PLUS_P;
						else
							-- ok r is good as it is
							state <= SETMUX_RES_R;
						end if;
					else
						-- r is gt p, subtract p
						state <= SETMUX_RES_MINUS_P;
					end if;
				end if;
			when SETMUX_RES_PLUS_P =>
				state <= LOAD_RES_PLUS_P;
			when LOAD_RES_PLUS_P =>
				state <= COMPLETED;
			when SETMUX_RES_R =>
				state <= LOAD_RESULT;
			when LOAD_RESULT =>
				state <= COMPLETED;
			when SETMUX_RES_MINUS_P =>
				state <= LOAD_RES_MINUS_P;
			when LOAD_RES_MINUS_P =>
				state <= COMPLETED;
			when COMPLETED =>
				if (start = '1') then
					state <= COMPLETED;
				else
					state <= SLEEP;
				end if;
			when ERROR_R_GT_1 =>
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

	g_x : process(state)
	begin
		case state is
		when SLEEP =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when LOAD_OPERANDS =>
			reg_u_clk <= '1'; reg_v_clk <= '1'; reg_r_clk <= '1'; reg_s_clk <= '1'; reg_result_clk <= '1';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when COND_CHECK =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when SETMUX_CASE1 =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "10"; mux_v_sel <= "00"; mux_r_sel <= "10"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when SETMUX_CASE2 =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "10"; mux_r_sel <= "00"; mux_s_sel <= "10"; mux_res_sel <= "00";
			mux_addp_sel <= '1'; addp_op <= '0';
			done <= '0'; err <= '0';
		when SETMUX_CASE3_1 =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "01"; mux_v_sel <= "00"; mux_r_sel <= "01"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when SETMUX_CASE3_2 =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "01"; mux_r_sel <= "00"; mux_s_sel <= "01"; mux_res_sel <= "00";
			mux_addp_sel <= '1'; addp_op <= '0';
			done <= '0'; err <= '0';
		when LOAD_CASE1 =>
			reg_u_clk <= '1'; reg_v_clk <= '0'; reg_r_clk <= '1'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "10"; mux_v_sel <= "00"; mux_r_sel <= "10"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when LOAD_CASE2 =>
			reg_u_clk <= '0'; reg_v_clk <= '1'; reg_r_clk <= '0'; reg_s_clk <= '1'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "10"; mux_r_sel <= "00"; mux_s_sel <= "10"; mux_res_sel <= "00";
			mux_addp_sel <= '1'; addp_op <= '0';
			done <= '0'; err <= '0';
		when LOAD_CASE3_1 =>
			reg_u_clk <= '1'; reg_v_clk <= '0'; reg_r_clk <= '1'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "01"; mux_v_sel <= "00"; mux_r_sel <= "01"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when LOAD_CASE3_2 =>
			reg_u_clk <= '0'; reg_v_clk <= '1'; reg_r_clk <= '0'; reg_s_clk <= '1'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "01"; mux_r_sel <= "00"; mux_s_sel <= "01"; mux_res_sel <= "00";
			mux_addp_sel <= '1'; addp_op <= '0';
			done <= '0'; err <= '0';
		when SETMUX_FIX_R =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "01"; mux_v_sel <= "00"; mux_r_sel <= "11"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when FIX_R =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '1'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "01"; mux_v_sel <= "00"; mux_r_sel <= "11"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when SETMUX_FIX_S =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "01"; mux_r_sel <= "00"; mux_s_sel <= "11"; mux_res_sel <= "00";
			mux_addp_sel <= '1'; addp_op <= '0';
			done <= '0'; err <= '0';
		when FIX_S =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '1'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "01"; mux_r_sel <= "00"; mux_s_sel <= "11"; mux_res_sel <= "00";
			mux_addp_sel <= '1'; addp_op <= '0';
			done <= '0'; err <= '0';
		when FIX_STAGE =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '1';
			done <= '0'; err <= '0';
		when SETMUX_RES_R =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "10";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when LOAD_RESULT =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '1';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "10";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when SETMUX_RES_PLUS_P =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "01";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when LOAD_RES_PLUS_P =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '1';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "01";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '0';
		when SETMUX_RES_MINUS_P =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "11";
			mux_addp_sel <= '0'; addp_op <= '1';
			done <= '0'; err <= '0';
		when LOAD_RES_MINUS_P =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '1';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "11";
			mux_addp_sel <= '0'; addp_op <= '1';
			done <= '0'; err <= '0';
		when COMPLETED =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "10";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '1'; err <= '0';
		when ERROR_R_GT_1 =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '1'; err <= '1';
		when others =>
			reg_u_clk <= '0'; reg_v_clk <= '0'; reg_r_clk <= '0'; reg_s_clk <= '0'; reg_result_clk <= '0';
			mux_u_sel <= "00"; mux_v_sel <= "00"; mux_r_sel <= "00"; mux_s_sel <= "00"; mux_res_sel <= "00";
			mux_addp_sel <= '0'; addp_op <= '0';
			done <= '0'; err <= '1';
		end case;
	end process;
end rtl;
