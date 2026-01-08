library ieee;
    use ieee.std_logic_1164.all;

entity extender is
    generic (
        n_in            : POSITIVE;
        n_out           : POSITIVE;
        twos_complement : BOOLEAN
    );

    port (
        data_in  : in    STD_LOGIC_VECTOR(n_in - 1 downto 0);
        data_out : out   STD_LOGIC_VECTOR(n_out - 1 downto 0)
    );
end entity extender;

architecture behavioral of extender is
    signal sign_bit : STD_LOGIC;

begin
    sign_bit <= data_in(n_in - 1) when twos_complement else '0';

    data_out(n_out - 1 downto n_in) <= (others => sign_bit);
    data_out(n_in - 1 downto 0)     <= data_in;
end architecture behavioral;
