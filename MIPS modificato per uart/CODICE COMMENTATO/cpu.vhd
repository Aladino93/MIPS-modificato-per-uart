library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_bit.all;
use ieee.numeric_std.all;
use work.opcodes.all;

entity CPU is
port(
	clock:	in std_logic;
	nRst:		in std_logic;
	data_bus:  inout std_logic_vector(31 downto 0);
	address_bus:  out std_logic_vector(31 downto 0);
	nMemRd:	out std_logic;
	nMemWr:  out std_logic;
   nHalt: out std_logic
);

end CPU;

architecture my_CPU of CPU is
	type state_type is (st_reset,
                      st_fetch_0,
                      st_fetch_1,
                      st_exec,
                      st_halt);
	type sub_state_type is (exec_0, exec_1);
	type register_array is array(0 to 7) of std_logic_vector(31 downto 0);
	signal PC: std_logic_vector(31 downto 0) := (others => '0');
	signal IR: std_logic_vector(31 downto 0) := (others => '0');
	signal REGS: register_array;
	signal state: state_type := st_halt;
	signal sub_state: sub_state_type := exec_0;
begin
  process(clock,nRst)  -- inizio del process della cpu che segue il clock 
	variable op_code : std_logic_vector(5 downto 0);
	variable rd, rs, rt : integer;
	variable func : std_logic_vector(5 downto 0);
	variable immediate_val : std_logic_vector(15 downto 0);
	variable NextPC : std_logic_vector(31 downto 0);
  begin

    if (nRst = '0') then --stato di reset
      state <= st_reset;
			
    elsif (clock'event and clock = '1') then -- rising edge  --nel caso non si sia premuto il tasto di reset
		
			NextPC := PC + 1; --il next program counter viene incrementato di 1
			
			case state is  
	
				when st_reset =>  -- stato di reset in cui viene azzerato tutto e vengono bloccati lettura e scrittura
					PC <= (others => '0');
					REGS(0) <= (others => '0');
					REGS(1) <= (others => '0');
					REGS(2) <= (others => '0');
					REGS(3) <= (others => '0');
					REGS(4) <= (others => '0');
					REGS(5) <= (others => '0');
					REGS(6) <= (others => '0');
					REGS(7) <= (others => '0');
					nMemRd <= '1';
					nMemWr <= '1';
					data_bus <= (others => 'Z');
					nHalt <= '1';
					state <= st_fetch_0;
	
				when st_fetch_0 => --viene caricato il program counter sull'address bus
					address_bus <= PC;
					nMemRd <= '0';
					state <= st_fetch_1;
	
				when st_fetch_1 =>  --si legge l'operazione attuale in base al program counter 
					IR <= data_bus;
					nMemRd <= '1';
					sub_state <= exec_0;
					state <= st_exec;
	
				when st_exec =>  -- si eseguono i comandi
	
					if IR = NOP then --non si esegue nulla e si salta all'istruzione successiva il ciclo successivo
						state <= st_fetch_0;
					else  
						op_code := IR(31 downto 26);
						rs := conv_integer(IR(25 downto 21));
						rt := conv_integer(IR(20 downto 16));
						rd := conv_integer(IR(15 downto 11));
						immediate_val := IR(15 downto 0);
						func := IR(5 downto 0);
						case op_code is
						
							when MOV =>        
								if rt /= 0 then -- sposta da rs a rt
									REGS(rt) <= REGS(rs);
								end if;
								state <= st_fetch_0;
								
							when ADD =>
								if rd /= 0 then -- somma rs + rt in rd
									REGS(rd) <= REGS(rs) + REGS(rt);
								end if;
								state <= st_fetch_0;
								
							when SUBT =>
								if rd /= 0 then -- sottrae rs - rt in rd
									REGS(rd) <= REGS(rs) - REGS(rt);
								end if;
								state <= st_fetch_0;
								
							when ADD_I =>  -- aggiunge un valore immediato a rs e lo salva in rt
							if rt /= 0 then
									REGS(rt) <= REGS(rs) + immediate_val;
								end if;
								state <= st_fetch_0;
								
							when SUB_I =>  -- sottrae un valore immediato a rs e lo salva in rt
								if rt /= 0 then
									REGS(rt) <= REGS(rs) - immediate_val;
								end if;
								state <= st_fetch_0;
								
							when AND_I =>  -- And logico con valore immediato e rs e lo salva in rt
								if rt /= 0 then
									REGS(rt) <= REGS(rs) and immediate_val;
								end if;
								state <= st_fetch_0;
								
							when JUMP =>  -- salto non condizionale ad un indirizzo della ROM
								NextPC := "000000" & IR(25 downto 0);
								state <= st_fetch_0;
								
							when BEQ =>  -- salto condizionale se rs = rt
								if REGS(rs) = REGS(rt) then
									NextPC := "0000000000000000" & immediate_val;
								end if;
								state <= st_fetch_0;
								
							when BNE =>  -- salto condizionale se rs != rt
								if REGS(rs) /= REGS(rt) then
									NextPC := "0000000000000000" & immediate_val;
								end if;
								state <= st_fetch_0;
								
							when SW =>  -- store word: carica il valore di rs + immediato nell'address bus e nel data bus il valore di rt							
								case sub_state is
									when exec_0 =>	address_bus <= immediate_val + REGS(rs);
																	data_bus <= REGS(rt);
																	nMemWr <= '0';
																	state <= st_exec;
																	sub_state <= exec_1;
																	
									when exec_1 =>	address_bus <= (others => 'Z');
																	data_bus <= (others => 'Z');
																	nMemWr <= '1';
																	state <= st_fetch_0;
								end case;
								
							when LW =>  -- load word: varica il valore di rs + immediato nell'address bus e salva in rt il valore del data bus							
								case sub_state is
									when exec_0 =>	address_bus <= immediate_val + REGS(rs);
																	nMemRd <= '0';
																	state <= st_exec;
																	sub_state <= exec_1;
																	
									when exec_1 =>	if rt /= 0 then
																		REGS(rt) <= data_bus;
																	end if;
																	address_bus <= (others => 'Z');
																	nMemRd <= '1';
																	state <= st_fetch_0;
								end case;
								
							when others => --caso di default
								state <= st_halt;
						end case;
					end if;
	
				when st_halt => --gestisce caso di default in caso si blocchi
	
					nMemRd <= '1';
					nMemWr <= '1';
					data_bus <= (others => 'Z');
					nHalt <= '0';
	
					state <= st_halt;
					
				when others =>
					state <= st_halt;
					
			end case;
			
			if (state = st_exec and sub_state = exec_0) then --carica il NextPc (che in assenza di salti è semplicemente aumentato di 1) nel program counter
				PC <= NextPC;
			end if;
			
		end if;
		
  end process;

end architecture;


