-- Component: tb_Math_Sub
-- Desc: Testbed for the Math_Sub component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Sub is
end tb_Math_Sub;

architecture rtl of tb_Math_Sub is
	component Math_Sub is
	generic (
		nbits : integer := 16
	);
	port (
		A : in std_logic_vector(nbits-1 downto 0);
		B : in std_logic_vector(nbits-1 downto 0);
		Borrow_in : in std_logic;
		Diff : out std_logic_vector(nbits-1 downto 0);
		Borrow_out : out std_logic
	);
	end component;

	signal A : std_logic_vector(31 downto 0);
	signal B : std_logic_vector(31 downto 0);
	signal DIFF : std_logic_vector(31 downto 0);
	signal BO : std_logic;
	signal BI : std_logic;

begin
	uut : Math_Sub generic map (nbits => 32)
	port map (
		A => A,
		B => B,
		Borrow_in => BI,
		Diff => DIFF,
		Borrow_out => BO
	);

	stim: process
	begin
	BI <= '0';
	A <= x"00200010";
	B <= x"0010000A";
	wait for 1 ns;
	A <= x"12345678";
	B <= x"09876543";
	wait for 1 ns;
	wait;
	end process;
end rtl;
