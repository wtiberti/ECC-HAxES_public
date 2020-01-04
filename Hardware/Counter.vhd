library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
generic (
	nbits : integer := 16;
	increment : integer := -1
);
port (
	pr_value : in std_logic_vector(nbits-1 downto 0);
	value : out std_logic_vector(nbits-1 downto 0);
	clk : in std_logic;
	rst : in std_logic
);
end Counter;

architecture rtl of Counter is
	signal cnt_state : std_logic_vector(nbits-1 downto 0);
begin
	process(clk, rst)
		variable v : integer;
	begin
		if (rst = '1') then
			cnt_state <= pr_value;
		elsif (rising_edge(clk)) then
			v := to_integer(unsigned(cnt_state));
			v := v + increment;
			cnt_state <= std_logic_vector(to_unsigned(v, nbits));
		end if;
		value <= cnt_state;
	end process;
end rtl;
