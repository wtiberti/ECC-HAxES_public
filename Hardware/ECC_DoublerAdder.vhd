-- Component: ECC_DoublerAdder
-- Desc: A all-in-one ECC point adder/doubler component: P+Q or 2P
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity ECC_DoublerAdder is
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
end ECC_DoublerAdder;

architecture rtl of ECC_DoublerAdder is
	component Math_Invert_modN_RS is
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
	end component;
	signal inv_a : std_logic_vector(nbits downto 0);
	signal inv_p : std_logic_vector(nbits downto 0);
	signal inv_result : std_logic_vector(nbits downto 0);
	signal inv_clk : std_logic;
	signal inv_start : std_logic;
	signal inv_done : std_logic;
	signal inv_err : std_logic;

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

	component Math_AddSub_modN is
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
	end component;
	signal as_cbi : std_logic;
	signal as_a : std_logic_vector(nbits-1 downto 0);
	signal as_b : std_logic_vector(nbits-1 downto 0);
	signal as_n : std_logic_vector(nbits-1 downto 0);
	signal as_op : std_logic; -- 0 = add, 1 = sub
	signal as_start : std_logic;
	signal as_clk : std_logic;
	signal as_result : std_logic_vector(nbits-1 downto 0);
	signal as_done : std_logic;

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
	signal mux_mul1_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_mul1_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_mul1_in2 : std_logic_vector(nbits-1 downto 0);
	signal mux_mul1_in3 : std_logic_vector(nbits-1 downto 0);
	signal mux_mul1_sel : std_logic_vector(1 downto 0);
	signal mux_mul1_out : std_logic_vector(nbits-1 downto 0);

	signal mux_mul2_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_mul2_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_mul2_in2 : std_logic_vector(nbits-1 downto 0);
	signal mux_mul2_in3 : std_logic_vector(nbits-1 downto 0);
	signal mux_mul2_sel : std_logic_vector(1 downto 0);
	signal mux_mul2_out : std_logic_vector(nbits-1 downto 0);

	signal mux_addsub1_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_addsub1_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_addsub1_in2 : std_logic_vector(nbits-1 downto 0);
	signal mux_addsub1_in3 : std_logic_vector(nbits-1 downto 0);
	signal mux_addsub1_sel : std_logic_vector(1 downto 0);
	signal mux_addsub1_out : std_logic_vector(nbits-1 downto 0);

	signal mux_addsub2_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_addsub2_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_addsub2_in2 : std_logic_vector(nbits-1 downto 0);
	signal mux_addsub2_in3 : std_logic_vector(nbits-1 downto 0);
	signal mux_addsub2_sel : std_logic_vector(1 downto 0);
	signal mux_addsub2_out : std_logic_vector(nbits-1 downto 0);

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
	signal mux_inv_in0 : std_logic_vector(nbits downto 0);
	signal mux_inv_in1 : std_logic_vector(nbits downto 0);
	signal mux_inv_sel : std_logic;
	signal mux_inv_out : std_logic_vector(nbits downto 0);

	signal mux_acc_in0 : std_logic_vector(nbits-1 downto 0);
	signal mux_acc_in1 : std_logic_vector(nbits-1 downto 0);
	signal mux_acc_sel : std_logic;
	signal mux_acc_out : std_logic_vector(nbits-1 downto 0);

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
	signal reg_acc_in : std_logic_vector(nbits-1 downto 0);
	signal reg_acc_clk : std_logic;
	signal reg_acc_rst : std_logic;
	signal reg_acc_out : std_logic_vector(nbits-1 downto 0);

	signal reg_px_in : std_logic_vector(nbits-1 downto 0);
	signal reg_px_clk : std_logic;
	signal reg_px_rst : std_logic;
	signal reg_px_out : std_logic_vector(nbits-1 downto 0);
	signal reg_py_in : std_logic_vector(nbits-1 downto 0);
	signal reg_py_clk : std_logic;
	signal reg_py_rst : std_logic;
	signal reg_py_out : std_logic_vector(nbits-1 downto 0);

	signal reg_qx_in : std_logic_vector(nbits-1 downto 0);
	signal reg_qx_clk : std_logic;
	signal reg_qx_rst : std_logic;
	signal reg_qx_out : std_logic_vector(nbits-1 downto 0);
	signal reg_qy_in : std_logic_vector(nbits-1 downto 0);
	signal reg_qy_clk : std_logic;
	signal reg_qy_rst : std_logic;
	signal reg_qy_out : std_logic_vector(nbits-1 downto 0);

	signal reg_rx_in : std_logic_vector(nbits-1 downto 0);
	signal reg_rx_clk : std_logic;
	signal reg_rx_rst : std_logic;
	signal reg_rx_out : std_logic_vector(nbits-1 downto 0);
	signal reg_ry_in : std_logic_vector(nbits-1 downto 0);
	signal reg_ry_clk : std_logic;
	signal reg_ry_rst : std_logic;
	signal reg_ry_out : std_logic_vector(nbits-1 downto 0);

	signal reg_a_in : std_logic_vector(nbits-1 downto 0);
	signal reg_a_clk : std_logic;
	signal reg_a_rst : std_logic;
	signal reg_a_out : std_logic_vector(nbits-1 downto 0);

	signal reg_modp_in : std_logic_vector(nbits-1 downto 0);
	signal reg_modp_clk : std_logic;
	signal reg_modp_rst : std_logic;
	signal reg_modp_out : std_logic_vector(nbits-1 downto 0);

	signal reg_x2s_in : std_logic_vector(nbits-1 downto 0);
	signal reg_x2s_clk : std_logic;
	signal reg_x2s_rst : std_logic;
	signal reg_x2s_out : std_logic_vector(nbits-1 downto 0);

	signal reg_s2_in : std_logic_vector(nbits-1 downto 0);
	signal reg_s2_clk : std_logic;
	signal reg_s2_rst : std_logic;
	signal reg_s2_out : std_logic_vector(nbits-1 downto 0);

	-- Op-like auxiliary signals
	signal mux_mul_op : std_logic_vector(3 downto 0);
	signal mux_as_op : std_logic_vector(4 downto 0);
	constant op_mul_px_px : std_logic_vector(3 downto 0) := "0000";
	constant op_mul_s_s : std_logic_vector(3 downto 0) := "1010";
	constant op_mul_s_acc : std_logic_vector(3 downto 0) := "1001";
	constant op_mul_acc_inv : std_logic_vector(3 downto 0) := "0101";
	constant op_add_s2_acc : std_logic_vector(4 downto 0) := "10110";
	constant op_add_qx_px : std_logic_vector(4 downto 0) := "00000";
	constant op_sub_qx_px : std_logic_vector(4 downto 0) := "00001";
	constant op_sub_qy_py : std_logic_vector(4 downto 0) := "01011";
	constant op_sub_px_acc : std_logic_vector(4 downto 0) := "10101";
	constant op_sub_s2_acc : std_logic_vector(4 downto 0) := "10111";
	constant op_sub_s2_py : std_logic_vector(4 downto 0) := "01111"; -- used for acc - py in the last computation

	type state_t is (
		SLEEP,
		LOAD_OPERANDS,
		PA_SETMUX_SUB_Y,
		PA_SUB_QY_PY,
		PA_LOAD_ACC1,
		PA_START_INV,
		PA_SETMUX_SUB_X,
		PA_SUB_QX_PX,
		PA_LOAD_ACC2,
		PD_SETMUX_PX2,
		PD_LOAD_A_START_ALL,
		PD_LOAD_X2,
		PD_SETMUX_X2_ACC,
		PD_ADD_X2_1,
		PD_LOAD_NUM_1,
		PD_ADD_X2_2,
		PD_LOAD_NUM_2,
		PD_ADD_X2_3,
		PD_LOAD_NUM_3,
		SET_COMPUTE_S,
		COMPUTE_S,
		LOAD_S,
		SET_COMPUTE_S2,
		COMPUTE_S2,
		LOAD_S2,
		SETMUX_ADD_X,
		ADD_QX_PX,
		LOAD_ACC_SUM_X,
		SETMUX_SUB_S2_ACC,
		SUB_S2_ACC,
		LOAD_RX,
		SETMUX_SUB_PX_ACC,
		SUB_PX_ACC,
		LOAD_ACC_AUX1,
		MUL_S_ACC,
		LOAD_S2_AS_ACC,
		SETMUX_SUB_ACC_PY,
		SUB_ACC_PY,
		LOAD_RY,
		COMPLETED,
		OP_ERROR
	);
	signal state : state_t := SLEEP;
begin
	inv : Math_Invert_modN_RS generic map (nbits => nbits+1)
	port map (
		a => inv_a,
		p => inv_p,
		result => inv_result,
		start => inv_start,
		clk => inv_clk,
		done => inv_done,
		err => inv_err
	);

	mulmodn : Math_Mul_modN generic map (nbits => nbits)
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

	addsubmodn : Math_AddSub_modN generic map (nbits => nbits)
	port map (
		cbi => as_cbi,
		a => as_a,
		b => as_b,
		n => as_n,
		op => as_op,
		start => as_start,
		clk => as_clk,
		result => as_result,
		done => as_done
	);

	muxmul1 : Mux_4to1 generic map (nbits => nbits)
	port map (
		input0 => mux_mul1_in0,
		input1 => mux_mul1_in1,
		input2 => mux_mul1_in2,
		input3 => mux_mul1_in3,
		sel => mux_mul1_sel,
		output => mux_mul1_out
	);
	muxmul2 : Mux_4to1 generic map (nbits => nbits)
	port map (
		input0 => mux_mul2_in0,
		input1 => mux_mul2_in1,
		input2 => mux_mul2_in2,
		input3 => mux_mul2_in3,
		sel => mux_mul2_sel,
		output => mux_mul2_out
	);
	muxaddsub1 : Mux_4to1 generic map (nbits => nbits)
	port map (
		input0 => mux_addsub1_in0,
		input1 => mux_addsub1_in1,
		input2 => mux_addsub1_in2,
		input3 => mux_addsub1_in3,
		sel => mux_addsub1_sel,
		output => mux_addsub1_out
	);
	muxaddsub2 : Mux_4to1 generic map (nbits => nbits)
	port map (
		input0 => mux_addsub2_in0,
		input1 => mux_addsub2_in1,
		input2 => mux_addsub2_in2,
		input3 => mux_addsub2_in3,
		sel => mux_addsub2_sel,
		output => mux_addsub2_out
	);

	muxinv : Mux_2to1 generic map (nbits => nbits+1)
	port map (
		input0 => mux_inv_in0,
		input1 => mux_inv_in1,
		sel => mux_inv_sel,
		output => mux_inv_out
	);
	muxacc : Mux_2to1 generic map (nbits => nbits)
	port map (
		input0 => mux_acc_in0,
		input1 => mux_acc_in1,
		sel => mux_acc_sel,
		output => mux_acc_out
	);

	reg_px : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_px_in,
		clk => reg_px_clk,
		rst => reg_px_rst,
		output => reg_px_out
	);
	reg_py : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_py_in,
		clk => reg_py_clk,
		rst => reg_py_rst,
		output => reg_py_out
	);
	reg_qx : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_qx_in,
		clk => reg_qx_clk,
		rst => reg_qx_rst,
		output => reg_qx_out
	);
	reg_qy : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_qy_in,
		clk => reg_qy_clk,
		rst => reg_qy_rst,
		output => reg_qy_out
	);
	reg_rx : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_rx_in,
		clk => reg_rx_clk,
		rst => reg_rx_rst,
		output => reg_rx_out
	);
	reg_ry : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_ry_in,
		clk => reg_ry_clk,
		rst => reg_ry_rst,
		output => reg_ry_out
	);
	reg_a : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_a_in,
		clk => reg_a_clk,
		rst => reg_a_rst,
		output => reg_a_out
	);
	reg_modp : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_modp_in,
		clk => reg_modp_clk,
		rst => reg_modp_rst,
		output => reg_modp_out
	);
	reg_x2s : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_x2s_in,
		clk => reg_x2s_clk,
		rst => reg_x2s_rst,
		output => reg_x2s_out
	);
	reg_s2 : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_s2_in,
		clk => reg_s2_clk,
		rst => reg_s2_rst,
		output => reg_s2_out
	);
	reg_acc : Reg_PIPO generic map (nbits => nbits)
	port map (
		input  => reg_acc_in,
		clk => reg_acc_clk,
		rst => reg_acc_rst,
		output => reg_acc_out
	);
	-- ================================================
	reg_px_in <= P((2*nbits)-1 downto nbits);
	reg_px_rst <= '0';
	reg_py_in <= P(nbits-1 downto 0);
	reg_py_rst <= '0';
	reg_qx_in <= Q((2*nbits)-1 downto nbits);
	reg_qx_rst <= '0';
	reg_qy_in <= Q(nbits-1 downto 0);
	reg_qy_rst <= '0';
	reg_a_in <= a;
	reg_a_rst <= '0';
	reg_modp_in <= mod_p;
	reg_modp_rst <= '0';
	reg_rx_in <= as_result;
	reg_rx_rst <= '0';
	reg_ry_in <= as_result;
	reg_ry_rst <= '0';
	reg_x2s_in <= mul_product;
	reg_x2s_rst <= '0';
	reg_s2_in <= mul_product;
	reg_s2_rst <= '0';
	reg_acc_in <= mux_acc_out;
	reg_acc_rst <= '0';

	mux_mul1_in0 <= reg_px_out;
	mux_mul1_in1 <= reg_acc_out;
	mux_mul1_in2 <= reg_x2s_out;
	mux_mul1_in3 <= (others => 'Z');

	mux_mul2_in0 <= reg_px_out;
	mux_mul2_in1 <= inv_result(nbits-1 downto 0);
	mux_mul2_in2 <= reg_x2s_out;
	mux_mul2_in3 <= reg_s2_out;

	mux_addsub1_in0 <= reg_qx_out;
	mux_addsub1_in1 <= reg_qy_out;
	mux_addsub1_in2 <= reg_px_out;
	mux_addsub1_in3 <= reg_s2_out;

	mux_addsub2_in0 <= reg_px_out;
	mux_addsub2_in1 <= reg_py_out;
	mux_addsub2_in2 <= reg_acc_out;
	mux_addsub2_in3 <= (others => 'Z'); -- check

	mux_inv_in0 <= reg_py_out & '0'; -- shift
	mux_inv_in1 <= '0' & reg_acc_out; -- zero-extend

	mux_acc_in0 <= a;
	mux_acc_in1 <= as_result;

	mul_a <= mux_mul1_out;
	mul_b <= mux_mul2_out;
	mul_n <= reg_modp_out;
	mul_clk <= clk;

	as_cbi <= '0';
	as_a <= mux_addsub1_out;
	as_b <= mux_addsub2_out;
	as_n <= reg_modp_out;
	as_clk <= clk;

	inv_a <= mux_inv_out;
	inv_p <= '0' & reg_modp_out;
	inv_clk <= clk;

	-- OP2|OP1
	mux_mul1_sel <= mux_mul_op(1 downto 0);
	mux_mul2_sel <= mux_mul_op(3 downto 2);

	-- OP2|OP1|OP
	as_op <= mux_as_op(0);
	mux_addsub1_sel <= mux_as_op(2 downto 1);
	mux_addsub2_sel <= mux_as_op(4 downto 3);

	R((2*nbits)-1 downto nbits) <= reg_rx_out;
	R(nbits-1 downto 0) <= reg_ry_out;
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
				if (op = '0') then
					state <= PA_SETMUX_SUB_X;
				else
					state <= PD_SETMUX_PX2;
				end if;
			when PA_SETMUX_SUB_X =>
				state <= PA_SUB_QX_PX;
			when PA_SUB_QX_PX =>
				if (as_done = '1') then
					state <= PA_LOAD_ACC1;
				else
					state <= PA_SUB_QX_PX;
				end if;
			when PA_LOAD_ACC1 =>
				state <= PA_START_INV;
			when PA_START_INV =>
				-- don't wait
				state <= PA_SETMUX_SUB_Y;
			when PA_SETMUX_SUB_Y =>
				state <= PA_SUB_QY_PY;
			when PA_SUB_QY_PY =>
				if (as_done = '1') then
					state <= PA_LOAD_ACC2;
				else
					state <= PA_SUB_QY_PY;
				end if;
			when PA_LOAD_ACC2 =>
				if (inv_done = '1') then
					if (inv_err = '1') then
						state <= OP_ERROR;
					else
						state <= SET_COMPUTE_S;
					end if;
				else
					state <= PA_LOAD_ACC2;
				end if;
			-- intermezzo --
			when PD_SETMUX_PX2 =>
				state <= PD_LOAD_A_START_ALL;
			when PD_LOAD_A_START_ALL =>
				if (mul_done = '1') then
					if (mul_moderror = '1') then
						state <= OP_ERROR;
					else
						state <= PD_LOAD_X2;
					end if;
				else
					state <= PD_LOAD_A_START_ALL;
				end if;
			when PD_LOAD_X2 =>
				state <= PD_SETMUX_X2_ACC;
			when PD_SETMUX_X2_ACC =>
				state <= PD_ADD_X2_1;
			when PD_ADD_X2_1 =>
				if (as_done = '1') then
					state <= PD_LOAD_NUM_1;
				else
					state <= PD_ADD_X2_1;
				end if;
			when PD_LOAD_NUM_1 =>
				state <= PD_ADD_X2_2;
			when PD_ADD_X2_2 =>
				if (as_done = '1') then
					state <= PD_LOAD_NUM_2;
				else
					state <= PD_ADD_X2_2;
				end if;
			when PD_LOAD_NUM_2 =>
				state <= PD_ADD_X2_3;
			when PD_ADD_X2_3 =>
				if (as_done = '1') then
					state <= PD_LOAD_NUM_3;
				else
					state <= PD_ADD_X2_3;
				end if;
			when PD_LOAD_NUM_3 =>
				if (inv_done = '1') then
					if (inv_err = '1') then
						state <= OP_ERROR;
					else
						state <= SET_COMPUTE_S;
					end if;
				else
					state <= PD_LOAD_NUM_3;
				end if;
			-- merge --
			when SET_COMPUTE_S =>
				state <= COMPUTE_S;
			when COMPUTE_S =>
				if (mul_done = '1') then
					if (mul_moderror = '1') then
						state <= OP_ERROR;
					else
						state <= LOAD_S;
					end if;
				else
					state <= COMPUTE_S;
				end if;
			when LOAD_S =>
				state <= SET_COMPUTE_S2;
			when SET_COMPUTE_S2 =>
				state <= COMPUTE_S2;
			when COMPUTE_S2 =>
				if (mul_done = '1') then
					if (mul_moderror = '1') then
						state <= OP_ERROR;
					else
						state <= LOAD_S2;
					end if;
				else
					state <= COMPUTE_S2;
				end if;
			when LOAD_S2 =>
				state <= SETMUX_ADD_X;
			when SETMUX_ADD_X =>
				state <= ADD_QX_PX;
			when ADD_QX_PX =>
				if (as_done = '1') then
					state <= LOAD_ACC_SUM_X;
				else
					state <= ADD_QX_PX;
				end if;
			when LOAD_ACC_SUM_X =>
				state <= SETMUX_SUB_S2_ACC;
			when SETMUX_SUB_S2_ACC =>
				state <= SUB_S2_ACC;
			when SUB_S2_ACC =>
				if (as_done = '1') then
					state <= LOAD_RX;
				else
					state <= SUB_S2_ACC;
				end if;
			when LOAD_RX =>
				state <= SETMUX_SUB_PX_ACC;
			when SETMUX_SUB_PX_ACC =>
				state <= SUB_PX_ACC;
			when SUB_PX_ACC =>
				if (as_done = '1') then
					state <= LOAD_ACC_AUX1;
				else
					state <= SUB_PX_ACC;
				end if;
			when LOAD_ACC_AUX1 =>
				state <= MUL_S_ACC;
			when MUL_S_ACC =>
				if (mul_done = '1') then
					if (mul_moderror = '1') then
						state <= OP_ERROR;
					else
						state <= LOAD_S2_AS_ACC;
					end if;
				else
					state <= MUL_S_ACC;
				end if;
			when LOAD_S2_AS_ACC =>
				state <= SETMUX_SUB_ACC_PY;
			when SETMUX_SUB_ACC_PY =>
				state <= SUB_ACC_PY;
			when SUB_ACC_PY =>
				if (as_done = '1') then
					state <= LOAD_RY;
				else
					state <= SUB_ACC_PY;
				end if;
			when LOAD_RY =>
				state <= COMPLETED;
			when COMPLETED =>
				if (start = '1') then
					state <= COMPLETED;
				else
					state <= SLEEP;
				end if;
			when OP_ERROR =>
				if (start = '1') then
					state <= OP_ERROR;
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
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '0'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_px_px; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when LOAD_OPERANDS =>
			reg_px_clk <= '1'; reg_py_clk <= '1'; reg_qx_clk <= '1'; reg_qy_clk <= '1'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '1'; reg_modp_clk <= '1'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '0'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_px_px; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when PA_SETMUX_SUB_X =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_qx_px; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '1'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when PA_SUB_QX_PX =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_qx_px; as_start <= '1';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '1'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when PA_LOAD_ACC1 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '1';
			mux_as_op <= op_sub_qy_py; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '1'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when PA_START_INV =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_qy_py; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '1'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PA_SETMUX_SUB_Y =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_qy_py; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '1'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PA_SUB_QY_PY =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_qy_py; as_start <= '1';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '1'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PA_LOAD_ACC2 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '1';
			mux_as_op <= op_sub_qx_px; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '1'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_SETMUX_PX2 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '0'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_px_px; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_LOAD_A_START_ALL =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '0'; reg_acc_clk <= '1';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_px_px; mul_start <= '1';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_LOAD_X2 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '1'; reg_s2_clk <= '1'; -- !
			mux_acc_sel <= '0'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_px_px; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_SETMUX_X2_ACC =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_ADD_X2_1 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '1';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_LOAD_NUM_1 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '1';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_ADD_X2_2 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '1';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_LOAD_NUM_2 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '1';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_ADD_X2_3 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '1';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when PD_LOAD_NUM_3 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '1';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '1';
			done <= '0'; err <= '0'; inf <= '0';
		when SET_COMPUTE_S =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when COMPUTE_S =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '1';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when LOAD_S =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '1'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_acc_inv; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when SET_COMPUTE_S2 => -- removeable
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_s; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when COMPUTE_S2 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_s; mul_start <= '1';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when LOAD_S2 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '1';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_s; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when SETMUX_ADD_X => -- removeable
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_qx_px; as_start <= '0';
			mux_mul_op <= op_mul_s_s; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when ADD_QX_PX =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_add_qx_px; as_start <= '1';
			mux_mul_op <= op_mul_s_s; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when LOAD_ACC_SUM_X =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '1';
			mux_as_op <= op_add_qx_px; as_start <= '0';
			mux_mul_op <= op_mul_s_s; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when SETMUX_SUB_S2_ACC =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_s; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when SUB_S2_ACC =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_s2_acc; as_start <= '1';
			mux_mul_op <= op_mul_s_s; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when LOAD_RX =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '1'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '1';
			mux_as_op <= op_sub_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_s; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when SETMUX_SUB_PX_ACC =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_px_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when SUB_PX_ACC =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_px_acc; as_start <= '1';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when LOAD_ACC_AUX1 =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '1';
			mux_as_op <= op_sub_px_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when MUL_S_ACC =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_px_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_acc; mul_start <= '1';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when LOAD_S2_AS_ACC =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '1'; -- !
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_px_acc; as_start <= '0';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when SETMUX_SUB_ACC_PY =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_s2_py; as_start <= '0';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when SUB_ACC_PY =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_s2_py; as_start <= '1';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when LOAD_RY =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '1';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_s2_py; as_start <= '0';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '0'; inf <= '0';
		when COMPLETED =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_s2_py; as_start <= '0';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '1'; err <= '0'; inf <= '0';
		when OP_ERROR =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '1'; reg_acc_clk <= '0';
			mux_as_op <= op_sub_s2_py; as_start <= '0';
			mux_mul_op <= op_mul_s_acc; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '1'; err <= '1'; inf <= '0';
		when others =>
			reg_px_clk <= '0'; reg_py_clk <= '0'; reg_qx_clk <= '0'; reg_qy_clk <= '0'; reg_rx_clk <= '0'; reg_ry_clk <= '0';
			reg_a_clk <= '0'; reg_modp_clk <= '0'; reg_x2s_clk <= '0'; reg_s2_clk <= '0';
			mux_acc_sel <= '0'; reg_acc_clk <= '0';
			mux_as_op <= op_add_s2_acc; as_start <= '0';
			mux_mul_op <= op_mul_px_px; mul_start <= '0';
			mux_inv_sel <= '0'; inv_start <= '0';
			done <= '0'; err <= '1'; inf <= '0';
		end case;
	end process;
end rtl;
