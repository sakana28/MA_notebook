library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------
entity signal_generator is
    port (
        clk : in std_logic;
        axis_data : in std_logic_vector(31 downto 0);
        axis_valid : in std_logic;
        axis_ready : out std_logic;
        sample_clk : in std_logic;
        sampling_en : in std_logic;
        rstn : in std_logic;
        data_out : out std_logic_vector(7 downto 0);
        wr_en : out std_logic;
        fifo_rst : out std_logic
    );
end entity signal_generator;
------------------------------------------------------------
architecture arch of signal_generator is
    signal data_reg : std_logic_vector (7 downto 0);
    signal data_reg_nxt : std_logic_vector (7 downto 0);
    signal sample_clk_dly : std_logic;
    signal sample_clk_rising : std_logic;
    signal wr_en_reg : std_logic;
    signal wr_en_nxt : std_logic;
begin
    data_out <= data_reg;
    wr_en <= wr_en_reg;
    fifo_rst <= not rstn;
    delay_ff : process (clk) is
    begin
        if rising_edge(clk) then
            sample_clk_dly <= sample_clk;
        end if;
    end process;

    edge_detect : process (clk, rstn) is
    begin
        if rising_edge(clk) then
            if (rstn = '0') then
                sample_clk_rising <= '0';
            else
                sample_clk_rising <= (not sample_clk_dly) and (sample_clk);
            end if;
        end if;
    end process;
    ff : process (clk, rstn) is
    begin

        if (rstn = '0') then
            data_reg <= (others => '0');
            wr_en_reg <= '0';
        elsif rising_edge(clk) then
            data_reg <= data_reg_nxt;
            wr_en_reg <= wr_en_nxt;
        end if;

    end process ff;

    signal_gen : process (data_reg, sampling_en, sample_clk_rising)
    begin
        data_reg_nxt <= data_reg;
        wr_en_nxt <= '0';
        axis_ready <= '0';
        if (sampling_en = '1') then
            if (sample_clk_rising = '1') then
                axis_ready <= '1';
                if (axis_valid = '1') then
                    data_reg_nxt <= axis_data (7 downto 0);
                    wr_en_nxt <= '1';
                end if;
            end if;
        end if;
    end process signal_gen;
end architecture arch;