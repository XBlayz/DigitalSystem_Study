library ieee;
    use ieee.std_logic_1164.all;

entity full_adder is
    port (
        a, b, cin : in    std_logic;
        s, cout   : out   std_logic
    );
end entity full_adder;

architecture behavioral of full_adder is
    signal p : std_logic;
begin
    s    <= p xor cin;
    p    <= a xor b;
    cout <= cin when p = '1' else a;
end architecture behavioral;
