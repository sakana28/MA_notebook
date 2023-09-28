library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity top_level is
    port (

        scl : inout std_logic;
        sda : inout std_logic;
        clk : in std_logic;
        rst : in std_logic;
        fifo_din : in std_logic_vector(7 downto 0);
        fifo_rd_req : out std_logic;
        -- interface from Registermap to other parts
        threshold : out std_logic_vector(9 downto 0);
        odr_conf : out std_logic_vector(3 downto 0);
        sampling_start : out std_logic
    );
end top_level;

architecture arch of top_level is

    component IOBUF is
        port (
            I : in std_logic;
            O : out std_logic;
            T : in std_logic;
            IO : inout std_logic
        );
    end component IOBUF;

    component I2C_minion is
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
            sampling_start : out std_logic
        );
    end component I2C_minion;

    signal scl_i_reg : std_logic;
    signal scl_o_reg : std_logic;
    signal scl_t_reg : std_logic;
    signal sda_i_reg : std_logic;
    signal sda_o_reg : std_logic;
    signal sda_t_reg : std_logic;

begin

    I2C_slave_0_scl_iobuf : component IOBUF
        port map(
            I => scl_o_reg,
            IO => scl,
            O => scl_i_reg,
            T => scl_t_reg
        );

        I2C_slave_0_sda_iobuf : component IOBUF
            port map(
                I => sda_o_reg,
                IO => sda,
                O => sda_i_reg,
                T => sda_t_reg
            );
            SLAVE : component I2C_minion
                generic map(
                    MINION_ADDR => "0011111",
                    USE_INPUT_DEBOUNCING => TRUE,
                    DEBOUNCING_WAIT_CYCLES => 3)
                port map(
                    scl_i => scl_i_reg,
                    scl_o => scl_o_reg,
                    scl_t => scl_t_reg,
                    sda_i => sda_i_reg,
                    sda_o => sda_o_reg,
                    sda_t => sda_t_reg,
                    clk => clk,
                    rstn => rst,
                    start_debug => open,
                    sda_t_debug => open,

                    state_code => open,
                    sda_i_debug => open,
                    scl_i_debug => open,
                    fifo_din => fifo_din,
                    fifo_rd_req => fifo_rd_req,
                    threshold => threshold,
                    odr_conf => odr_conf,
                    sampling_start => sampling_start
                );

            end arch;