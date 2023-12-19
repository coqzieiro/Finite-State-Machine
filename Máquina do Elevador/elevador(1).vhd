library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity elevador is
  port (
    -- inputs padrao
    clock      : in  std_logic;     
    reset      : in  std_logic;  
    -- input do andar que o elevador deve ir
    entrada    : in  std_logic_vector (3 downto 0);

    -- outputs correspondentes aos estados da maquina
    saida      : out std_logic;  
    estado_out : out std_logic_vector (1 downto 0)
    );
end elevador;

architecture moore of elevador is
	-- estados possiveis da maquina
	type estado_t is (parado, subindo, descendo);
	signal estado     : estado_t                := parado;
	-- inteiros para os andares
	signal a_atual    : integer range 0 to 16   := 0;
	signal a_desejado : integer range 0 to 16   := 0;
	-- sinal para a posicao relativa entre o andar desejado e o atual
	signal pos_rel    : bit_vector (1 downto 0) := "00";
begin

	transicao: process(clock, reset)
	begin
		-- reset do elevador
		if reset = '1' then
			estado  <= parado;
			a_atual <= 0;
			
		-- verifica a borda de subida
		elsif (clock = '1' and clock'event) then
			case estado is
				-- fazendo a transicao dos estados e atualizando o andar
				when parado =>
					if pos_rel = "00" then
						estado <= subindo;
					elsif pos_rel = "01" then
						estado <= descendo;
					elsif pos_rel = "10" then
						estado <= parado;
					end if;
				when subindo =>
					if pos_rel = "00" then
						a_atual <= a_atual + 1;
						estado <= subindo;
					elsif pos_rel = "10" then
						estado <= parado;
					end if;
				when descendo =>
					if pos_rel = "01" then
						a_atual <= a_atual - 1;
						estado <= descendo;
					elsif pos_rel = "10" then
						estado <= parado;
					end if;									
			end case;
		end if;
	end process transicao;

	-- convertendo a entrada de std_logic_vector para integer, pois
	-- facilita aritmetica e comparacao
	conversao: process(entrada, reset)
	begin
		a_desejado <= 0;
		if entrada(0) = '1' then
			a_desejado <= a_desejado + 1;
		end if;
		if entrada(1) = '1' then
			a_desejado <= a_desejado + 2;
		end if;
		if entrada(2) = '1' then
			a_desejado <= a_desejado + 4;
		end if;
		if entrada(3) = '1' then
			a_desejado <= a_desejado + 8;
		end if;
	end process conversao;

	-- determinando se o elevador precisa subir, descer ou parar
	pos_rel <= "00" when a_desejado > a_atual
		else  "01" when a_desejado < a_atual
		else  "10";

	-- exibindo a saida da maquina
	with estado select
		saida <= '1' when parado,
			    '0' when others;

	-- exibindo o estado atual da maquina
	with estado select
	estado_out <= "10" when parado,
			    "00" when subindo,
			    "01" when descendo;
	
end moore;