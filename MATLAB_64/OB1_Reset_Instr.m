function [error] = OB1_Reset_Instr(OB1_ID)
 % OB1_Reset_Instr
 
error=calllib('Elveflow64', 'OB1_Reset_Instr' , OB1_ID);


end