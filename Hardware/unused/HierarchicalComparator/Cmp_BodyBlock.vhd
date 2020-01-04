-- Component: Cmp_BodyBlock
-- Desc: The first block in the heirarchical comparator
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Cmp_BodyBlock is
port (
	gt1 : in std_logic;
	eq1 : in std_logic;
	gt2 : in std_logic;
	eq2 : in std_logic;
	gt : out std_logic;
	eq : out std_logic
);
end Cmp_BodyBlock;

architecture rtl of Cmp_BodyBlock is
begin
	-- if both eq signal are 1, eq = 1
	eq <= eq1 and eq2;
	-- gt is asserted only when:
	-- 1) gt1 == 1
	-- 2) eq1 = 1 & gt2 == 1
	gt <= gt1 or (eq1 and gt2);
end rtl;
