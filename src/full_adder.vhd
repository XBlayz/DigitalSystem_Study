library ieee;
    use ieee.std_logic_1164.all;

entity full_adder is
    port (
        a, b, cin : in    STD_LOGIC;
        s, cout   : out   STD_LOGIC
    );
end entity full_adder;

architecture behavioral of full_adder is
    signal p : STD_LOGIC;

begin
    s    <= p xor cin;
    p    <= a xor b;
    cout <= cin when p = '1' else a;
end architecture behavioral;
