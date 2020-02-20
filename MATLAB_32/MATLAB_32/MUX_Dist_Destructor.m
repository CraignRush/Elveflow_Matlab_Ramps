function [error] = MUX_Dist_Destructor(MUX_Dist_ID_in)
 % Elveflow Library
 % MUXDistributor Device
 % 
 % Close Communication with MUX distributor device
 
error=calllib('Elveflow32', 'MUX_Dist_Destructor' , MUX_Dist_ID_in);


end