-- Component: Reg_PIxO
-- Desc: A generic PIxO register with selectable shift step and direction
-- Author: Walter Tiberti <walter.tiberti@graduate.univaq.it>

library ieee;
use ieee.std_logic_1164.all;

entity Reg_PIxO is
generic (
	nbits : integer := 16;
	shift_direction : character := 'l';
	shift_step : integer := 1
);
port (
	input : in std_logic_vector(nbits-1 downto 0);
	clk : in std_logic;
	mode : in std_logic; -- 0 = parallel load, 1 = shift
	output : out std_logic_vector(nbits-1 downto 0);
	serial_input : in std_logic;
	serial_output : out std_logic
);
end Reg_PIxO;

architecture rtl of Reg_PIxO is
	signal value : std_logic_vector(nbits-1 downto 0);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if mode = '0' then
				value <= input;
			else
				if shift_direction = 'l' then
					for i in nbits-shift_step-1 downto 0 loop
						value(i+shift_step) <= value(i);
					end loop;
					for i in 0 to shift_step-1 loop
						value(i) <= serial_input;
					end loop;
				end if;

				if shift_direction = 'r' then
					for i in nbits-1 downto shift_step loop
						value(i-shift_step) <= value(i);
					end loop;
					for i in nbits-1 downto nbits-shift_step loop
						value(i) <= serial_input;
					end loop;
				end if;
			end if;
		end if;
	end process;

	output <= value;

	s_out_1: if shift_direction = 'l' generate
		serial_output <= value(nbits-1);
	end generate;

	s_out_2: if shift_direction = 'r' generate
		serial_output <= value(0);
	end generate;
end rtl;
