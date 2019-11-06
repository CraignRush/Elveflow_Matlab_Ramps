function [error] = MUX_Dist_Set_Valve(MUX_Dist_ID_in, selected_Valve)
 % Elveflow Library
 % MUXDistributor Device
 % 
 % Set the active valve
 
error=calllib('Elveflow64', 'MUX_Dist_Set_Valve' , MUX_Dist_ID_in, selected_Valve);


end