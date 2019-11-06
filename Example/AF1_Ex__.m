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

%create equivalent of char[] to communicate with DLL
%the instrument name can be found in NI Max
Instrument_Name = libpointer('cstring','MyAF1'); 

%create a pointer for calibration
CalibSize = 1000;
Calibration = libpointer('doublePtr',zeros(CalibSize,1));

%pointer to store the instrument ID (no array)
Inst_ID=libpointer('int32Ptr',zeros(1,1));

%Initiate the device and all regulators and sensors types (see user
%guide for help
%may return an error if the instrument wasn't close properly last use
error=AF1_Initialization(Instrument_Name,4,1,Inst_ID);
CheckError(error);

disp(strcat('Instrument ID = ', num2str(Inst_ID.Value)));%show the instrument number


%%%%%%%%%%%%%%%%
% CALIBRATION
%%%%%%%%%%%%%%%%
%Chose between new calibration (take about 2 minutes) load calibration or
%default calibration
%%%%%%%%%%%%%%%%

%set the calibrations path (if not found it will ask the user to chose the
%file. For instanrce define : 
%Calib_Save = libpointer('cstring','C:\Users\Public\Documents\Elvesys\MyCalib');
Calib_Save = libpointer('cstring',' ');
Calib_Load = libpointer('cstring',' ');


% adk user what kinf of calibration to use
while (~(strcmp(answer,'new')||strcmp(answer,'load')||strcmp(answer,'default')))
    prompt = 'what kind of calibration do you want to use ?(new, load, default)\n';
    answer = input(prompt,'s');
end

if strcmp(answer,'new')%new calibration takes about 2 minutes
    if error==0
        error=AF1_Calib(Inst_ID.Value,Calibration, CalibSize);
        CheckError(error);
    end
    %Save the valibration for futher use
    if error==0
        error=Elveflow_Calibration_Save( Calib_Save , Calibration, CalibSize);
        CheckError(error);
    end
end

if strcmp(answer,'load')%load previous valibration
    if error==0
         error = Elveflow_Calibration_Load( Calib_Load , Calibration, CalibSize);
    end
end

if strcmp(answer,'default')%use default calibration
    if error==0
         error = Elveflow_Calibration_Default(Calibration, CalibSize);
    end
end

%%%%%%%%%%%%%%%%
% MAIN PART
%%%%%%%%%%%%%%%%
%Present all the possibility of AF1
%%%%%%%%%%%%%%%%
%init required variables
Pressure = libpointer('doublePtr',zeros(1,1)); % to store the pressure
flow_rate = libpointer ('doublePtr',zeros(1,1)); % pointer to store the flow rate
trigger = libpointer ('int32Ptr',zeros(1,1)); % pointer to trigger
channel_n = -1;
trigger_value=0;
%ask user what to do and loop until user enter exit
while (~strcmp(answer,'exit')) %loop until user enter exit
    % get user answer 
    answer='non valid answer to avoid looping indefinitelly';
    while (~(strcmp(answer,'get pressure')||strcmp(answer,'set pressure')||strcmp(answer,'get sensor')||strcmp(answer,'get trigger')||strcmp(answer,'set trigger')||strcmp(answer,'exit')))
        prompt = '\nChose what to do: get pressure, set pressure, get sensor, set trigger, get trigger or exit\n';
        answer = input(prompt,'s');
    end
    
    channel_n=-1; %reset channel_n to -1
    set_pressure=0;
    
    % get pressure
    if strcmp(answer,'get pressure')
        %integrate pressure over 100 ms
        error = AF1_Get_Press(Inst_ID.Value,100,Calibration, Pressure, CalibSize);
        CheckError(error);
        disp(strcat('pressure ch = ' , num2str(Pressure.Value),' mbar'));
    end
    
    %set pressure
    if strcmp(answer,'set pressure')
        prompt = 'select pressure (mbar)';
        set_pressure=input(prompt);
        error = AF1_Set_Press(Inst_ID.Value,set_pressure,Calibration,CalibSize);
        CheckError(error);
    end
    
    %get flow
    if strcmp(answer,'get sensor')
        error = AF1_Get_Flow_rate(Inst_ID.Value,flow_rate);
        CheckError(error);
        disp(strcat( 'flow rate = ',num2str(flow_rate.Value)));
              
    end
    
    %get the trigger value
    if strcmp(answer,'get trigger')
        error = AF1_Get_Trig(Inst_ID.Value,trigger);
        CheckError(error);
        if trigger.Value==0
            disp(strcat( 'Trigger is Low '));
        end
        if trigger.Value==1
            disp(strcat( 'Trigger is High '));
        end   
    end
    
    %set Trigger
    if strcmp(answer,'set trigger')%new calibration
        while (~(strcmp(answer,'high')||strcmp(answer,'low')))
            prompt = 'set trigger state (high or low)';
            answer=input(prompt,'s');
        end
        if strcmp(answer,'high')
            error = AF1_Set_Trig(Inst_ID.Value,1);
            CheckError(error);
        else
            error = AF1_Set_Trig(Inst_ID.Value,0);
            CheckError(error);
        end
    end
end

%%%%%%%%%%%%%%%
%EXIT
%%%%%%%%%%%%%%%
%Close communication 
%Clear all pointer if not done properly, it will crash next time the srcipt
%runs
%%%%%%%%%%%%%%%


error=AF1_Destructor(Inst_ID.Value);%close communication with the instrument
CheckError(error);

Elveflow_Unload;

clear Instrument_Name;
clear Inst_ID;
clear MyCalibPath;
clear Calibration;
clear Press_Array;
clear flow_rate;
clear trigger;
