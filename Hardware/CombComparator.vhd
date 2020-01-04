-- Component: CombComparator
-- Desc: A ripple combinatorial comparator
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity CombComparator is
generic (
	nbits : integer := 32
);
port (
	op1 : in std_logic_vector(nbits-1 downto 0);
	op2 : in std_logic_vector(nbits-1 downto 0);
	gt : out std_logic;
	eq : out std_logic;
	lt : out std_logic
);
end CombComparator;

architecture rtl of CombComparator is
	signal eq_results : std_logic_vector(nbits-1 downto 0);
	signal gt_results : std_logic_vector(nbits-1 downto 0);
begin
	eq_results(nbits-1) <= (op1(nbits-1) xnor op2(nbits-1));
	gt_results(nbits-1) <= op1(nbits-1) and (not op2(nbits-1));
	ripples : for i in nbits-2 downto 0 generate
		eq_results(i) <= eq_results(i+1) and (op1(i) xnor op2(i));
		gt_results(i) <= gt_results(i+1) or (op1(i) and (not op2(i)) and eq_results(i+1));
	end generate;
	eq <= eq_results(0);
	gt <= gt_results(0);
	lt <= eq_results(0) nor gt_results(0);
end rtl;
