function [error] = MUX_Dist_Initialization(Visa_COM, MUX_Dist_ID_out)
 % Elveflow Library
 % MUXDistributor Device
 % 
 % Initiate the MUX Distributor device using device com port (ASRLXXX::INSTR 
 % where XXX is the com port that could be found in windows device manager). 
 % It return the MUX Distributor ID (number >=0) to be used with other 
 % function
 
error=calllib('Elveflow32', 'MUX_Dist_Initialization' , Visa_COM, MUX_Dist_ID_out);


end