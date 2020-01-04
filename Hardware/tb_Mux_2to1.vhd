-- Component: tb_Mux_2to1
-- Desc: Testbed for the Mux_2to1 component
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity tb_Mux_2to1 is
end tb_Mux_2to1;

architecture rtl of tb_Mux_2to1 is
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
	signal v0 : std_logic_vector(15 downto 0);
	signal v1 : std_logic_vector(15 downto 0);
	signal mux_sel : std_logic;
	signal mux_out : std_logic_vector(15 downto 0);
begin
	uut : Mux_2to1 generic map (nbits => 16)
	port map (
		input0 => v0,
		input1 => v1,
		sel => mux_sel,
		output => mux_out
	);

	stim_proc : process
	begin
		v0 <= x"DEAD";
		v1 <= x"BEEF";
		mux_sel <= '0';
		wait for 1 ns;
		mux_sel <= '1';
		wait for 1 ns;
		v1 <= x"BABE";
		wait for 5 ns;
		wait;
	end process;
end rtl;
