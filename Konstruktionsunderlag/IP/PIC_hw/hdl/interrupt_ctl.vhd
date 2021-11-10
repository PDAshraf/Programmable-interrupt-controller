-------------------------------------------------------------------------------
--
-- Företag           : AGSTU AB 
-- Författare        : Ashraf Tumah
-- 
-- Skapad            : 2021-09-11
-- Designnamn        : interrupt_ctl
-- Enhet             : DE10-Lite 10M50DAF484C7G
-- Verktygsversion   : Quartus Prime 18.1 och ModelSim 10.5b
-- Testbänk          : 
-- DO file           : 
--
-- Beskrivning :
--    Topnivån för interrupt kontrollern
--    består av komponenter -
--      interrupt_counter och interrupt_sender
--  
--
--
-- Insignaler:
--    clk                     :  Systemklocka 50 MHz
--    reset_n                 :  SystemReset
--    enable                  :  Enable till vilket startar räknaren i komponent-interrupt_counter
--    intr_enable             :  Enable vilket aktiverar interrupt 0,1 och 2. Anslutna till Switchar 0,1 och 2
--    data_0, data_1, data_2  :  Interrupt Data för interrupt 0,1 och 2.(Räknarvärde innan en interrupt genereras)
--    acknowledge             :  Acknowledge signalen för att medla - ISR utförd återställ interrupt ut.
--
-- Utsignaler:
--    intr_queue              :  Om en interrupt är aktiv lyser diod(6 downto 4) för att indikera "kö"
--    intr_present            :  Visar på lysdiod (2 downto 0) vilken interruptbit som genererat interruptsignalen
--    interrupt               :  Interrupt signal ut
--    interrupt_data          :  Antal genererade interruptsignaler
--
-------------------------------------------------------------------------------

library  ieee;
use ieee.std_logic_1164.all;


entity interrupt_ctl is
   port
      (
         clk      :  in std_logic;
         reset_n  :  in std_logic;
         enable   :  in std_logic;
         
         intr_enable    :  in std_logic_vector(2 downto 0);
         intr_queue     :  out std_logic_vector(2 downto 0);
         intr_present   :  out std_logic_vector(2 downto 0); 
         
         data_0            :  in std_logic_vector(31 downto 0);      
         data_1            :  in std_logic_vector(31 downto 0);      
         data_2            :  in std_logic_vector(31 downto 0);
         
         interrupt      :  out std_logic;
         acknowledge    :  in  std_logic;
         
         interrupt_data :  out std_logic_vector(15 downto 0)
      );
end interrupt_ctl;


architecture rtl of interrupt_ctl is

   component interrupt_counter is
   port
      (
         reset_n              :  in std_logic;
         clk                  :  in std_logic;
         enable               :  in std_logic;
      
         ir_data_0            :  in std_logic_vector(31 downto 0);      
         ir_data_1            :  in std_logic_vector(31 downto 0);      
         ir_data_2            :  in std_logic_vector(31 downto 0);
         
         intr_out             :  out std_logic_vector(2 downto 0)
      );
   end component;

   component interrupt_sender
   port(
      clk      :  in std_logic;
      reset_n  :  in std_logic;
      
      intr_enable    :  in std_logic_vector(2 downto 0);
      intr_request   :  in std_logic_vector(2 downto 0);
      intr_queue     :  out std_logic_vector(2 downto 0);
      intr_present   :  out std_logic_vector(2 downto 0); 
      
      interrupt      :  out std_logic;
      acknowledge    :  in  std_logic;
      intr_data      :  out std_logic_vector(15 downto 0)
      );
   end component;
   
   signal s_interrupt : std_logic_vector(2 downto 0);
   
begin
   
      C1 : interrupt_counter
      port map(
         reset_n     => reset_n,
         clk         => clk,
         enable      => enable,
         ir_data_0   => data_0,
         ir_data_1   => data_1,
         ir_data_2   => data_2,
         intr_out    => s_interrupt
      );
      
   C2 :  interrupt_sender
      port map(
         clk            => clk,
         reset_n        => reset_n,
         intr_enable    => intr_enable,
         intr_request   => s_interrupt,
         intr_queue     => intr_queue,
         intr_present   => intr_present,
         interrupt      => interrupt,
         acknowledge    => acknowledge,
         intr_data      => interrupt_data
      );

end rtl;