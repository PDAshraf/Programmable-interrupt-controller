-------------------------------------------------------------------------------
--
-- Företag           : AGSTU AB 
-- Författare        : Ashraf Tumah
-- 
-- Skapad            : 2021-09-11
-- Designnamn        : interrupt_counter
-- Enhet             : DE10-Lite 10M50DAF484C7G
-- Verktygsversion   : Quartus Prime 18.1 och ModelSim 10.5b
-- Testbänk          : 
-- DO file           : 
--
-- Beskrivning :
--    Räknarkomponent, genererar interruptsignal(2 downto 0) då
--       räknaren når det angivna värdet för respektive interrupt
--      
--  
--
--
-- Insignaler:
--    clk                           :  Systemklocka 50 MHz
--    reset_n                       :  SystemReset
--    enable                        :  Enable till vilket startar räknaren i komponent-interrupt_counter
--    ir_data_0,ir_data_1,ir_data_2 :  In data(Räknarvärde)
--
-- Utsignaler:
--    intr_out                      :  Genererad interruptsignal från respektive ir ut
--    intr_data                     :  Antal genererad interruptsignal
--
-------------------------------------------------------------------------------

library ieee;
use   ieee.std_logic_1164.all;
use   ieee.numeric_std.all;

entity interrupt_counter is
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
end interrupt_counter;



architecture rtl of interrupt_counter is

   signal rst_n_t1, rst_n_t2  : std_logic;
   signal cnt_0,cnt_1,cnt_2   : unsigned(31 downto 0);
   signal s_shift_reg         : std_logic_vector(2 downto 0);
   signal s_intr              : std_logic_vector(2 downto 0);
   
   
begin

   ----Meta-Reset---
   reset : process(reset_n,clk)
   begin
      if reset_n ='1' then
         rst_n_t1 <='1';
         rst_n_t2 <='1';
      elsif rising_edge(clk) then
         rst_n_t1 <= '0';
         rst_n_t2 <= rst_n_t1;
      end if;
   end process;
   ----Meta-Reset---
   

   
   ----Interrupt Process-----
   ir :  process(clk,rst_n_t2)
   begin
      if rst_n_t2='0' then
         s_intr   <=(others=>'0');
         cnt_0    <=(others=>'0');
         cnt_1    <=(others=>'0');
         cnt_2    <=(others=>'0');
      elsif rising_edge(clk) then
         if enable ='1' then
      ---Om räknaren når respektive intr data värde 
      ---genereras en IRQ för respektive interrupt(2 downto 0).
         if cnt_0 = unsigned(ir_data_0) then
               s_intr(0)   <= '1';
               cnt_0       <= (others=>'0');
            else
               s_intr(0)   <='0';
               cnt_0 <= cnt_0+1;
            end if;
            
            if cnt_1 = unsigned(ir_data_1) then
               s_intr(1)   <= '1';
               cnt_1       <= (others=>'0');
            else
               cnt_1 <= cnt_1+1;
               s_intr(1)   <='0';
            end if;
            
            if cnt_2 = unsigned(ir_data_2) then
               s_intr(2)   <= '1';
               cnt_2    <= (others=>'0');
            else
               cnt_2 <= cnt_2+1;
               s_intr(2)   <='0';
            end if;
         else
            cnt_0  <= (others=>'0');
            cnt_1  <= (others=>'0');
            cnt_2  <= (others=>'0');
         end if;
      end if;
   end process;
   
   intr_out <= s_intr;
   
end rtl;