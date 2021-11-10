

library ieee;
use ieee.std_logic_1164.all;

entity interrupt_project is
   port
      (
      MAX10_CLK1_50  :  in std_logic;
      KEY            :  in std_logic_vector(1 downto 0);
      SW             :  in std_logic_vector(9 downto 0);
      LEDR           :  out std_logic_vector(9 downto 0)
      );
end entity;


architecture rtl of interrupt_project is



   component nios
      port (
         clk_clk                    : in  std_logic                    := '0';             --              clk.clk
         ir_ip_exp_en_exp           : in  std_logic                    := '0';             --        ir_ip_exp.en_exp
         ir_ip_exp_intr_en_exp      : in  std_logic_vector(2 downto 0) := (others => '0'); --                 .intr_en_exp
         ir_ip_exp_intr_present_exp : out std_logic_vector(2 downto 0);                    --                 .intr_present_exp
         ir_ip_exp_intr_queue_exp   : out std_logic_vector(2 downto 0);                    --                 .intr_queue_exp
         key_pio_external_export    : in  std_logic_vector(1 downto 0) := (others => '0'); -- key_pio_external.export
         reset_reset_n              : in  std_logic                    := '0'              --            reset.reset_n
      );
   end component nios;

      
begin


   inst_nios : nios
      port map
         (
         clk_clk                          =>    MAX10_CLK1_50,
         ir_ip_exp_en_exp                 =>    SW(8),
         ir_ip_exp_intr_en_exp            =>    SW(2 downto 0),
         ir_ip_exp_intr_present_exp       =>    LEDR(2 downto 0),
         ir_ip_exp_intr_queue_exp         =>    LEDR(6 downto 4),
         key_pio_external_export          =>    KEY,
         reset_reset_n                    =>    SW(9)
         );


end rtl;