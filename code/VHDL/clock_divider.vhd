library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity Clock_Divider is
    port (
        clk : in std_logic;
        rst : in std_logic;
        odr_conf : in std_logic_vector(3 downto 0);
        clock_out : out std_logic
    );
end Clock_Divider;

--50 Hz 11110100001001000000 20bits -- max 26

architecture bhv of Clock_Divider is

    signal count_max : std_logic_vector(25 downto 0);
    signal count : unsigned(25 downto 0);
    signal tmp : std_logic;
begin

    ODR_Setting : process (odr_conf) is
    begin
        case odr_conf is

            when "0000" =>
                count_max <= "01111010000100100000000000";
            when "0001" =>
                count_max <= "00111101000010010000000000";
            when "0010" =>
                count_max <= "00011110100001001000000000";
            when "0011" =>
                count_max <= "00001111010000100100000000";
            when "0100" =>
                count_max <= "00000111101000010010000000";
            when "0101" =>
                count_max <= "00000011110100001001000000";
            when "0110" =>
                count_max <= "00000001111010000100100000";
            when "0111" =>
                count_max <= "00000000111101000010010000";
            when "1000" =>
                count_max <= "00000000011110100001001000";
            when "1001" =>
                count_max <= "00000000001111010000100100";
            when "1010" =>
                count_max <= "00000000000111101000010010";
            when "1011" =>
                count_max <= "00000000000011110100001001";
            when "1100" =>
                count_max <= "00000000000001111010000100";
            when "1101" =>
                count_max <= "00000000000000111101000010";
            when "1110" =>
                count_max <= "00000000000000011110100001";
            when "1111" =>
                count_max <= "00000000000000001111010000";
            when others =>
                count_max <= "00000001111010000100100000"; --default 50Hz
        end case;
    end process;
    process (clk, rst)
    begin
        if (rst = '0') then
            count <= (others => '0');
            tmp <= '0';
        elsif rising_edge(clk) then
            if (count < (unsigned(count_max) - 1)) then
                count <= count + 1;
            else
                tmp <= not tmp;
                count <= (others => '0');
            end if;
        end if;
        clock_out <= tmp;
    end process;

end bhv;