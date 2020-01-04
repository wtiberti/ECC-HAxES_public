-- Component: tb_Math_Mul
-- Desc: testbench for Math_Mul
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Math_Mul is
end tb_Math_Mul;

architecture rtl of tb_Math_Mul is
	component Math_Mul is
	generic (
		nbits : integer := 16
	);
	port (
		a : in std_logic_vector(nbits-1 downto 0);
		b : in std_logic_vector(nbits-1 downto 0);
		product : out std_logic_vector((2*nbits)-1 downto 0)
	);
	end component;
	signal mul_a : std_logic_vector(7 downto 0);
	signal mul_b : std_logic_vector(7 downto 0);
	signal mul_p : std_logic_vector(15 downto 0);
begin
	uut : Math_Mul generic map (nbits => 8)
	port map (
		a => mul_a,
		b => mul_b,
		product => mul_p
	);

	stimproc : process
	begin
		mul_a <= x"10";
		mul_b <= x"77";
		wait for 20 ns;
		mul_a <= x"FF";
		mul_b <= x"17";
		wait for 20 ns;
		mul_a <= x"17";
		mul_b <= x"00";
		wait for 20 ns;
		mul_a <= x"99";
		mul_b <= x"01";
		wait for 20 ns;
		wait;
	end process;
end rtl;
