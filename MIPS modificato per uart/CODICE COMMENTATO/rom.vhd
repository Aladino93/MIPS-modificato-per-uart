library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.opcodes.all;

entity rom is
port(
	data_bus_out: out std_logic_vector(31 downto 0);
	address_bus:  in std_logic_vector(31 downto 0);
	nMemRd:	in std_logic
	);
end rom;

architecture rom_arch of rom is

signal out_byte: std_logic_vector(31 downto 0);
begin
	process(nMemRd)
	begin
			if nMemRd = '0' then
				case address_bus is					

when x"00000000" =>      out_byte <= NOP; -- non esegue nulla
when x"00000001" =>      out_byte <= LW  & R0 & R1  & x"8000"; --legge l'indirizzo 8000 e carica il risultato della lettura in R1 (cioè legge l'RX dell'UART)
when x"00000002" =>      out_byte <= ADD_I & R0 & R2 & x"0009"; -- carica il valore x0009 in R2
when x"00000003" =>      out_byte <= BEQ & R1 & R2 & x"0005"; -- jump condizionale se R1 e R2 sono uguali alla linea di codice 0005 (cioè se l'UART ha ricevuto x0009)
when x"00000004" =>      out_byte <= JUMP  & "00" & x"000001"; --se l'UART non ha letto x0009 riesegue il programma da zero
when x"00000005" =>      out_byte <= SW    & "00000" & R1 & x"9000"; --l'UART trasmette il valore di R1 tramite TX (in questo caso trasmette x0009 fino a che non riceve un numero diverso)
when x"00000006" =>      out_byte <= JUMP  & "00" & x"000001"; --jump 


					when others => 		out_byte <= (others => 'Z');
				end case;
			else
				out_byte <= (others => 'Z');
			end if;
	end process;

	data_bus_out <= out_byte;
	
end architecture;
