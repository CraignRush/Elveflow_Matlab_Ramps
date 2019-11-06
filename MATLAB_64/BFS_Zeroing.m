function [error] = BFS_Zeroing(BFS_ID_in)
 % BFS_Zeroing
 
error=calllib('Elveflow64', 'BFS_Zeroing' , BFS_ID_in);


end