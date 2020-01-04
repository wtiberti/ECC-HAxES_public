-- Component: tb_ORreduce
-- Desc: testbench for ORreduce
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_ORreduce is
end tb_ORreduce;

architecture rtl of tb_ORreduce is
	component ORreduce is
	generic (
		nbits : integer := 32;
		do_invert : boolean := false
	);
	port (
		input : in std_logic_vector(nbits-1 downto 0);
		output : out std_logic
	);
	end component;
	signal uut1_in : std_logic_vector(191 downto 0);
	signal uut2_in : std_logic_vector(191 downto 0);
	signal uut1_out : std_logic;
	signal uut2_out : std_logic;
begin
	uut1 : ORreduce generic map (192, false) port map (uut1_in, uut1_out);
	uut2 : ORreduce generic map (192, true) port map (uut2_in, uut2_out);

	stimproc : process
	begin
		uut1_in <= (others => '0');
		uut2_in <= (others => '0');
		wait for 10 ns;
		uut1_in <= (others => '1');
		uut2_in <= (others => '1');
		wait for 10 ns;
		wait;
	end process;
end rtl;
