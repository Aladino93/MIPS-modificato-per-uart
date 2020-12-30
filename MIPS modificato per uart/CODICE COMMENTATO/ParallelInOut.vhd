library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ParallelInOut is
 Generic (
        CLK_FREQ    : integer := 50e6;   -- set system clock frequency in Hz
        BAUD_RATE   : integer := 115200; -- baud rate value
        PARITY_BIT  : string  := "none"  -- legal values: "none", "even", "odd", "mark", "space"
    );
port(
	address_bus: in std_logic_vector(31 downto 0)  ;
	data_bus:  inout std_logic_vector(31 downto 0) ;
	data_output : out std_logic_vector(31 downto 0);
	data_input : in std_logic_vector(31 downto 0);
	clock: in std_logic  ;
	nMemWr:  in std_logic;
	nMemRd:  in std_logic;
	nRst: in std_logic;
	UART_TXD    : out std_logic;
    UART_RXD    : in  std_logic
);
end ParallelInOut;

architecture pInOut of ParallelInOut is

signal  rst         : std_logic;
signal  data_out    :  std_logic_vector(7 downto 0);
signal  data_vld    :  std_logic; -- when DATA_VLD = 1, data on DATA_OUT are valid
signal  frame_error :  std_logic;  -- when FRAME_ERROR = 1, stop bit was invalid, current and next data may be invalid
signal  busy : std_logic;
signal  data_send : std_logic ;
signal  data_in :  std_logic_vector(7 downto 0) ;


begin
   rst  <=  not(nRst); -- il reset della periferica uart è il negato del segnale di reset del sistema
	
	
	process(clock,nRst)
	begin
	
		if nRst = '0' then  --se sono in reset non spedisco dati, pulisco il display e  metto in alta impedenza il databus
			data_output  <= (others => '0');
			data_bus <= (others => 'Z');
			data_send <= '0';
		elsif (clock'event and clock = '0') then
			
			if (address_bus = x"00008000" and busy = '0' ) then -- se l'address bus evocato dalla cpu è x8000 allora si va a leggere se l'UART ha ricevuto qualcosa
			    data_send <= '0'; --si blocca il TX
				 
				if nMemWr = '0' then  --se eseguo l'accesso con l'operazione sbagliata di Store word semplicemente carico il data_bus sul display
				
				
					data_output <= data_bus ;
					
				elsif nMemRd = '0' then  --se eseguo l'accesso all'indirizzo con Load word allora visualizzo sul display l'ultimo byte ricevuto e lo rendo disponibile sul data_bus
					data_bus <= x"000000" & data_out;
					data_output <= x"000000" & data_out;
				else --operazione di default se qualcosa va storto
					data_bus <= (others => 'Z');
				end if;
				
			elsif (address_bus =x"00009000" and busy = '0') then --se l'address bus diventa x9000 allora tramite data_send a 1 attivo la periferica di TX che trasmetterà 8 bit del data_bus
			data_in <= data_bus(7 downto 0);
		    data_send <= '0';
			data_send <= '1';
				end if;
		end if;
	end process;
	
	
	
	--Mapping della periferica di UART
	
	uart_i: entity work.UART
    generic map (
        CLK_FREQ      =>  CLK_FREQ,   
        BAUD_RATE     =>  BAUD_RATE, 
        PARITY_BIT    =>  PARITY_BIT 
    )
    port map (
        
		  -- collegamenti fisici 
		  CLK         =>  clock ,
          RST         =>  rst ,
          UART_TXD    =>  UART_TXD ,
		  UART_RXD    =>  UART_RXD,
        		  
		  -- segnali
          DATA_IN     =>  data_in ,
		  DATA_SEND   =>  data_send,
	      BUSY        =>  busy  ,
	      DATA_OUT    =>  data_out,  
          DATA_VLD    =>  data_vld ,
          FRAME_ERROR =>  frame_error
    );
	 
	 
	 
end architecture;





