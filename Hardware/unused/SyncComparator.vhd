-- Component: SyncComparator
-- Desc: A shift-based comparator (compare the higher bits each iteration)
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity SyncComparator is
generic (
	nbits : integer := 16
);
port (
	op1 : in std_logic_vector(nbits-1 downto 0);
	op2 : in std_logic_vector(nbits-1 downto 0);
	start : in std_logic;
	clk : in std_logic;
	greater_than : out std_logic;
	done : out std_logic
);
end SyncComparator;

architecture rtl of SyncComparator is
	component Reg_PIxO is
	generic (
		nbits : integer := 16;
		shift_direction : character := 'l'
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

	signal pixo1_input : std_logic_vector(nbits-1 downto 0);
	signal pixo1_clk : std_logic;
	signal pixo1_mode : std_logic;
	signal pixo1_output : std_logic;
	signal empty1 : std_logic_vector(nbits-1 downto 0);

	signal pixo2_input : std_logic_vector(nbits-1 downto 0);
	signal pixo2_clk : std_logic;
	signal pixo2_mode : std_logic;
	signal pixo2_output : std_logic;
	signal empty2 : std_logic_vector(nbits-1 downto 0);

	type state_t is (SLEEP,
			INIT,
			SHIFTING1,
			SHIFTING2,
			FINISH_GT,
			FINISH_LTE
	);
	signal state : state_t := SLEEP;
begin
	pixo1 : Reg_PIxO
	generic map (
		nbits => nbits,
		shift_direction => 'l'
	)
	port map (
		input => pixo1_input,
		clk => pixo1_clk,
		mode => pixo1_mode,
		output => empty1,
		serial_input => '0',
		serial_output => pixo1_output
	);

	pixo2 : Reg_PIxO
	generic map (
		nbits => nbits,
		shift_direction => 'l'
	)
	port map (
		input => pixo2_input,
		clk => pixo2_clk,
		mode => pixo2_mode,
		output => empty2,
		serial_input => '1', -- to stop without a counter
		serial_output => pixo2_output
	);

	pixo1_input <= op1;
	pixo2_input <= op2;

	f_x : process(clk)
	begin
		if rising_edge(clk) then
			case state is
			when SLEEP =>
				if start = '1' then
					state <= INIT;
				else
					state <= SLEEP;
				end if;
			when INIT =>
				state <= SHIFTING1;
			when SHIFTING1 =>
				if pixo1_output = '1' and pixo2_output = '0' then
					state <= FINISH_GT;
				elsif (pixo1_output xor pixo2_output) = '0' then
					state <= SHIFTING2;
				else
					state <= FINISH_LTE;
				end if;
			when SHIFTING2 =>
				if pixo1_output = '1' and pixo2_output = '0' then
					state <= FINISH_GT;
				elsif (pixo1_output xor pixo2_output) = '0' then
					state <= SHIFTING1;
				else
					state <= FINISH_LTE;
				end if;
			when FINISH_GT =>
				if start = '0' then
					state <= SLEEP;
				else
					state <= FINISH_GT;
				end if;
			when FINISH_LTE =>
				if start = '0' then
					state <= SLEEP;
				else
					state <= FINISH_GT;
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
			pixo1_mode <= '0';
			pixo2_mode <= '0';
			pixo1_clk <= '0';
			pixo2_clk <= '0';
			done <= '0';
			greater_than <= '0';
		when INIT =>
			pixo1_mode <= '0';
			pixo2_mode <= '0';
			pixo1_clk <= '1';
			pixo2_clk <= '1';
			done <= '0';
			greater_than <= '0';
		when SHIFTING1 =>
			pixo1_mode <= '1';
			pixo2_mode <= '1';
			pixo1_clk <= '0';
			pixo2_clk <= '0';
			done <= '0';
			greater_than <= '0';
		when SHIFTING2 =>
			pixo1_mode <= '1';
			pixo2_mode <= '1';
			pixo1_clk <= '1';
			pixo2_clk <= '1';
			done <= '0';
			greater_than <= '0';
		when FINISH_GT =>
			pixo1_mode <= '1';
			pixo2_mode <= '1';
			pixo1_clk <= '0';
			pixo2_clk <= '0';
			done <= '1';
			greater_than <= '1';
		when FINISH_LTE =>
			pixo1_mode <= '1';
			pixo2_mode <= '1';
			pixo1_clk <= '0';
			pixo2_clk <= '0';
			done <= '1';
			greater_than <= '0';
		when others =>
			pixo1_mode <= '0';
			pixo2_mode <= '0';
			pixo1_clk <= '0';
			pixo2_clk <= '0';
			done <= '0';
			greater_than <= '0';
		end case;
	end process;
end rtl;
