function [error] = MUX_Dist_Get_Valve(MUX_Dist_ID_in, selected_Valve)
 % Elveflow Library
 % MUXDistributor Device
 % 
 % Get the active valve
 
error=calllib('Elveflow32', 'MUX_Dist_Get_Valve' , MUX_Dist_ID_in, selected_Valve);


end