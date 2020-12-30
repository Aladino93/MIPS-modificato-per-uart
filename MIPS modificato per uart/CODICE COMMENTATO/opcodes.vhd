library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


package opcodes is


  -- register definition
  constant R0: std_logic_vector(4 downto 0) := "00000";
  constant R1: std_logic_vector(4 downto 0) := "00001";
  constant R2: std_logic_vector(4 downto 0) := "00010";
  constant R3: std_logic_vector(4 downto 0) := "00011";
  constant R4: std_logic_vector(4 downto 0) := "00100";
  constant R5: std_logic_vector(4 downto 0) := "00101";
  constant R6: std_logic_vector(4 downto 0) := "00110";
  constant R7: std_logic_vector(4 downto 0) := "00111";
	
	constant ZERO_P: std_logic_vector(10 downto 0) := "00000000000";

  -- opcode definition

	-- R-type
  constant MOV:         std_logic_vector(5 downto 0) := "010001";
  constant ADD:         std_logic_vector(5 downto 0) := "010010";
  constant SUBT:        std_logic_vector(5 downto 0) := "010011";
	
	-- Immediate
  constant ADD_I:       std_logic_vector(5 downto 0) := "001000";
  constant SUB_I:       std_logic_vector(5 downto 0) := "001001";
  constant AND_I:       std_logic_vector(5 downto 0) := "001010";
  constant BEQ:         std_logic_vector(5 downto 0) := "000100";
  constant BNE:         std_logic_vector(5 downto 0) := "000101";
  constant LW:          std_logic_vector(5 downto 0) := "100011";
  constant SW:          std_logic_vector(5 downto 0) := "101011";

  -- Other
  constant NOP:         std_logic_vector(31 downto 0) := (others => '0');
  constant JUMP:        std_logic_vector(5 downto 0) := "000010";
  constant HALT:        std_logic_vector(31 downto 0) := (others => '1');

end package opcodes;

