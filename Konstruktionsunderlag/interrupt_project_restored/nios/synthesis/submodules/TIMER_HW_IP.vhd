
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


ENTITY TIMER_HW_IP IS
	PORT
	(
		reset_n 	: IN std_logic;
		clk 		: IN std_logic;
		cs_n 		: IN std_logic; -- IP component address
		addr 		: IN std_logic_vector(1 downto 0); -- offset address
		-- need one address, two be sure we add one extra bit (4 addresses a 4 bytes)
		write_n 	: IN std_logic;
		read_n 	: IN std_logic;
		din 		: IN std_logic_vector(31 DOWNTO 0);
		-- need only two bits, but the wrapper require same number of bits for din and dout
		dout 		: OUT std_logic_vector(31 DOWNTO 0)
	);
END TIMER_HW_IP;

ARCHITECTURE rtl of TIMER_HW_IP IS

	SIGNAL data_reg		: std_logic_vector(31 downto 0);
	SIGNAL control_reg	: std_logic_vector(1 downto 0);
	
	COMPONENT timer_top
		port
		(
			control_timer	:	in std_logic_vector(1 downto 0);
			clk				:	in std_logic;
			reset_n			: 	in std_logic;
			timer_data		:	inout std_logic_vector(31 downto 0)
		);
	END COMPONENT;

BEGIN

	bus_register_write_process:
	process(clk,reset_n)
	begin
		if (reset_n = '0') then
			control_reg <= (others=>'0');
		elsif rising_edge(clk) then
			if(cs_n='0' and write_n='0' and addr="01") then
				control_reg(1 downto 0) <= din(31 downto 30);
				--CPU write to control
			else
				null;
			end if;
		else
			null;
		end if;
	end process;
	
	bus_register_read_process:
	process(cs_n,read_n,addr)
	begin
		if(cs_n='0' and read_n='0' and addr="00") then
			dout<=data_reg; ---- Time Read
		else 
			dout <= (others=>'X');
		end if;
	end process;
	
	timer_function : timer_top
		port map
			(
			  control_timer => control_reg,
			  clk 			 => clk,
			  reset_n		 => reset_n,
			  timer_data	 => data_reg
 			);

END rtl;