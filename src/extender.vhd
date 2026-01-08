library ieee;
    use ieee.std_logic_1164.all;

entity extender is
    generic (
        N_IN            : POSITIVE;
        N_OUT           : POSITIVE;
        TWOS_COMPLEMENT : BOOLEAN
    );

    port (
        data_in  : in    STD_LOGIC_VECTOR(N_IN - 1 downto 0);
        data_out : out   STD_LOGIC_VECTOR(N_OUT - 1 downto 0)
    );
end entity extender;

architecture behavioral of extender is
    signal sign_bit : STD_LOGIC;

begin
    sign_bit <= data_in(N_IN - 1) when TWOS_COMPLEMENT else '0';

    data_out(N_OUT - 1 downto N_IN) <= (others => sign_bit);
    data_out(N_IN - 1 downto 0)     <= data_in;
end architecture behavioral;
