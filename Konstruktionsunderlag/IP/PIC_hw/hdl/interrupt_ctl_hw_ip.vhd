library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity interrupt_ctl_hw_ip is
   port
      (
         clk      :  in std_logic;
         reset_n  :  in std_logic;
         enable   :  in std_logic;
         
         --AvalonBus---
         cs_n     :  in std_logic;
         read_n   :  in std_logic;
         write_n  :  in std_logic;
         addr     :  in std_logic_vector(1 downto 0);
         din      :  in std_logic_vector(31 downto 0);
         dout     :  out std_logic_vector(31 downto 0);
         ------------
         
         intr_enable  : in std_logic_vector(2 downto 0); -- Enable interrupt
         intr_present : out std_logic_vector(2 downto 0);-- Current interrupt
         intr_queue   : out std_logic_vector(2 downto 0);-- Pending interrupt
         
         interrupt    : out std_logic                    --Interrupt Request to CPU
      );
end interrupt_ctl_hw_ip;

architecture rtl of interrupt_ctl_hw_ip is

   component interrupt_ctl
      port
         (
         clk            :  in std_logic;
         reset_n        :  in std_logic;
         enable         :  in std_logic;
         intr_enable    :  in std_logic_vector(2 downto 0);
         intr_queue     :  out std_logic_vector(2 downto 0);
         intr_present   :  out std_logic_vector(2 downto 0); 
         data_0         :  in std_logic_vector(31 downto 0);      
         data_1         :  in std_logic_vector(31 downto 0);      
         data_2         :  in std_logic_vector(31 downto 0);
         interrupt      :  out std_logic;
         acknowledge    :  in  std_logic;
         interrupt_data :  out std_logic_vector(15 downto 0)
         );
   end component;

   signal s_data_reg_in       :  std_logic_vector(31 downto 0);
   signal s_data_reg_out      :  std_logic_vector(15 downto 0);
   signal s_ack               :  std_logic;
   signal rst_n_t1,rst_n_t2   :  std_logic;
   
begin

   Meta_Reset :
   Process(clk,reset_n)
   begin
      if reset_n ='1' then
         rst_n_t1 <='1';
         rst_n_t2 <='1';
      elsif rising_edge(clk) then
         rst_n_t1 <= '0';
         rst_n_t2 <= rst_n_t1;
      end if;
   end process;
         

   bus_register_write_process:
   process(clk,rst_n_t2,s_data_reg_in)
   begin
      if (rst_n_t2= '0') then
         s_data_reg_in <= (others=>'0');
      elsif rising_edge(clk) then
      
         --CPU write Interrupt Data
         if(cs_n='0' and write_n='0' and addr="01") then
            s_data_reg_in <= din(31 downto 0);
            
         --Acknowledge
         elsif(cs_n='0' and write_n='0' and addr="10") then
            s_ack <= din(0);
            
         else
            null;
         end if;
      else
         null;
      end if;
   end process;
   

   
   bus_register_read_process:
   process(cs_n,read_n,addr,s_data_reg_out)
   begin
      if(cs_n='0' and read_n='0' and addr="00") then
         dout(15 downto 0)<=s_data_reg_out; ---- Time Read
      else 
         dout <= (others=>'0');
      end if;
   end process;

   inst_irq_ctl   :  interrupt_ctl
      port map
         (
         clk            => clk,
         reset_n        => rst_n_t2,
         enable         => enable,
         intr_enable    => intr_enable,
         intr_queue     => intr_queue,
         intr_present   => intr_present,
         data_0         => s_data_reg_in,
         data_1         => std_logic_vector(to_unsigned(250000000,32)),   --5sekunders avbrotsintervall
         data_2         => std_logic_vector(to_unsigned(500000000,32)),   --10sekunders avbrotsintervall
         interrupt      => interrupt,
         acknowledge    => s_ack,
         interrupt_data => s_data_reg_out
         );



end rtl;