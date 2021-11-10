-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "09/20/2021 10:03:52"
                                                            
-- Vhdl Test Bench template for design  :  interrupt_ctl_hw_ip
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;  
USE ieee.numeric_std.all;                              

ENTITY interrupt_ctl_hw_ip_vhd_tst IS
END interrupt_ctl_hw_ip_vhd_tst;
ARCHITECTURE interrupt_ctl_hw_ip_arch OF interrupt_ctl_hw_ip_vhd_tst IS
	-- constants
	CONSTANT sys_clk_period	:	TIME := 20 ns;
	-- signals                                                   
	SIGNAL addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL clk : STD_LOGIC;
	SIGNAL cs_n : STD_LOGIC;
	SIGNAL din : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL dout : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL enable : STD_LOGIC;
	SIGNAL interrupt : STD_LOGIC;
	SIGNAL intr_enable : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL intr_present : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL intr_queue : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL read_n : STD_LOGIC;
	SIGNAL reset_n : STD_LOGIC;
	SIGNAL write_n : STD_LOGIC;
	
	COMPONENT interrupt_ctl_hw_ip
		PORT (
		addr : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		clk : IN STD_LOGIC;
		cs_n : IN STD_LOGIC;
		din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		enable : IN STD_LOGIC;
		interrupt : OUT STD_LOGIC;
		intr_enable : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		intr_present : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		intr_queue : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		read_n : IN STD_LOGIC;
		reset_n : IN STD_LOGIC;
		write_n : IN STD_LOGIC
		);
	END COMPONENT;
	
BEGIN
		i1 : interrupt_ctl_hw_ip
		PORT MAP (
	-- list connections between master ports and signals
		addr => addr,
		clk => clk,
		cs_n => cs_n,
		din => din,
		dout => dout,
		enable => enable,
		interrupt => interrupt,
		intr_enable => intr_enable,
		intr_present => intr_present,
		intr_queue => intr_queue,
		read_n => read_n,
		reset_n => reset_n,
		write_n => write_n
		);
		
	clock: process 
	begin -- Clock period 
		clk <= '0';
		WAIT FOR sys_clk_period/2; 
		clk <= '1';
		WAIT FOR sys_clk_period/2;
	end process clock;
	
	rst: process
	begin
		reset_n <= '0';
		WAIT FOR 5*sys_clk_period;
		reset_n <='1';
		wait;
	end process rst;
	
	---Interrupt Process---
	ir: process
	begin
		addr			<="00";
		cs_n 			<='0';
		read_n 		<='1';
		write_n 		<='1';
		enable 		<='0';
		intr_enable <="000";
		din	<=(others=>'0');
		wait for 10*sys_clk_period;
		enable 		<='1';
		intr_enable <="111"; -- Interrupt 1,2,3 Aktiv
		write_n <='0';
		addr	  <="01";
		
		------- tilldela IRQ olika värden-------
		din <= std_LOGIC_VECTOR(to_unsigned(50,din'length));
		wait for 10*sys_clk_period;
		if (interrupt='1') then
			addr	<="10";
			din(1)<='1';
		else
			NULL;
		end if;
		wait for 3*sys_clk_period;
		addr	<="10";
		din(1)<='1';
		wait for 1 us;
		
		write_n <='1';
		read_n  <='0';
		addr    <="00";
		
		wait for 1 us;
	end process ir;                                                                                  
END interrupt_ctl_hw_ip_arch;
