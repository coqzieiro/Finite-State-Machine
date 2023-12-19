library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity refrigerante is
  port (
    clock         : in  std_logic;
    reset         : in  std_logic;
    switch_10     : in  std_logic;
    switch_25     : in  std_logic;
    switch_50     : in  std_logic;
    switch_100    : in  std_logic;
    button        : in  std_logic;
    release_led   : out std_logic;  -- LED indicando a liberação do refrigerante
    return_led    : out std_logic;  -- LED indicando o retorno das moedas
    leds          : out std_logic_vector(11 downto 0)
  );
end refrigerante;

architecture behavior of refrigerante is
  signal accumulator   : unsigned(11 downto 0) := (others => '0');
  signal value_added   : unsigned(11 downto 0) := (others => '0');
  signal first_clock   : boolean := true;
begin
  process(clock, reset)
  begin
    if reset = '1' then
      if first_clock = false then
        accumulator <= (others => '0');
      end if;

      release_led <= '0';
      return_led <= '0';
      first_clock <= true;  -- Sinaliza que o primeiro clock foi recebido
    elsif rising_edge(clock) then
      -- Remove lixo de memória após o primeiro clock
      if first_clock then
        first_clock <= false;  -- Primeiro clock foi processado
      else
        -- Atualiza o acumulador com base nos switches ativos
        value_added <= (others => '0');

        if switch_10 = '1' then
          value_added(3 downto 0) <= "1010";  -- 10 em binário
        end if;

        if switch_25 = '1' then
          value_added(4 downto 0) <= "11001";  -- 25 em binário
        end if;

        if switch_50 = '1' then
          value_added(5 downto 0) <= "110010";  -- 50 em binário
        end if;

        if switch_100 = '1' then
          value_added(9 downto 0) <= "0001100100";  -- 100 em binário
        end if;

        accumulator <= accumulator + value_added;

        -- Verifica se o valor acumulado ultrapassou 100 e o botão está em 0
        if accumulator > to_unsigned(100, 12) and button = '0' then
          release_led <= '0';  -- Acende o LED de liberação do refrigerante
          return_led <= '1';
          
          -- Reseta o estado
          accumulator <= (others => '0');
          value_added <= (others => '0');
          first_clock <= true;  -- Sinaliza que o primeiro clock foi recebido
        else
          release_led <= '0';  -- Mantém o LED de liberação apagado

          -- Manipula o pressionamento do botão
          if button = '1' then
            if accumulator = to_unsigned(100, 12) then
              release_led <= '1';  -- Usuário inseriu o valor correto (1 real)
				  return_led <= '0';
            else
              return_led <= '1';    -- Usuário inseriu menos que 1 real, retorna todas as moedas
				  release_led <= '0';
            end if;

            -- Reseta o estado
            accumulator <= (others => '0');
            value_added <= (others => '0');
            first_clock <= true;  -- Sinaliza que o primeiro clock foi recebido
          end if;
        end if;
      end if;
    end if;
  end process;

  leds <= std_logic_vector(accumulator);
end behavior;
