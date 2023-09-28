
--------------------------------------
--used embedded registers
--0x21 ODCNTL
--0x5E BUF_CNTL1 define threshold
--0X1B CNTL1 
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------
entity I2C_minion is
  generic (
    MINION_ADDR : std_logic_vector(6 downto 0) := "0011111";
    -- for test 0x1F 0011111
    -- noisy SCL/SDA lines can confuse the minion
    -- use low-pass filter to smooth the signal
    -- (this might not be necessary!)
    USE_INPUT_DEBOUNCING : boolean := true;
    -- play with different number of wait cycles
    -- larger wait cycles increase the resource usage
    DEBOUNCING_WAIT_CYCLES : integer := 4);
  port (
    scl_i : in std_logic;
    scl_o : out std_logic;
    scl_t : out std_logic;
    sda_i : in std_logic;
    sda_o : out std_logic;
    sda_t : out std_logic;
    clk : in std_logic;
    rstn : in std_logic;
    --debug
    start_debug : out std_logic;
    sda_t_debug : out std_logic;
    state_code : out std_logic_vector(2 downto 0);
    counter_debug : out std_logic_vector(3 downto 0);
    sda_i_debug : out std_logic;
    scl_i_debug : out std_logic;
    --to FIFO BUF_READ is read only register
    fifo_din : in std_logic_vector(7 downto 0);
    fifo_rd_req : out std_logic;
    -- interface from Registermap to other parts
    threshold : out std_logic_vector(9 downto 0);
    odr_conf : out std_logic_vector(3 downto 0);
    sampling_start :out std_logic
  );
end entity I2C_minion;
------------------------------------------------------------
architecture arch of I2C_minion is
  type state_t is (idle, get_address_and_cmd,
    answer_ack_start, write, after_write_ack,
    read, read_ack_start,
    read_ack_got_rising, read_stop);
  -- I2C state management

  type state_register_t is (idle, get_data, write_data);
  -- W/R from register state management

  type t_registermap is array (0 to 127) of std_logic_vector(7 downto 0); --to use RA: registermap(to_integer(unsigned(register_addr_reg)));
  signal registermap : t_registermap;
  -- Register Array
  signal state : state_t;
  signal state_nxt : state_t;
  signal state_2 : state_register_t;
  signal state_2_nxt : state_register_t;
  signal cmd_reg : std_logic;
  signal cmd_reg_nxt : std_logic;
  signal bits_processed_reg : unsigned(3 downto 0);
  signal bits_processed_reg_nxt : unsigned(3 downto 0);
  signal continue_reg : std_logic;
  signal continue_reg_nxt : std_logic;
  signal scl_debounced : std_logic;
  signal sda_debounced : std_logic;

  signal scl_internal : std_logic;
  signal sda_internal : std_logic;

  signal scl_pre_internal : std_logic;
  signal sda_pre_internal : std_logic;

  -- Helpers to figure out next state
  signal start_reg : std_logic;
  signal stop_reg : std_logic;
  signal scl_rising_reg : std_logic;
  signal scl_falling_reg : std_logic;
  -- used for edge detection
  signal sda_prev_reg : std_logic;
  signal scl_prev_reg : std_logic;
  -- Address and data received from master
  signal addr_reg : std_logic_vector(6 downto 0);
  signal addr_reg_nxt : std_logic_vector(6 downto 0);
  signal data_reg : std_logic_vector(6 downto 0);
  signal data_reg_nxt : std_logic_vector(6 downto 0);
  signal data_from_master_reg : std_logic_vector(7 downto 0);

  -- Minion writes on sda
  signal sda_t_reg : std_logic;

  -- User interface
  signal data_valid_reg : std_logic;
  signal read_req_reg : std_logic;
  signal data_to_master_reg : std_logic_vector(7 downto 0);

  -- Register address and reg_addr_valid
  -- for each write operation, the first data written to the slave is seen as a register address.
  -- It is unvalid after the slave receives the STOP condition.
  -- KX134 allows data to be read from/written to multiple registers by auto-increment
  signal register_addr_reg : std_logic_vector(7 downto 0) := (others => '0');
  signal register_addr_reg_nxt : std_logic_vector(7 downto 0) := (others => '0');
  signal register_addr_valid_reg : std_logic;
  signal register_addr_valid_reg_nxt : std_logic;
  signal register_addr_incr_reg : std_logic; -- This is a signal used only for write operations to indicate that the data being written is a register address or register data.
  signal register_addr_incr_reg_nxt : std_logic;

  signal interrupt_reg : std_logic;
  
  signal threshold_reg :std_logic_vector(9 downto 0);
  signal threshold_reg_nxt :std_logic_vector(9 downto 0);
  
  signal register_map_buffer : std_logic_vector(7 downto 0);
  signal register_map_buffer_nxt : std_logic_vector(7 downto 0);
  -- Buffer to get the valid data_from_master which lasts for just 1 cycle
begin
  -- I2C connection
  sda_o <= '0';
  sda_t <= sda_t_reg;
  scl_o <= '0';
  scl_t <= '1';
  --following ports are for debugging only
  start_debug <= scl_rising_reg;
  sda_t_debug <= sda_t_reg;
  counter_debug <= std_logic_vector(bits_processed_reg);
  sda_i_debug <= sda_internal;
  scl_i_debug <= scl_internal;
  --connection to FIFO_generator
  threshold <= threshold_reg;
  threshold_reg_nxt <= std_logic_vector(shift_left(resize(unsigned(registermap(94)),10),2)+shift_left(resize(unsigned(registermap(94)),10),1)); --sample threshold *6 =byte threshold
  fifo_rd_req <= read_req_reg when (register_addr_reg = "01100011") else
    '0';
  odr_conf <= registermap(33)(3 downto 0);
  sampling_start <= registermap(27)(7);

  debounce : if USE_INPUT_DEBOUNCING generate
    -- debounce SCL and SDA
    SCL_debounce : entity work.debounce
      generic map(
        WAIT_CYCLES => DEBOUNCING_WAIT_CYCLES)
      port map(
        clk => clk,
        signal_in => scl_i,
        signal_out => scl_debounced);
    SDA_debounce : entity work.debounce
      generic map(
        WAIT_CYCLES => DEBOUNCING_WAIT_CYCLES)
      port map(
        clk => clk,
        signal_in => sda_i,
        signal_out => sda_debounced);

    scl_pre_internal <= scl_debounced;
    sda_pre_internal <= sda_debounced;
  end generate debounce;

  -- Align SCL and SDA with clk
  dont_debounce : if (not USE_INPUT_DEBOUNCING) generate
    process (clk) is
    begin
      if rising_edge(clk) then
        scl_pre_internal <= scl_i;
        sda_pre_internal <= sda_i;
      end if;
    end process;
  end generate dont_debounce;

  scl_internal <= '0' when scl_pre_internal = '0' else
    '1';
  sda_internal <= '0' when sda_pre_internal = '0' else
    '1';

  -- edge and START/STOP condition detection
  process (clk) is
  begin
    if rising_edge(clk) then
      -- Delay SCL and SDA by 1 clock cycle
      scl_prev_reg <= scl_internal;
      sda_prev_reg <= sda_internal;
      -- Detect rising and falling SCL
    end if;
  end process;

  process (clk, rstn) is
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        scl_rising_reg <= '0';
        scl_falling_reg <= '0';
        start_reg <= '0';
        stop_reg <= '0';
      else
        scl_rising_reg <= (not scl_prev_reg) and (scl_internal);
        scl_falling_reg <= (scl_prev_reg) and (not scl_internal);
        start_reg <= scl_internal and scl_prev_reg and sda_prev_reg and (not sda_internal);
        stop_reg <= scl_prev_reg and scl_internal and (not sda_prev_reg) and (sda_internal);
      end if;
    end if;
  end process;

  ----------------------------------------------------------
  -- I2C state machine(flip-flop part)
  ----------------------------------------------------------
  fsm_ff : process (clk, rstn) is
  begin

    if rising_edge(clk) then
      if (rstn = '0') then
        threshold_reg <= (others => '1');
        state <= idle;
        state_2 <= idle;
        register_addr_reg <= ((others => '0'));
        register_addr_valid_reg <= '0';
        register_addr_incr_reg <= '0';
        addr_reg <= ((others => '0'));
        data_reg <= ((others => '0'));
        cmd_reg <= '0';
        continue_reg <= '0';
        register_map_buffer <= ((others => '0'));
      else
        threshold_reg <= threshold_reg_nxt;
        state <= state_nxt;
        state_2 <= state_2_nxt;
        register_addr_reg <= register_addr_reg_nxt;
        register_addr_valid_reg <= register_addr_valid_reg_nxt;
        register_addr_incr_reg <= register_addr_incr_reg_nxt;
        addr_reg <= addr_reg_nxt;
        data_reg <= data_reg_nxt;
        cmd_reg <= cmd_reg_nxt;
        continue_reg <= continue_reg_nxt;
        register_map_buffer <= register_map_buffer_nxt;
      end if;
    end if;

  end process fsm_ff;

  bit_counter : process (clk, rstn) is
  begin
    if rising_edge(clk) then
      if rstn = '0' then
        bits_processed_reg <= ((others => '0'));
      else
        bits_processed_reg <= bits_processed_reg_nxt;
      end if;
    end if;
  end process bit_counter;
  ----------------------------------------------------------
  -- I2C state machine(logic part)
  ----------------------------------------------------------

  fsm_transfer : process (state, register_addr_reg, register_addr_valid_reg, scl_rising_reg, scl_falling_reg, start_reg, stop_reg, bits_processed_reg, data_reg, addr_reg, cmd_reg, sda_internal, register_addr_incr_reg, data_to_master_reg, continue_reg) is
  begin

    -- Default assignments to avoid inferred latch
    state_nxt <= state;

    sda_t_reg <= '1';

    bits_processed_reg_nxt <= bits_processed_reg;
    register_addr_reg_nxt <= register_addr_reg;
    register_addr_valid_reg_nxt <= register_addr_valid_reg;
    register_addr_incr_reg_nxt <= register_addr_incr_reg;
    addr_reg_nxt <= addr_reg;
    data_reg_nxt <= data_reg;
    data_from_master_reg <= ((others => '0'));
    cmd_reg_nxt <= cmd_reg;
    continue_reg_nxt <= continue_reg;

    --communication signals with Registers
    data_valid_reg <= '0';
    read_req_reg <= '0';

    --interrupt (logic TBD)
    interrupt_reg <= '0';
    case state is

      when idle =>
        state_code <= "000";
        register_addr_valid_reg_nxt <= '0';
        addr_reg_nxt <= ((others => '0'));
        data_reg_nxt <= ((others => '0'));
        if start_reg = '1' then
          state_nxt <= get_address_and_cmd;
          bits_processed_reg_nxt <= (others => '0');
        end if;

      when get_address_and_cmd =>
        state_code <= "001";
        if scl_rising_reg = '1' then
          if bits_processed_reg < 7 then
            bits_processed_reg_nxt <= bits_processed_reg + 1;
            addr_reg_nxt(6 - to_integer(bits_processed_reg)) <= sda_internal;
          elsif bits_processed_reg = 7 then
            bits_processed_reg_nxt <= bits_processed_reg + 1;
            cmd_reg_nxt <= sda_internal;
          end if;

        elsif scl_falling_reg = '1' then
          if bits_processed_reg = 8 then
            if addr_reg = MINION_ADDR then -- check req address
              state_nxt <= answer_ack_start;
              bits_processed_reg_nxt <= (others => '0');
              if cmd_reg = '1' then -- issue read request 
                read_req_reg <= '1';
              end if;
            else
              state_nxt <= idle;
              interrupt_reg <= '1';
              assert false
              report ("I2C: target/minion address mismatch (data is being sent to another minion).")
                severity note;
            end if;
          end if;
        end if;

        ----------------------------------------------------
        -- I2C acknowledge to master
        ----------------------------------------------------
      when answer_ack_start =>
        state_code <= "010";
        sda_t_reg <= '0';
        if scl_falling_reg = '1' then
          if cmd_reg = '0' then
            state_nxt <= write;
          else
            state_nxt <= read;
          end if;
        end if;
        -- State starts on a falling edge, ends on next falling edge to ensure that SDA does not change when SCL is high.
        ----------------------------------------------------
        -- WRITE
        ----------------------------------------------------
      when write =>
        state_code <= "011";
        if scl_rising_reg = '1' then
          bits_processed_reg_nxt <= bits_processed_reg + 1;
          if bits_processed_reg < 7 then
            data_reg_nxt(6 - to_integer(bits_processed_reg)) <= sda_internal;
          elsif bits_processed_reg = 7 then
            if register_addr_valid_reg = '0' then
              register_addr_reg_nxt <= data_reg & sda_internal;
              register_addr_valid_reg_nxt <= '1'; --RA valid will keep itself
              register_addr_incr_reg_nxt <= '0';
            else
              data_from_master_reg <= data_reg & sda_internal; --data lasted just one cycle
              data_valid_reg <= '1'; --data valid just one cycle
              register_addr_incr_reg_nxt <= '1';
            end if;
          end if;
        end if;

        if scl_falling_reg = '1' and bits_processed_reg = 8 then
          state_nxt <= after_write_ack;
          bits_processed_reg_nxt <= (others => '0');
        end if;

      when after_write_ack =>
        state_code <= "100";
        sda_t_reg <= '0';
        if scl_falling_reg = '1' then
          state_nxt <= write;
          sda_t_reg <= '1';
          if register_addr_incr_reg = '0'then
            register_addr_reg_nxt <= register_addr_reg;
          else
            register_addr_reg_nxt <= std_logic_vector(unsigned(register_addr_reg) + 1);
          end if;
        end if;
        ----------------------------------------------------
        -- READ: send data to master
        ----------------------------------------------------
      when read =>
        state_code <= "101";
        if register_addr_valid_reg = '0' then
          assert false
          report ("I2C: error: Register address must be written before read.")
            severity error;
          state_nxt <= idle;
        end if;

        if data_to_master_reg(7 - to_integer(bits_processed_reg)) = '0' then
          sda_t_reg <= '0';
        else
          sda_t_reg <= '1';
        end if;

        if scl_falling_reg = '1' then
          if bits_processed_reg < 7 then
            bits_processed_reg_nxt <= bits_processed_reg + 1;
          elsif bits_processed_reg = 7 then
            state_nxt <= read_ack_start;
            bits_processed_reg_nxt <= (others => '0');
          end if;
        end if;

        ----------------------------------------------------
        -- I2C read master acknowledge
        ----------------------------------------------------
        -- function: waiting until scl rising edge
      when read_ack_start =>
        state_code <= "110";
        if scl_rising_reg = '1' then
          state_nxt <= read_ack_got_rising;
          if sda_internal = '1' then -- nack = stop read
            continue_reg_nxt <= '0';
          else -- ack = continue read
            continue_reg_nxt <= '1';
            if (register_addr_reg = "01100011") then
              register_addr_reg_nxt <= register_addr_reg;
            else
              register_addr_reg_nxt <= std_logic_vector(unsigned(register_addr_reg) + 1); --TBD check of addr =63 aka FIFO (FIFO xilinx IP core)
            end if;
          end if;
        end if;

      when read_ack_got_rising =>
        state_code <= "111";
        if scl_falling_reg = '1' then
          if continue_reg = '1' then
            state_nxt <= read;
            read_req_reg <= '1'; -- request reg byte. At this time, the data from register will be prepared in data_to_master_reg
          else
            state_nxt <= read_stop;
          end if;
        end if;

        -- Wait for START or STOP to get out of this state
      when read_stop =>
        state_code <= "000";
        null;

        -- Wait for START or STOP to get out of this state
      when others =>
        state_code <= "000";
        assert false
        report ("I2C: error: ended in an impossible state.")
          severity error;
        state_nxt <= idle;
    end case;

    --------------------------------------------------------
    -- Reset counter and state on start/stop
    --------------------------------------------------------
    if start_reg = '1' then -- include SR
      state_nxt <= get_address_and_cmd;
      bits_processed_reg_nxt <= (others => '0');
    end if;

    if stop_reg = '1' then
      state_nxt <= idle;
      bits_processed_reg_nxt <= (others => '0');
      register_addr_incr_reg_nxt <= '0';
    end if;

  end process fsm_transfer;
  --BUF_READ Register :0X63
  ----------------------------------------------------------
  -- Connect to Rigesters
  ----------------------------------------------------------
  fsm_rd_transfer : process (state_2, register_map_buffer, register_addr_valid_reg, read_req_reg, data_valid_reg, fifo_din, registermap, register_addr_reg) is
  begin

    -- Default assignments to avoid inferred latch
    state_2_nxt <= state_2;
    register_map_buffer_nxt <= register_map_buffer;
    case state_2 is

      when idle =>
        if register_addr_valid_reg = '1' then
          if read_req_reg = '1' then
            state_2_nxt <= get_data;
          elsif data_valid_reg = '1' then
            state_2_nxt <= write_data;
            register_map_buffer_nxt <= data_from_master_reg;
          end if;
        end if;
      when get_data =>
        if (register_addr_reg = "01100011") then
          data_to_master_reg <= fifo_din;
        else
          data_to_master_reg <= registermap(to_integer(unsigned(register_addr_reg)));
        end if;
        state_2_nxt <= idle;
      when write_data =>

        registermap(to_integer(unsigned(register_addr_reg))) <= register_map_buffer;
        state_2_nxt <= idle;
      when others =>
        assert false
        report ("Register Map: error: ended in an impossible state.")
          severity error;
        state_2_nxt <= idle;
    end case;
  end process;

end architecture arch;