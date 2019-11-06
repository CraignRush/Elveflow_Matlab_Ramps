%%%%%%%%%%%%%%%%%
%INITIALIZATION
%%%%%%%%%%%%%%%%%
%add path where the lib Elveflow are stored, load library and set all
%required variable (some are pointer to communicate with DLL)
%and start the instrument
%%%%%%%%%%%%%%%%%

%define here the directory where .m, Dll and this script are 
addpath('D:\dev\SDK\MATLAB_64\MATLAB_64');% path for Mathlab"***.m" file
addpath('D:\dev\SDK\MATLAB_64\MATLAB_64\DLL64\');% path for DLL library
addpath('D:\dev\SDK\MATLAB_64\Example\')% path your script

%%Always use Elveflow_Load at the begining, it load the DLL
Elveflow_Load;

error =0;% int error to zero, if an error occurs in the dll, an error is returned
answer='empty_string';% store the user answer in this variable

% create equivalent of char[] to communicate with DLL
% the instrument com port can be determine in windows Device explorer
%  ! ! ! TO WORKS PROPERLY, FTDI DRIVER ARE REQUIRED !!! (see user guide)
ComPortPtr = libpointer('cstring','ASRL14::INSTR'); 


%pointer to store the instrument ID (no array)
Inst_ID=libpointer('int32Ptr',zeros(1,1));

%Initiate the device and all regulators types (see user
%guide for help
%may return an error if the instrument wasn't close properly last use
error= BFS_Initialization(ComPortPtr,Inst_ID);
CheckError(error);
error=0;
disp(strcat('Instrument ID = ', num2str(Inst_ID.Value)));%show the instrument number


%%%%%%%%%%%%%%%%
% MAIN PART
%%%%%%%%%%%%%%%%
%Present all the possibility of MUX_Dist
%%%%%%%%%%%%%%%%
%init required variables
SetFilter=-1;
GetValuePtr = libpointer('doublePtr',zeros(1,1));%%to store the returned value

%ask user what to do and loop until user enter exit
while (~strcmp(answer,'exit')) %loop until user enter exit
    % get user answer 
    answer='non valid answer to avoid looping indefinitelly';
    while (~(strcmp(answer,'get density')||strcmp(answer,'get flow')||strcmp(answer,'get temperature')||strcmp(answer,'set filter')||strcmp(answer,'do zero')||strcmp(answer,'exit')))
    prompt = '\nChose what to do: get density, get flow, get temperature, set filter, do zero or exit\n';
    answer = input(prompt,'s');
    end

     %get density
    if strcmp(answer,'get density')
       error = BFS_Get_Density(Inst_ID.Value,GetValuePtr );
       CheckError(error);
       disp(strcat('measured Density: ' , num2str(GetValuePtr.Value)));
    end
    
    %get flow
    if strcmp(answer,'get flow')
       error = BFS_Get_Flow(Inst_ID.Value,GetValuePtr );
       CheckError(error);
       disp(strcat('measured Flow: ' , num2str(GetValuePtr.Value),'. Remember that density need to be measured at least once before since density is used to measure the flow.\n If measurement frequency is not critical, always measure first density and then flow'));
    end
    
    %get Temperature
    if strcmp(answer,'get temperature')
       error = BFS_Get_Temperature(Inst_ID.Value,GetValuePtr );
       CheckError(error);
       disp(strcat('measured Temperature: ' , num2str(GetValuePtr.Value)));
    end
    
    % set filter
    if strcmp(answer,'set filter')
        prompt = 'set filter value (1=min filter, 0,00001=max filter)';
        SetFilter=input(prompt);
        error = BFS_Set_Filter(Inst_ID.Value, SetFilter );
        CheckError(error);
    end
    
    %put valves to stop the flow before performing zeroing
    %Zeroing last approximately 10 sec. Wait for the LED to stop blinking before sending an other command.
    %Read corresponding User Guide to perform correctly the zeroing procedure.
    if strcmp(answer,'do zero')
        error = BFS_Zeroing(Inst_ID.Value);
        CheckError(error);
    end
end

%%%%%%%%%%%%%%%
%EXIT
%%%%%%%%%%%%%%%
%Close communication 
%Clear all pointer if not done properly, it will crash next time the srcipt
%runs
%%%%%%%%%%%%%%%


error=BFS_Destructor(Inst_ID.Value);%close communication with the instrument
CheckError(error);

Elveflow_Unload;

clear Inst_ID;
clear GetValvePtr;
