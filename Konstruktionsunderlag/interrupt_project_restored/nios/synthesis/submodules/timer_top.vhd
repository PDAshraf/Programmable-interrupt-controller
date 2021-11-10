
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity timer_top is
	port
		(
		 control_timer	: in std_logic_vector(1 downto 0);
		 clk 				: IN std_logic;
		 reset_n 		: IN std_logic;
		 timer_data 	: INOUT std_logic_vector(31 DOWNTO 0)
		);
end timer_top;

architecture rtl of timer_top is


begin

	HW_function_process:
	process(clk,reset_n)
	begin
		if reset_n='0' then
			timer_data <=(others=>'0');
		elsif rising_edge(clk) then
			case control_timer is
				--Start Timer--
				when "10"=> timer_data<= 1 + timer_data;
				
				--Stop Timer--
				when "00" => 
					timer_data <= timer_data;
				
				--Reset Timer--
				when "01"=>
					timer_data <= (others=>'0');
					
				when others => null;
			end case;
		end if;
	end process;
	
end rtl;