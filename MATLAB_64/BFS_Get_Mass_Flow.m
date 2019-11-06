function [error] = BFS_Get_Mass_Flow(BFS_ID_in, MassFlow)
 % BFS_Get_Mass_Flow
 
error=calllib('Elveflow64', 'BFS_Get_Mass_Flow' , BFS_ID_in, MassFlow);


end