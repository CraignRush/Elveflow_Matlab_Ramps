%% A Simple Script To Drive a Ramp On The OB1 Pressure Controller
% 06.11.2019 Johann Brenner

%% Device Initialization
%define here the directory where .m, Dll and this script are
addpath('./MATLAB_64/Example');% path for Mathlab"***.m" file
addpath('./MATLAB_64/DLL64');% path for DLL library
addpath('./MATLAB_64');% path for DLL library
addpath('./')% path for your script

try
    mex -setup C
catch
    error('Compiler does not work properly!');
end

%%Always use Elveflow_Load at the begining, it load the DLL
Elveflow_Load;

error =0;% int error to zero, if an error occurs in the dll, an error is returned
answer='empty_string';% store the user answer in this variable

%create equivalent of char[] to communicate with DLL
%the instrument name can be found in NI Max
Instrument_Name = libpointer('cstring','01C9D9C3'); %01C9D9C3 is the name of my instrument

%create a pointer for calibrationset
CalibSize = 1000;
Calibration = libpointer('doublePtr',ones(CalibSize,1));

%pointer to store the instrument ID (no array)
Inst_ID=libpointer('int32Ptr',zeros(1,1));

%Initiate the device and all regulators and sensors types (see user
%guide for help
error=OB1_Initialization(Instrument_Name,1,2,4,3,Inst_ID);
CheckError(error);

%add digital flow sensor. Valid for OB1 MK3+ only, if sensor not detected it will throw an error ;
%error=OB1_Add_Sens(Inst_ID.Value,1,5,1,0,7); %add digital flow sensor. Valid for OB1 MK3+ only, if sensor not detected it will throw an error ;
%CheckError(error);

%disp(strcat('Instrument ID = ', num2str(Inst_ID.Value)));%show the instrument number

%% Controller Calibration
%Chose between new calibration (take about 2 minutes), load calibration or
%default calibration

% adk user what kind of calibration to use
while (~(strcmp(answer,'new')||strcmp(answer,'load')||strcmp(answer,'default')))
    prompt = 'what kind of calibration do you want to use ?(new, load, default)\n';
    answer = input(prompt,'s');
end

if strcmp(answer,'new')%new calibration takes about 2 minutes
    if error==0%avoid new calibration if something appends during the initialization
        Calib_Dir = uigetdir('', 'Please specify the calibration file directory:');
        Calib_Save = libpointer('cstring',Calib_Dir);
        error = OB1_Calib(Inst_ID.Value,Calibration, CalibSize);
        %Save the valibration for futher use
        error=Elveflow_Calibration_Save( Calib_Save , Calibration, CalibSize);
        CheckError(error);
    end
end

if strcmp(answer,'load')%load previous valibration
    Calib_Dir = uigetdir('', 'Please specify the calibration file directory:');
    Calib_Load = libpointer('cstring',Calib_Dir);
    error = Elveflow_Calibration_Load( Calib_Load , Calibration, CalibSize);
    CheckError(error);
end

if strcmp(answer,'default')%use default calibration
    error = Elveflow_Calibration_Default(Calibration, CalibSize);
    CheckError(error);
end

%% Main Loop
% where the magic happens

%init required variables
Press_Array = libpointer('doublePtr',zeros(4,1)); % to store 4 channel pressure
Press_value= libpointer('doublePtr',zeros(1,1));% to store the pressure of 1 Channel
flow_rate = libpointer ('doublePtr',zeros(1,1)); % pointer to store the flow rate
trigger = libpointer ('int32Ptr',zeros(1,1)); % pointer to trigger
channel_n = -1;
trigger_value = 0;


while (~strcmp(answer,'exit')) %loop until user enter exit
    % get user answer
    answer='non valid answer to avoid looping indefinitelly';
    while (~(strcmp(answer,'get pressure')||strcmp(answer,'set pressure')...
            ||strcmp(answer,'get everything')||strcmp(answer,'get sensor')...
            ||strcmp(answer,'get trigger')||strcmp(answer,'set trigger')...
            ||strcmp(answer,'exit')))
        prompt = ['\nChose what to do: get pressure, get sensor, get\n'...
            'everything, set pressure, drive rampe or exit\n'];
        answer = input(prompt,'s');
    end
    
    
    %% Get the current measured pressure from a channel
    channel_n = -1; %reset channel_n to -1
    set_pressure=0;
    
    % get pressure
    if strcmp(answer,'get pressure')
        %Select the channel
        while (~(channel_n>0&&channel_n<5))
            prompt = 'select channel (1-4)';
            channel_n=input(prompt);
        end
        
        error = OB1_Get_Press(Inst_ID.Value ,channel_n, 1, Calibration, Press_value, CalibSize);
        CheckError(error);
        
        disp(strcat('pressure ch',num2str(channel_n), ' = ' , num2str(Press_value.Value),' mbar'));
    end
    
    % get pressure
    if strcmp(answer,'drive ramp')
        
        %Select the channel
        while (~(channel_n>0&&channel_n<5))
            prompt = 'select channel (1-4)';
            channel_n=input(prompt);
        end
        
        steepness = 0;
        while (~(steepness > 0 && steepness < 1000))
            prompt = 'how steep should the ramp be [mbar/s]';
            steepness=input(prompt);
        end
        
        saturation = 0;
        while (~(saturation > 0 && saturation < 1000))
            prompt = 'specify the final pressure [mbar]';
            saturation=input(prompt);
        end
        
        % Get initial pressure to start ramp from
        error = OB1_Get_Press(Inst_ID.Value ,channel_n, 1, Calibration, Press_init, CalibSize);        
        CheckError(error);
        
        % Calculate the final step number 
        step_final = ceil((saturation - Press_init) / steepness);
        
        % interpolate in 100 ms resolution (TODO test finer) 
        for x = 1:0.1:step_final
            press = steepness * x + Press_init; 
            error = OB1_Set_Press(Inst_ID.Value,channel_n,press,Calibration,CalibSize);
            CheckError(error);
            disp(strcat('pressure ch',num2str(channel_n), ' = ' , num2str(Press_value.Value),' mbar'));
            pause(0.09);
        end      
        
    end
end

%% Closing and freeing memory

error=OB1_Destructor(Inst_ID.Value);%close communication with the instrument
CheckError(error);
    
Elveflow_Unload;% Unload DLL

clear Instrument_Name;
clear Inst_ID;
clear MyCalibPath;
clear Calibration;
clear Press_Array;
clear flow_rate;
clear trigger;
