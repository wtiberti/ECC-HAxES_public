-- Component: RegisterBank
-- Desc: an addressable bank of PIPO registers
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterBank is
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
end RegisterBank;

architecture rtl of RegisterBank is
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

	subtype tmp is std_logic_vector(nbits-1 downto 0);
	type mem_t is array(integer range 0 to 2**address_lines-1) of tmp;
	signal pipos_out : mem_t;
	signal pipos_in : std_logic_vector(nbits-1 downto 0);
	signal pipos_wr_clk : std_logic_vector(2**address_lines-1 downto 0);
begin
	pipo_generate : for i in 0 to (2**address_lines) generate
		pipos : Reg_PIPO generic map (nbits => nbits)
		port map (
			input => pipos_in,
			clk => pipos_wr_clk(i),
			rst => '0',
			output => pipos_out(i)
		);
	end generate;

	pipos_in <= din;
	dout <= pipos_out(to_integer(unsigned(addr)));
	pipos_wr_clk(to_integer(unsigned(addr))) <= wr_clk;
end rtl;
