function [error] = OB1_Reset_Digit_Sens(OB1_ID, Channel_1_to_4)
 % OB1_Reset_Digit_Sens
 
error=calllib('Elveflow64', 'OB1_Reset_Digit_Sens' , OB1_ID, Channel_1_to_4);


end