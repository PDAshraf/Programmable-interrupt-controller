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
-- Beskrivning:
--    Komponenten innehåller en prioriterad avkodare för interruptbitar.
--       Intr_queue ansluten till Lysdiod(6 downto 4) för att indikera 
--          vilken interrupt som är i väntan på att generera en IRQ.
--
--       Intr_present ansluten till Lysdiod(2 downto 0) för att indikera 
--          vilken interrupt som genererat en IRQ.
--       
--       
--  
-- Insignaler:
--    clk                     :  Systemklocka 50 MHz
--    reset_n                 :  SystemReset
--    intr_enable             :  Enable vilket aktiverar interrupt 0,1 och 2. Anslutna till Switchar 0,1 och 2
--    intr_request            :  Interruptsignal från interrupt_counter komponenten
--    acknowledge             :  Acknowledge signalen för att medla - ISR utförd, återställ interrupt ut.
--
-- Utsignaler:
--    intr_queue              :  Om en interrupt är aktiv lyser diod(6 downto 4) för att indikera "kö"
--    intr_present            :  Visar på lysdiod (2 downto 0) vilken interruptbit som genererat interruptsignalen
--    interrupt               :  Interrupt signal ut
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interrupt_sender is
   port(
      clk      :  in std_logic;
      reset_n  :  in std_logic;
      
      intr_enable    :  in std_logic_vector(2 downto 0);
      intr_request   :  in std_logic_vector(2 downto 0);
      intr_queue     :  out std_logic_vector(2 downto 0);
      intr_present   :  out std_logic_vector(2 downto 0); 
      
      interrupt      :  out std_logic;
      acknowledge    :  in  std_logic;
      
      intr_data            :  out std_logic_vector(15 downto 0)
      );
end interrupt_sender;


architecture rtl of interrupt_sender is
      
   signal   s_shift_reg                      :  std_logic_vector(7 downto 0);
   signal   s_intr_queue,  s_intr_present    :  std_logic_vector(intr_request'range);
   signal   s_interrupt                      :  std_logic;
   signal   rst_n_t1, rst_n_t2,ack_t1,ack_t2 :  std_logic;
   signal   intr_cnt                         : unsigned(15 downto 0);
   
   -- Prioriterad avkodare
   --  Vektor för alla väntande interrupts. Resultatet vektor med där lägst bit hat högst prio
  function priority_decode(intr_queue : std_logic_vector) return std_logic_vector is
    variable result   : std_logic_vector(intr_queue'range);
    variable or_chain : std_logic;
  begin

   -- Lägst bit = högst prio
    result(intr_queue'low) := intr_queue(intr_queue'low);
    or_chain := result(intr_queue'low);

    -- Loop för att kontrollera IRQs i tur
    for i in intr_queue'low + 1 to intr_queue'high loop
      if intr_queue(i) = '1' and or_chain = '0' then
        result(i) := '1';
      else
        result(i) := '0';
      end if;
      or_chain := or_chain or intr_queue(i);
    end loop;
    return result;
  end function;

   
begin

   
   
   meta_reset  :  process(clk,reset_n)
   begin
      if reset_n = '1' then
         rst_n_t1 <= '1';
         rst_n_t2 <= '1';
      elsif rising_edge(clk) then
         rst_n_t1 <= '0';
         rst_n_t2 <= rst_n_t1;
      end if;
   end process;
   
   
   ic: process(clk,rst_n_t2) is
    variable clear_int_n, queue_v, present_v : std_logic_vector(intr_queue'range);
    variable interrupt_v : std_ulogic;
  begin
    if rst_n_t2 = '0' then
      s_intr_queue   <= (others => '0');
      s_intr_present <= (others => '0');
      s_interrupt <= '0';
    elsif rising_edge(clk) then

      if Acknowledge = '1' then
        clear_int_n := not s_intr_present;
      else
        clear_int_n := (others => '1');
      end if;

      -- Håll koll på avvaktande intr , användaren inaktiverar passiv avbrott och rensar avbrott efter isr-acknowledge.
      queue_v := (intr_request or s_intr_queue) and intr_enable and clear_int_n;
      s_intr_queue<= queue_v;

      -- Fastställer den aktiva interrupten från de i kön
      present_v := priority_decode(queue_v);
      s_intr_present <= present_v;

--      -- -- Flagga när en interrupt är aktiv 
--      interrupt_v := or_reduce(present_v);
--      s_interrupt <= interrupt_v;
      if present_v  = "000" then
         s_interrupt <='0';
      else
         s_interrupt <='1';
      end if;

      if s_interrupt = '0' or (s_interrupt = '1' and Acknowledge = '1') then
        -- Uppdatera intr
        s_intr_present <= present_v;
      end if;
    end if;
  end process;
  
  interrupt_count : process(rst_n_t2,Acknowledge)
  begin
   if rst_n_t2 ='0' then
      intr_cnt <=(others=>'0');
   elsif rising_edge(Acknowledge) then
      if intr_cnt>=60000 then
         intr_cnt <=(others=>'0');
      else
         intr_cnt <= intr_cnt +1;
      end if;
    end if;
   end process;
  

  intr_present <= s_intr_present;
  intr_queue   <= s_intr_queue;
  interrupt    <= s_interrupt;
  intr_data    <= std_logic_vector(intr_cnt);
end rtl;