%%%%%%%%%%%%%%%%%
%INITIALIZATION
%%%%%%%%%%%%%%%%%
%add path where the lib Elveflow are stored, load library and set all
%required variable (some are pointer to communicate with DLL)
%and start the instrument
%%%%%%%%%%%%%%%%%

%define here the directory where .m, Dll and this script are 
addpath('D:\dev\SDK\SDK_V3_03_00\MATLAB_64\MATLAB_64');% path for MATLAB"***.m" file
addpath('D:\dev\SDK\SDK_V3_03_00\MATLAB_64\MATLAB_64\DLL64');% path for DLL library
addpath('D:\dev\SDK\SDK_V3_03_00\MATLAB_64\Example')% path for your script

%%Always use Elveflow_Load at the beginning, it load the DLL
Elveflow_Load;

error=0;% int error to zero, if an error occurs in the dll, an error is returned
answer='empty_sring';% store the user answer in this variable

%create equivalent of char[] to communicate with DLL
%the instrument name can be found in NI Max
Instrument_Name = libpointer('cstring','01DAA568'); %here instrument name is 01DAA568


%pointer to store the instrument ID (no array)
Inst_ID=libpointer('int32Ptr',zeros(1,1));

%Initiate the device and all regulators types (see user
%guide for help
%may return an error if the instrument wasn't close properly last use
error=M_S_R_D_Initialization(Instrument_Name,5,0,0,0,Inst_ID); %remember that channel 1-2 and 3-4 should be the same kind //sensor type has to be the same in this function as in the "Add_Sens" function
CheckError(error);

%add sensor
error=M_S_R_D_Add_Sens(Inst_ID.Value,1,5,1,0,7); %add digital flow sensor. if sensor not detected it will throw an error ;
CheckError(error);

disp(strcat('Instrument ID = ', num2str(Inst_ID.Value)));%show the instrument number


%%%%%%%%%%%%%%%%
% MAIN PART
%%%%%%%%%%%%%%%%
%Present all the possibility of MSRD
%%%%%%%%%%%%%%%%
%init required variables
channel_n=-1;
sensor_value_Ptr = libpointer('doublePtr',zeros(1,1));%%to stor the value of the selected channel 

%ask user what to do and loop until user enter exit
while (~strcmp(answer,'exit')) %loop until user enter exit
    % get user answer 
    answer='non valid answer to avoid looping indefinitelly';
    while (~(strcmp(answer,'get sensor')||strcmp(answer,'exit')))
    prompt = '\nChoose what to do: get sensor or exit\n';
    answer = input(prompt,'s');
    end

    
    % get sensor
    if strcmp(answer,'get sensor')
        prompt = 'which channel (1-4)?';
        channel_n=input(prompt);
        error = M_S_R_D_Get_Sens_Data(Inst_ID.Value,channel_n, sensor_value_Ptr );
        CheckError(error);
        disp(strcat('sensor',num2str(channel_n),'= ' , num2str(sensor_value_Ptr.Value)));
    end
end

%%%%%%%%%%%%%%%
%EXIT
%%%%%%%%%%%%%%%
%Close communication 
%Clear all pointer if not done properly, it will crash next time the script
%runs
%%%%%%%%%%%%%%%


error=M_S_R_D_Destructor(Inst_ID.Value);%close communication with the instrument
CheckError(error);

Elveflow_Unload;

clear Instrument_Name;
clear Inst_ID;
clear sensor_value_Ptr;