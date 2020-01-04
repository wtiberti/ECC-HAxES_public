-- Component: tb_Math_Add
-- Desc: Testbed for the Math_Add component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Add is
end tb_Math_Add;

architecture rtl of tb_Math_Add is
	component Math_Add is
	generic (
		nbits : integer := 16
	);
	port (
		carryin : in std_logic;
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		sum : out std_logic_vector(nbits-1 downto 0);
		carryout : out std_logic
	);
	end component;
	signal A : std_logic_vector(31 downto 0);
	signal B : std_logic_vector(31 downto 0);
	signal SUM : std_logic_vector(31 downto 0);
	signal CO : std_logic;
	signal CI : std_logic;

begin
	uut : Math_Add generic map (nbits => 32)
	port map (
		carryin => CI,
		a => A,
		b => B,
		sum => SUM,
		carryout => CO
	);

	stim: process
	begin
	CI <= '0';
	A <= x"00200010";
	B <= x"0010000A";
	wait for 1 ns;
	A <= x"12345678";
	B <= x"09876543";
	wait for 1 ns;
	wait;
	end process;
end rtl;
