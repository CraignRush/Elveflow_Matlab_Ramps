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
answer='empty_sring';% store the user answer in this variable

% create equivalent of char[] to communicate with DLL
% the instrument com port can be determine in windows Device explorer
%  ! ! ! TO WORKS PROPERLY, FTDI DRIVER ARE REQUIRED !!! (see user guide)
ComPortPtr = libpointer('cstring','ASRL4::INSTR'); 


%pointer to store the instrument ID (no array)
Inst_ID=libpointer('int32Ptr',zeros(1,1));

%Initiate the device and all regulators types (see user
%guide for help
%may return an error if the instrument wasn't close properly last use
error= MUX_Dist_Initialization(ComPortPtr,Inst_ID);
CheckError(error);

disp(strcat('Instrument ID = ', num2str(Inst_ID.Value)));%show the instrument number


%%%%%%%%%%%%%%%%
% MAIN PART
%%%%%%%%%%%%%%%%
%Present all the possibility of MUX_Dist
%%%%%%%%%%%%%%%%
%init required variables
SetValve=-1;
GetValvePtr = libpointer('int32Ptr',zeros(1,1));%%to stor the active valve

%ask user what to do and loop until user enter exit
while (~strcmp(answer,'exit')) %loop until user enter exit
    % get user answer 
    answer='non valid answer to avoid looping indefinitelly';
    while (~(strcmp(answer,'get valve')||strcmp(answer,'set valve')||strcmp(answer,'exit')))
    prompt = '\nChose what to do: get valve, set valve or exit\n';
    answer = input(prompt,'s');
    end

    
    % set valve
    if strcmp(answer,'set valve')
        prompt = 'set avcive valve: ';
        SetValve=input(prompt);
        error = MUX_Dist_Set_Valve(Inst_ID.Value, SetValve );
        CheckError(error);
    end
    
    %get valve
    if strcmp(answer,'get valve')
        error = MUX_Dist_Get_Valve(Inst_ID.Value,GetValvePtr );
        CheckError(error);
        disp(strcat('active valve: ' , num2str(GetValvePtr.Value)));
    end
end

%%%%%%%%%%%%%%%
%EXIT
%%%%%%%%%%%%%%%
%Close communication 
%Clear all pointer if not done properly, it will crash next time the srcipt
%runs
%%%%%%%%%%%%%%%


error=MUX_Dist_Destructor(Inst_ID.Value);%close communication with the instrument
CheckError(error);

Elveflow_Unload;

clear ComPortPtr;
clear Inst_ID;
clear GetValvePtr;
