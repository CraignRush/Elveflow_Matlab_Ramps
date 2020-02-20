%%%%%%%%%%%%%%%%%
%INITIALIZATION
%%%%%%%%%%%%%%%%%
%add path where the lib Elveflow are stored, load library and set all
%required variables (some are pointers to communicate with the DLL)
%and start the instrument
%%%%%%%%%%%%%%%%%

%define here the directory where .m, DLL and this script are 
addpath('D:\dev\SDK\MATLAB_64\MATLAB_64');%path for MATLAB"***.m" file
addpath('D:\dev\SDK\MATLAB_64\MATLAB_64\DLL64\');%path for the DLL library
addpath('D:\dev\SDK\MATLAB_64\Example\')%path for your script

%always use Elveflow_Load at the beginning, it loads the DLL
Elveflow_Load;

error =0;%init error to zero, if an error occurs in the DLL, an error is returned
answer='empty_string';%store the user answer in this variable

%create equivalent of char[] to communicate with the DLL
%the instrument com port can be determined in windows device explorer and/or
%NIMAX
%  ! ! ! TO WORK PROPERLY, FTDI DRIVER ARE REQUIRED !!! (see User Guide)
ComPortPtr = libpointer('cstring','ASRL4::INSTR'); 


%pointer to store the instrument ID (no array)
Inst_ID=libpointer('int32Ptr',zeros(1,1));

%initiate the device (see User
%Guide for help)
%may return an error if the instrument wasn't closed properly last time
error= MUX_Dist_Initialization(ComPortPtr,Inst_ID);
CheckError(error);

disp(strcat('Instrument ID = ', num2str(Inst_ID.Value)));%show the instrument number


%%%%%%%%%%%%%%%%
% MAIN PART
%%%%%%%%%%%%%%%%
%present all the possibility of MUX Distributor
%%%%%%%%%%%%%%%%
%init required variables
SetValve=-1;
GetValvePtr = libpointer('int32Ptr',zeros(1,1));%to store the active valve

%ask the user what to do and loop until user enters exit
while (~strcmp(answer,'exit')) %loop until user enters exit
    %get user answer 
    answer='non valid answer to avoid looping indefinitely';
    while (~(strcmp(answer,'get valve')||strcmp(answer,'set valve')||strcmp(answer,'exit')))
    prompt = '\nChoose what to do: get valve, set valve or exit\n';
    answer = input(prompt,'s');
    end

    
    %set valve
    if strcmp(answer,'set valve')
        prompt = 'set active valve: ';
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
%close communication 
%clear all pointers. If it is not done properly, it will crash at next
%launch
%%%%%%%%%%%%%%%


error=MUX_Dist_Destructor(Inst_ID.Value);%close communication with the instrument
CheckError(error);

Elveflow_Unload;

clear ComPortPtr;
clear Inst_ID;
clear GetValvePtr;