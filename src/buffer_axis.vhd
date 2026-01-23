----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11.12.2019 09:25:27
-- Design Name:
-- Module Name: BufferLine - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BufferLine is
generic(ncol:integer:=16);
port(s_axis_clk,s_axis_rstn:in std_logic;
     s_axis_tvalid:in std_logic;
     s_axis_tlast:in std_logic;
     s_axis_tready:out std_logic;
     s_axis_tdata:in std_logic_vector(7 downto 0);
     m_axis_tvalid:out std_logic;
     m_axis_tlast:out std_logic;
     m_axis_tready:in std_logic;
     m_axis_tdata:out std_logic_vector(15 downto 0));
end BufferLine;

architecture Behavioral of BufferLine is

type state is (s0,s1,s2,s3);
signal state_curr, state_next: state;
signal d00,d01,d02,d10,d11,d12,d20,d21,d22,buffer1_out,buffer2_out:std_logic_vector(7 downto 0);
type reg_array is array (ncol-4 downto 0) of std_logic_vector(7 downto 0);
signal buffer1,buffer2:reg_array;
signal add0,add1,add2,add3:std_logic_vector(8 downto 0);
signal add01,add23:std_logic_vector(9 downto 0);
signal add0123:std_logic_vector(10 downto 0);
signal outputdata:std_logic_vector(11 downto 0);
signal count_latencyin,count_latencyout:unsigned(9 downto 0);
signal data_valid,en_countout:std_logic;
signal d22_reg1,d22_reg2,d22_reg3,d22_reg4:std_logic_vector(7 downto 0);
begin

s_axis_tready<=m_axis_tready;
data_valid<=s_axis_tvalid and m_axis_tready;

process(s_axis_clk)
begin
   if(rising_edge(s_axis_clk))then
      if(s_axis_rstn='0')then
         d00<=(others=>'0');
         d01<=(others=>'0');
         d02<=(others=>'0');
      else
         if(data_valid='1')then
            d00<=s_axis_tdata;
         end if;
         if(m_axis_tready='1')then
            d01<=d00;
            d02<=d01;
         end if;
      end if;
   end if;
end process;


process(s_axis_clk)
begin
   if(rising_edge(s_axis_clk))then
      if(s_axis_rstn='0')then
         resetaLL: for j in 0 to ncol-4 loop
                       buffer1(j)<=(others=>'0');
                   end loop;
      else
         if(m_axis_tready='1')then
            genff: for j in 1 to ncol-4 loop
                       buffer1(j)<=buffer1(j-1);
                   end loop;
                   buffer1(0)<=d02;
         end if;
      end if;
   end if;
end process;

buffer1_out<=buffer1(ncol-4);

process(s_axis_clk)
begin
   if(rising_edge(s_axis_clk))then
      if(s_axis_rstn='0')then
         d10<=(others=>'0');
         d11<=(others=>'0');
         d12<=(others=>'0');
      else
         if(m_axis_tready='1')then
            d10<=buffer1_out;
            d11<=d10;
            d12<=d11;
         end if;
      end if;
   end if;
end process;

process(s_axis_clk)
begin
   if(rising_edge(s_axis_clk))then
      if(s_axis_rstn='0')then
         resetaLL: for j in 0 to ncol-4 loop
                       buffer2(j)<=(others=>'0');
                   end loop;
      else
         if(m_axis_tready='1')then
            genff: for j in 1 to ncol-4 loop
                       buffer2(j)<=buffer2(j-1);
                   end loop;
                   buffer2(0)<=d12;
         end if;
      end if;
   end if;
end process;

buffer2_out<=buffer2(ncol-4);

process(s_axis_clk)
begin
   if(rising_edge(s_axis_clk))then
      if(s_axis_rstn='0')then
         d20<=(others=>'0');
         d21<=(others=>'0');
         d22<=(others=>'0');
      else
         if(m_axis_tready='1')then
            d20<=buffer2_out;
            d21<=d20;
            d22<=d21;
         end if;
      end if;
   end if;
end process;


process(s_axis_clk)
begin
if(rising_edge(s_axis_clk)) then
   if(s_axis_rstn='0')then
      add0<=(others=>'0');
      add1<=(others=>'0');
      add2<=(others=>'0');
      add3<=(others=>'0');
      add01<=(others=>'0');
      add23<=(others=>'0');
      add0123<=(others=>'0');
      outputdata<=(others=>'0');
      d22_reg1<=(others=>'0');
      d22_reg2<=(others=>'0');
      d22_reg3<=(others=>'0');
      d22_reg4<=(others=>'0');
   else
      if(m_axis_tready='1')then
         add0<=(d00(7)&d00)+(d01(7)&d01);
         add1<=(d02(7)&d02)+(d10(7)&d10);
         add2<=(d11(7)&d11)+(d12(7)&d12);
         add3<=(d20(7)&d20)+(d21(7)&d21);
         add01<=(add0(8)&add0)+(add1(8)&add1);
         add23<=(add2(8)&add2)+(add3(8)&add3);
         add0123<=(add01(9)&add01)+(add23(9)&add23);
         d22_reg1<=d22;
         d22_reg2<=d22_reg1;
         d22_reg3<=d22_reg2;
         outputdata<=(add0123(10)&add0123)+(d22_reg3(7)&d22_reg3(7)&d22_reg3(7)&d22_reg3);
      end if;
   end if;
end if;
end process;

process(s_axis_clk)
begin
if(rising_edge(s_axis_clk)) then
   if(s_axis_rstn='0')then
      state_curr<=s0;
   else
      case state_curr is
      when s0 =>
                 if(s_axis_rstn='1')then
                    state_curr<=s1;
                 else
                    state_curr<=s0;
                 end if;
      when s1 =>
                 if(count_latencyin>2*ncol+5)then
                    state_curr<=s2;
                 else
                    state_curr<=s1;
                 end if;
      when s2 =>
                 if(s_axis_tlast='1')then
                    state_curr<=s3;
                 else
                    state_curr<=s2;
                 end if;
      when s3 =>
                 if(count_latencyout>5)then
                    state_curr<=s0;
                 else
                    state_curr<=s3;
                 end if;
      end case;
   end if;
end if;
end process;

process(state_curr,count_latencyout)
begin
      case state_curr is
      when s0 =>
               m_axis_tvalid<='0';
               m_axis_tlast<='0';
      when s1 =>
               m_axis_tvalid<='0';
               m_axis_tlast<='0';
      when s2 =>
               m_axis_tvalid<='1';
               m_axis_tlast<='0';
      when s3 =>
               m_axis_tvalid<='1';
               if(count_latencyout=5)then
                  m_axis_tlast<='1';
               else
                  m_axis_tlast<='0';
               end if;
      end case;
end process;

process(s_axis_clk)
begin
if(rising_edge(s_axis_clk)) then
   if(s_axis_rstn='0')then
      en_countout<='0';
      count_latencyin<=(others=>'0');
      count_latencyout<=(others=>'0');
   else
      if(s_axis_tvalid='1')then
         count_latencyin<=count_latencyin+1;
      end if;
      if(s_axis_tlast='1')then
         en_countout<='1';
      end if;
      if(en_countout='1')then
         count_latencyin<=(others=>'0');
         count_latencyout<=count_latencyout+1;
      else
         count_latencyout<=(others=>'0');
      end if;
   end if;
end if;
end process;

m_axis_tdata<=outputdata(11)&outputdata(11)&outputdata(11)&outputdata(11)&outputdata;
end Behavioral;
