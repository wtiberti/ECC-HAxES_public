-- Component: Math_Mul_modN
-- Desc: A multiplier modulo n
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Math_Mul_modN is
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
end Math_Mul_modN;

architecture rtl of Math_Mul_modN is
	component Math_SerialMul is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		clk : in std_logic;
		start : in std_logic;
		y : out std_logic_vector((2*nbits)-1 downto 0);
		done : out std_logic
	);
	end component;
	signal mul_a : std_logic_vector(nbits-1 downto 0);
	signal mul_b : std_logic_vector(nbits-1 downto 0);
	signal mul_clk : std_logic;
	signal mul_start : std_logic;
	signal mul_done : std_logic;
	signal mul_y : std_logic_vector((2*nbits)-1 downto 0);

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
	-- NOTE: the mod operation has to operate on twice the nbits
	signal mod_a : std_logic_vector((2*nbits)-1 downto 0);
	signal mod_p : std_logic_vector((2*nbits)-1 downto 0);
	signal mod_r : std_logic_vector((2*nbits)-1 downto 0);
	signal mod_start : std_logic;
	signal mod_clk : std_logic;
	signal mod_done : std_logic;
	signal mod_diverr : std_logic;

	type state_t is (
		SLEEP,
		DO_MULTIPLY,
		DO_MOD,
		MOD_FINISHED,
		DONE_ERROR
	);
	signal state : state_t := SLEEP;

begin
	mul : Math_SerialMul generic map (nbits => nbits)
	port map (
		a => mul_a,
		b => mul_b,
		clk => mul_clk,
		start => mul_start,
		y => mul_y,
		done => mul_done
	);

	modder : Math_Mod generic map (nbits => 2*nbits)
	port map (
		a => mod_a,
		p => mod_p,
		r => mod_r,
		start => mod_start,
		clk => mod_clk,
		done => mod_done,
		div_error => mod_diverr
	);
	-- =================================================
	mul_a <= a;
	mul_b <= b;
	mul_clk <= clk;
	mod_a <= mul_y;
	mod_p((2*nbits)-1 downto nbits) <= (others => '0');
	mod_p(nbits-1 downto 0) <= n;
	mod_clk <= clk;
	product <= mod_r(nbits-1 downto 0);
	-- =================================================
	fsm : process(clk)
	begin
		if (rising_edge(clk)) then
			case state is
			when SLEEP =>
				if (start = '1') then
					state <= DO_MULTIPLY;
				else
					state <= SLEEP;
				end if;
			when DO_MULTIPLY =>
				if (mul_done = '1') then
					state <= DO_MOD;
				else
					state <= DO_MULTIPLY;
				end if;
			when DO_MOD =>
				if (mod_done = '1') then
					if (mod_diverr = '1') then
						state <= DONE_ERROR;
					else
						state <= MOD_FINISHED;
					end if;
				else
					state <= DO_MOD;
				end if;
			when MOD_FINISHED =>
				if (start = '1') then
					state <= MOD_FINISHED;
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
				state <= DONE_ERROR;
			end case;
		end if;
	end process;

	datapath : process(state)
	begin
		case state is
		when SLEEP =>
			mul_start <= '0';
			mod_start <= '0';
			done <= '0';
			moderror <= '0';
		when DO_MULTIPLY =>
			mul_start <= '1';
			mod_start <= '0';
			done <= '0';
			moderror <= '0';
		when DO_MOD =>
			mul_start <= '0';
			mod_start <= '1';
			done <= '0';
			moderror <= '0';
		when MOD_FINISHED =>
			mul_start <= '0';
			mod_start <= '0';
			done <= '1';
			moderror <= '0';
		when DONE_ERROR =>
			mul_start <= '0';
			mod_start <= '0';
			done <= '1';
			moderror <= '1';
		when others =>
			mul_start <= '0';
			mod_start <= '0';
			done <= '0';
			moderror <= '1';
		end case;
	end process;
end rtl;
