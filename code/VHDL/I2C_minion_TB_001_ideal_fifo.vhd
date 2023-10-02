--------------------------original information-------------------------------
-----------------------------------------------------------------------------
-- Title      : I2C_minion Testbench
-----------------------------------------------------------------------------
-- File       : I2C_minion_TB_001_ideal
-- Author     : Peter Samarin <peter.samarin@gmail.com>
-----------------------------------------------------------------------------
-- Copyright (c) 2019 Peter Samarin
-----------------------------------------------------------------------------
-- add i2c_read_register procedure

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
------------------------------------------------------------------------
entity I2C_minion_TB_001_ideal is
end I2C_minion_TB_001_ideal;
------------------------------------------------------------------------
architecture Testbench of I2C_minion_TB_001_ideal is
  constant T : time := 20 ns; -- clk period
  constant T_SAMPLE : time := 10 us; -- clk period
  constant TH_I2C : time := 100 ns; -- i2c clk quarter period(kbis)
  constant T_MUL : integer := 2; -- i2c clk quarter period(kbis)
  constant T_HALF : integer := (TH_I2C * T_MUL * 2) / T; -- i2c halfclk period
  constant T_QUARTER : integer := (TH_I2C * T_MUL) / T; -- i2c quarterclk period

  signal clk : std_logic := '1';
 -- signal sample_clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal scl : std_logic;
  signal sda : std_logic;
  signal state_dbg : integer := 0;
  signal received_data : std_logic_vector(7 downto 0) := (others => '0');
  signal ack : std_logic := '0';
  signal read_req : std_logic := '0';
  signal data_to_master : std_logic_vector(7 downto 0) := (others => '0');
  signal data_valid : std_logic := '0';
  signal data_from_master : std_logic_vector(7 downto 0) := (others => '0');
  signal data_from_master_reg : std_logic_vector(7 downto 0) := (others => '0');
  signal prog_full : std_logic;
  shared variable seed1 : positive := 1000;
  shared variable seed2 : positive := 2000;

  -- simulation control
  shared variable ENDSIM : boolean := false;
 component design_1_wrapper is
port (
    prog_full_0 : out STD_LOGIC;
    rstn : in STD_LOGIC;
    scl_0 : inout STD_LOGIC;
    sda_0 : inout STD_LOGIC;
    sys_clk : in STD_LOGIC
  );
end component design_1_wrapper;

begin

  ---- Design Under Verification -----------------------------------------
  DUV : component design_1_wrapper
    port map(
      prog_full_0 => prog_full,
      rstn => rst,
      scl_0 => scl,
      sda_0 => sda,
      sys_clk => clk

    );
    ---- DUT clock running forever ----------------------------
    process
    begin
      if ENDSIM = false then
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;
      else
        wait;
      end if;
    end process;
    --- Sample clock running forever ---------------------------- 
   -- process
   -- begin
   --   if ENDSIM = false then
    --    sample_clk <= '0';
     --   wait for T_SAMPLE/2;
    --    sample_clk <= '1';
     --   wait for T_SAMPLE/2;
    --  else
    --    wait;
    --  end if;
   -- end process;

    ---- Reset asserted for T/2 ------------------------------
    rst <= '0', '1' after 4*T*1953;
    ----- Test vector generation -------------------------------------------
    TESTS : process is
      -- half clock
      procedure i2c_wait_half_clock is
      begin
        for i in 0 to T_HALF loop
          wait until rising_edge(clk);
        end loop;
      end procedure i2c_wait_half_clock;

      -- quarter clock

      procedure i2c_wait_quarter_clock is
      begin
        for i in 0 to T_QUARTER loop
          wait until rising_edge(clk);
        end loop;
      end procedure i2c_wait_quarter_clock;
      -- Write Bit

      procedure i2c_send_bit (
        constant a_bit : in std_logic) is
      begin
        scl <= '0';
        if a_bit = '0' then
          sda <= '0';
        else
          sda <= 'Z';
        end if;

        i2c_wait_quarter_clock;
        scl <= 'Z';
        i2c_wait_half_clock;
        scl <= '0';
        i2c_wait_quarter_clock;
      end procedure i2c_send_bit;

      -- Read Bit

      procedure i2c_receive_bit (
        variable a_bit : out std_logic) is
      begin
        scl <= '0';
        sda <= 'Z';
        i2c_wait_quarter_clock;
        scl <= 'Z';
        i2c_wait_quarter_clock;
        if sda = '0' then
          a_bit := '0';
        else
          a_bit := '1';
        end if;

        i2c_wait_quarter_clock;
        scl <= '0';
        i2c_wait_quarter_clock;
      end procedure i2c_receive_bit;

      -- Write Byte
      procedure i2c_send_byte (
        constant a_byte : in std_logic_vector(7 downto 0)) is
      begin
        for i in 7 downto 0 loop
          i2c_send_bit(a_byte(i));
        end loop;
      end procedure i2c_send_byte;

      -- Address
      procedure i2c_send_address (
        constant address : in std_logic_vector(6 downto 0)) is
      begin
        for i in 6 downto 0 loop
          i2c_send_bit(address(i));
        end loop;
      end procedure i2c_send_address;

      -- Read Byte
      procedure i2c_receive_byte (
        signal a_byte : out std_logic_vector(7 downto 0)) is
        variable a_bit : std_logic;
        variable accu : std_logic_vector(7 downto 0) := (others => '0');
      begin
        for i in 7 downto 0 loop
          i2c_receive_bit(a_bit);
          accu(i) := a_bit;
        end loop;
        a_byte <= accu;
      end procedure i2c_receive_byte;

      -- START
      procedure i2c_start is
      begin
        scl <= 'Z';
        sda <= '0';
        i2c_wait_half_clock;
        scl <= 'Z';
        i2c_wait_quarter_clock;
        scl <= '0';
        i2c_wait_quarter_clock;
      end procedure i2c_start;

      procedure i2c_start_repeat is
      begin
        scl <= 'Z';
        sda <= 'Z';
        i2c_wait_quarter_clock;
        sda <= '0';
        i2c_wait_half_clock;
        scl <= '0';
        i2c_wait_quarter_clock;
      end procedure i2c_start_repeat;

      -- STOP
      procedure i2c_stop is
      begin
        scl <= '0';
        sda <= '0';
        i2c_wait_quarter_clock;
        scl <= 'Z';
        i2c_wait_quarter_clock;
        sda <= 'Z';
        i2c_wait_half_clock;
        i2c_wait_half_clock;
      end procedure i2c_stop;
      -- send write
      procedure i2c_set_write is
      begin
        i2c_send_bit('0');
      end procedure i2c_set_write;

      -- send read
      procedure i2c_set_read is
      begin
        i2c_send_bit('1');
      end procedure i2c_set_read;

      -- read ACK
      procedure i2c_read_ack (signal ack : out std_logic) is
      begin
        scl <= '0';
        sda <= 'Z';
        i2c_wait_quarter_clock;
        scl <= 'Z';
        if sda = '0' then
          ack <= '1';
        else
          ack <= '0';
          assert false report "No ACK received: expected '0'" severity note;
        end if;
        i2c_wait_half_clock;
        scl <= '0';
        i2c_wait_quarter_clock;
      end procedure i2c_read_ack;
      -- write NACK
      procedure i2c_write_nack is
      begin
        scl <= '0';
        sda <= 'Z';
        i2c_wait_quarter_clock;
        scl <= 'Z';
        i2c_wait_half_clock;
        scl <= '0';
        i2c_wait_quarter_clock;
      end procedure i2c_write_nack;

      -- write ACK
      procedure i2c_write_ack is
      begin
        scl <= '0';
        sda <= '0';
        i2c_wait_quarter_clock;
        scl <= 'Z';
        i2c_wait_half_clock;
        scl <= '0';
        i2c_wait_quarter_clock;
      end procedure i2c_write_ack;

      -- write to I2C bus
      procedure i2c_write (
        constant address : in std_logic_vector(6 downto 0);
        constant data : in std_logic_vector(7 downto 0)) is
      begin
        state_dbg <= 0;
        i2c_start;
        state_dbg <= 1;
        i2c_send_address(address);
        state_dbg <= 2;
        i2c_set_write;
        state_dbg <= 3;
        -- dummy read ACK--don't care, because we are testing
        -- I2C minion
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 6;
          i2c_stop;
          ack <= '0';
          return;
        end if;
        state_dbg <= 4;
        i2c_send_byte(data);
        state_dbg <= 5;
        i2c_read_ack(ack);
        state_dbg <= 6;
        i2c_stop;
      end procedure i2c_write;

      procedure i2c_config_register (
        constant address : in std_logic_vector(6 downto 0);
        constant register_addr : in std_logic_vector(7 downto 0);
        constant register_data : in std_logic_vector(7 downto 0)) is
      begin
        state_dbg <= 0;
        i2c_start;
        state_dbg <= 1;
        i2c_send_address(address);
        state_dbg <= 2;
        i2c_set_write;
        state_dbg <= 3;
        -- dummy read ACK--don't care, because we are testing
        -- I2C minion
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 8;
          i2c_stop;
          ack <= '0';
          return;
        end if;
        state_dbg <= 4;
        i2c_send_byte(register_addr);
        state_dbg <= 5;
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 8;
          i2c_stop;
          ack <= '0';
          return;
        end if;
        state_dbg <= 6;
        i2c_send_byte(register_data);
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 8;
          i2c_stop;
          ack <= '0';
          return;
        end if;
        state_dbg <= 7;
        i2c_stop;
      end procedure i2c_config_register;
      -- read I2C bus
      procedure i2c_write_bytes (
        constant address : in std_logic_vector(6 downto 0);
        constant nof_bytes : in integer range 0 to 1023) is
        variable data : std_logic_vector(7 downto 0) := (others => '0');
      begin
        state_dbg <= 0;
        i2c_start;
        state_dbg <= 1;
        i2c_send_address(address);
        state_dbg <= 2;
        i2c_set_write;
        state_dbg <= 3;
        i2c_read_ack(ack);
        if ack = '0' then
          i2c_stop;
          return;
        end if;
        ack <= '0';
        for i in 0 to nof_bytes - 1 loop
          state_dbg <= 4;
          i2c_send_byte(std_logic_vector(to_unsigned(2 * i, 8)));
          state_dbg <= 5;
          i2c_read_ack(ack);
          if ack = '0' then
            i2c_stop;
            return;
          end if;
          ack <= '0';
        end loop;
        state_dbg <= 6;
        i2c_stop;
      end procedure i2c_write_bytes;

      -- read from I2C bus
      procedure i2c_read (
        constant address : in std_logic_vector(6 downto 0);
        signal data : out std_logic_vector(7 downto 0)) is
      begin
        state_dbg <= 0;
        i2c_start;
        state_dbg <= 1;
        i2c_send_address(address);
        state_dbg <= 2;
        i2c_set_read;
        state_dbg <= 3;
        -- dummy read ACK--don't care, because we are testing
        -- I2C minion
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 6;
          i2c_stop;
          return;
        end if;
        ack <= '0';
        state_dbg <= 4;
        i2c_receive_byte(data);
        state_dbg <= 5;
        i2c_write_nack;
        state_dbg <= 6;
        i2c_stop;
      end procedure i2c_read;

      procedure i2c_read_register (
        constant address : in std_logic_vector(6 downto 0);
        constant register_addr : in std_logic_vector(7 downto 0);
        constant nof_bytes : in integer range 0 to 1023;
        signal data : out std_logic_vector(7 downto 0)) is
      begin
        state_dbg <= 0;
        i2c_start;
        state_dbg <= 1;
        i2c_send_address(address);
        state_dbg <= 2;
        i2c_set_write;
        state_dbg <= 3;
        -- dummy read ACK--don't care, because we are testing
        -- I2C minion
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 6;
          i2c_stop;
          return;
        end if;
        ack <= '0';
        state_dbg <= 4;
        i2c_send_byte(register_addr);
        state_dbg <= 5;
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 6;
          i2c_stop;
          return;
        end if;
        ack <= '0';
        state_dbg <= 7;
        i2c_start_repeat;
        state_dbg <= 8;
        i2c_send_address(address);
        state_dbg <= 9;
        i2c_set_read;
        state_dbg <= 10;
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 6;
          i2c_stop;
          return;
        end if;
        ack <= '0';
        state_dbg <= 11;
        for i in 0 to nof_bytes - 1 loop
          i2c_receive_byte(data);
          state_dbg <= 12;
          if i < nof_bytes - 1 then
            i2c_write_ack;
          else
            i2c_write_nack;
          end if;
        end loop;
        state_dbg <= 13;
        i2c_stop;
      end procedure i2c_read_register;

      procedure i2c_read_bytes (
        constant address : in std_logic_vector(6 downto 0);
        constant nof_bytes : in integer range 0 to 1023;
        signal data : out std_logic_vector(7 downto 0)) is
      begin
        state_dbg <= 0;
        i2c_start;
        state_dbg <= 1;
        i2c_send_address(address);
        state_dbg <= 2;
        i2c_set_read;
        state_dbg <= 3;
        i2c_read_ack(ack);
        if ack = '0' then
          state_dbg <= 6;
          i2c_stop;
          return;
        end if;
        for i in 0 to nof_bytes - 1 loop
          -- dummy read ACK--don't care, because we are testing
          -- I2C minion
          state_dbg <= 4;
          i2c_receive_byte(data);
          state_dbg <= 5;
          if i < nof_bytes - 1 then
            i2c_write_ack;
          else
            i2c_write_nack;
          end if;
        end loop;
        state_dbg <= 6;
        i2c_stop;
      end procedure i2c_read_bytes;

    begin

      print("");
      print("------------------------------------------------------------");
      print("----------------- I2C_minion_TB_001_ideal ------------------");
      print("------------------------------------------------------------");

      scl <= 'Z';
      sda <= 'Z';
      --print("----------------- Testing a single write ------------------");
      --i2c_write("0000011", "00000001");

      --print("----------------- Testing a single write ------------------");
      --i2c_write("0000011", "11111010");

      --------------------------------------------------------
      -- !NEW testing read and write from rigister
      --------------------------------------------------------
      wait until rising_edge(clk);
      wait until rising_edge(rst);
      i2c_config_register("0011111", "00011011", "00000000"); ---write 0X00 to CNTL1 
      i2c_config_register("0011111", "00100001", "00001111"); ---write ODCNTL to set sample rate
      i2c_config_register("0011111", "01011110", "00111100"); ---write threshold=6 to 0x5E
      wait for 1953*10*T;
      i2c_config_register("0011111", "00011011", "11010000"); ---write 0XD0 to CNTL1 
      wait until rising_edge(prog_full);
     
      --i2c_write_bytes("0011111", 50);
      --i2c_read_register("0011111", "00000001", 5, received_data);
      --------------------------------------------------------
      -- !NEW testing FIFO and write from rigister
      --------------------------------------------------------
      -- wait for T_SAMPLE * 10;
      --i2c_write("0000011", "00000001");

      i2c_read_register("0011111", "01100011", 30, received_data);
      ENDSIM := true;
      print("Simulation end...");
      print("");
      wait;
    end process;
  end Testbench;