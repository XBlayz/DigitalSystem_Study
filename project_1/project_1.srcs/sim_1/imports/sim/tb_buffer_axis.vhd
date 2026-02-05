library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_buffer_axis is
end entity tb_buffer_axis;

architecture testing of tb_buffer_axis is
    -- Testing parameters (5x5 image)
    constant CLK_PERIOD       : time := 10 ns; -- 100 MHz
    constant NCOL_IMG         : integer := 5;  -- Columns
    constant NROW_IMG         : integer := 5;  -- Rows
    constant KERNEL_SIZE      : integer := 3;  -- 3x3 kernel

    -- Testing signals
    signal s_axis_clk    : std_logic := '0';
    signal s_axis_rstn   : std_logic := '0';
    signal s_axis_tvalid : std_logic := '0';
    signal s_axis_tlast  : std_logic := '0';
    signal s_axis_tready : std_logic;
    signal s_axis_tdata  : std_logic_vector(7 downto 0) := (others => '0');

    signal m_axis_tvalid : std_logic;
    signal m_axis_tlast  : std_logic;
    signal m_axis_tready : std_logic := '1';

    -- Control signals from state_machine
    signal pipeline_en    : std_logic;
    signal window_valid   : std_logic;
    signal flush_pipeline : std_logic;

    -- Buffer output signals
    signal d00, d01, d02, d10, d11, d12, d20, d21, d22 : std_logic_vector(7 downto 0);

    -- Auxiliary signals
    signal sim_done      : boolean := false;
    signal pixel_count   : integer := 0;
    signal output_count  : integer := 0;

    signal curr_out_row  : integer := 0;
    signal curr_out_col  : integer := 0;

    -- Component to test: state_machine
    component state_machine is
        generic(
            ncol_img        : integer;
            nrow_img        : integer;
            kernel_row_size : integer
        );
        port(
            s_axis_clk      : in  std_logic;
            s_axis_rstn     : in  std_logic;
            s_axis_tvalid   : in  std_logic;
            s_axis_tready   : out std_logic;
            s_axis_tlast    : in  std_logic;
            m_axis_tvalid   : out std_logic;
            m_axis_tready   : in  std_logic;
            m_axis_tlast    : out std_logic;
            pipeline_en     : out std_logic;
            window_valid    : out std_logic;
            flush_pipeline  : out std_logic
        );
    end component state_machine;

    -- Component to test: buffer_line
    component buffer_line is
        generic(
            ncol : integer
        );
        port(
            clk   : in  std_logic;
            reset : in  std_logic;
            valid : in  std_logic;
            flush : in  std_logic;
            data  : in  std_logic_vector(7 downto 0);

            d00, d01, d02, d10, d11, d12, d20, d21, d22 : out std_logic_vector(7 downto 0)
        );
    end component buffer_line;

    -- Pixel array for verification
    type pixel_array is array (0 to NROW_IMG-1, 0 to NCOL_IMG-1) of std_logic_vector(7 downto 0);
    signal sent_pixels   : pixel_array;

begin
    -- Component instantiations

    -- State Machine instantiation
    sm_inst: state_machine
        generic map(
            ncol_img        => NCOL_IMG,
            nrow_img        => NROW_IMG,
            kernel_row_size => KERNEL_SIZE
        )
        port map(
            s_axis_clk      => s_axis_clk,
            s_axis_rstn     => s_axis_rstn,
            s_axis_tvalid   => s_axis_tvalid,
            s_axis_tready   => s_axis_tready,
            s_axis_tlast    => s_axis_tlast,
            m_axis_tvalid   => m_axis_tvalid,
            m_axis_tready   => m_axis_tready,
            m_axis_tlast    => m_axis_tlast,
            pipeline_en     => pipeline_en,
            window_valid    => window_valid,
            flush_pipeline  => flush_pipeline
        );

    -- Buffer Line instantiation
    bl_inst: buffer_line
        generic map(
            ncol => NCOL_IMG
        )
        port map (
            clk   => s_axis_clk,
            reset => s_axis_rstn,
            valid => pipeline_en,
            flush => flush_pipeline,
            data  => s_axis_tdata,
            d00   => d00, d01 => d01, d02 => d02,
            d10   => d10, d11 => d11, d12 => d12,
            d20   => d20, d21 => d21, d22 => d22
        );

    -- Clock Generation
    clk_gen : process
    begin
        while not sim_done loop
            s_axis_clk <= '0';
            wait for CLK_PERIOD/2;
            s_axis_clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Generation INPUT data
    stimulus : process
        variable row, col : integer;
        variable pixel_val : std_logic_vector(7 downto 0);

    begin
        -- 1. Initial reset
        s_axis_rstn <= '0';
        wait for CLK_PERIOD * 10;
        s_axis_rstn <= '1';
        wait for CLK_PERIOD * 2;

        -- 2. Sending data
        for row in 0 to NROW_IMG-1 loop
            for col in 0 to NCOL_IMG-1 loop
                -- Pattern pixel: (riga * NCOL_IMG) + colonna (valore univoco)
                pixel_val := std_logic_vector(to_unsigned(row * NCOL_IMG + col, 8));

                s_axis_tdata  <= pixel_val;
                s_axis_tvalid <= '1';

                -- TLAST alto solo all'ultimo pixel della riga
                if col = NCOL_IMG-1 then
                    s_axis_tlast <= '1';
                else
                    s_axis_tlast <= '0';
                end if;

                -- Memorizza per verifica successiva
                sent_pixels(row, col) <= pixel_val;

                -- Attendi handshake (tvalid & tready)
                wait until rising_edge(s_axis_clk);
                while s_axis_tready = '0' loop
                    wait until rising_edge(s_axis_clk);
                end loop;

                pixel_count <= pixel_count + 1;
            end loop;
        end loop;

        -- 3. Ending transmission
        s_axis_tvalid <= '0';

        wait;
    end process;
end testing;
