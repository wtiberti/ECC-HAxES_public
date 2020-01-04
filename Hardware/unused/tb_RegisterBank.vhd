-- Component: tb_RegisterBank
-- Desc: testbench for RegisterBank
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_RegisterBank is
end tb_RegisterBank;

architecture rtl of tb_RegisterBank is
	component RegisterBank is
	generic (
		nbits : integer := 32;
		address_lines : integer := 6
	);
	port (
		addr : in std_logic_vector(address_lines-1 downto 0);
		din : in std_logic_vector(nbits-1 downto 0);
		dout : out std_logic_vector(nbits-1 downto 0);
		wr_clk : in std_logic
	);
	end component;
	signal uut_addr : std_logic_vector(5 downto 0);
	signal uut_din : std_logic_vector(31 downto 0);
	signal uut_dout : std_logic_vector(31 downto 0);
	signal uut_clk : std_logic;
begin
	uut : RegisterBank generic map (nbits => 32, address_lines => 6) port map (uut_addr, uut_din, uut_dout, uut_clk);
	stimproc : process
	begin
		uut_clk <= '0';
		uut_addr <= "000000";
		uut_din <= x"11111111";
		wait for 10 ns;
		uut_clk <= '1';
		wait for 10 ns;
		uut_clk <= '0';
		uut_addr <= "000001";
		uut_din <= x"22222222";
		wait for 10 ns;
		uut_clk <= '1';
		wait for 10 ns;
		uut_clk <= '0';
		uut_addr <= "000010";
		uut_din <= x"33333333";
		wait for 10 ns;
		uut_clk <= '1';
		wait for 10 ns;
		uut_clk <= '0';
		uut_addr <= "000011";
		uut_din <= x"44444444";
		wait for 10 ns;
		uut_clk <= '1';
		wait for 10 ns;
		uut_clk <= '0';

		wait for 30 ns;
		uut_addr <= "000000";
		wait for 1 ns;
		uut_addr <= "000001";
		wait for 1 ns;
		uut_addr <= "000010";
		wait for 1 ns;
		uut_addr <= "000011";
		wait for 1 ns;
		uut_addr <= "111111";
		wait for 1 ns;
		wait;
	end process;
end rtl;
