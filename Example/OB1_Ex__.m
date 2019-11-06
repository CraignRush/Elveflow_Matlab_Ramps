%%%%%%%%%%%%%%%%%
%INITIALIZATION
%%%%%%%%%%%%%%%%%
%add path where the lib Elveflow are stored, load library and set all
%required variable (some are pointer to communicate with DLL)
%and start the instrument
%%%%%%%%%%%%%%%%%

%define here the directory where .m, Dll and this script are 
addpath('./MATLAB_64\Example');% path for Mathlab"***.m" file
addpath('./MATLAB_64\DLL64');% path for DLL library
addpath('./')% path for your script

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


% adk user what kind of calibration to use
while (~(strcmp(answer,'new')||strcmp(answer,'load')||strcmp(answer,'default')))
    prompt = 'what kind of calibration do you want to use ?(new, load, default)\n';
    answer = input(prompt,'s');
end

if strcmp(answer,'new')%new calibration takes about 2 minutes
    if error==0%avoid new calibration if something appends during the initialization
        error = OB1_Calib(Inst_ID.Value,Calibration, CalibSize);
        %Save the valibration for futher use
        error=Elveflow_Calibration_Save( Calib_Save , Calibration, CalibSize);
        CheckError(error);
    end
end

if strcmp(answer,'load')%load previous valibration
    error = Elveflow_Calibration_Load( Calib_Load , Calibration, CalibSize);
    CheckError(error);
end

if strcmp(answer,'default')%use default calibration
    error = Elveflow_Calibration_Default(Calibration, CalibSize);
    CheckError(error);
end

%%%%%%%%%%%%%%%%
% MAIN PART
%%%%%%%%%%%%%%%%
%Present all the possibility of OB1
%%%%%%%%%%%%%%%%
%init required variables
Press_Array = libpointer('doublePtr',zeros(4,1)); % to store 4 channel pressure
Press_value= libpointer('doublePtr',zeros(1,1));%to store the pressure of 1 Channel
flow_rate = libpointer ('doublePtr',zeros(1,1)); % pointer to store the flow rate
trigger = libpointer ('int32Ptr',zeros(1,1)); % pointer to trigger
channel_n = -1;
trigger_value=0;
%ask user what to do and loop until user enter exit
while (~strcmp(answer,'exit')) %loop until user enter exit
    % get user answer 
    answer='non valid answer to avoid looping indefinitelly';
    while (~(strcmp(answer,'get pressure')||strcmp(answer,'set pressure')...
            ||strcmp(answer,'get everything')||strcmp(answer,'get sensor')...
            ||strcmp(answer,'get trigger')||strcmp(answer,'set trigger')...
            ||strcmp(answer,'exit')))
    prompt = ['\nChose what to do: get pressure, get sensor, get'... 
        'everything, set pressure, set trigger, get trigger or exit\n'];
    answer = input(prompt,'s');
    end
    
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
    
    %get flow
    if strcmp(answer,'get sensor')
        while (~(channel_n>0&&channel_n<5))
            prompt = 'select channel (1-4)';
            channel_n=input(prompt);
        end
        error = OB1_Get_Sens_Data(Inst_ID.Value,channel_n, 1,flow_rate); %Acquire data =1 -> Aquire the fresh data, if zero, used data in buffer 
        %error = OB1_Get_Flow_rate(Inst_ID.Value,channel_n,flow_rate);
        CheckError(error);
        disp(strcat( 'sensor data = ',num2str(flow_rate.Value)));
    end
    
    %get all pressure and sensor
    if strcmp(answer,'get everything')
        
        error = OB1_Get_Press(Inst_ID.Value ,1, 1, Calibration, Press_value, CalibSize);%Acquire data =1 -> Refresh the buffer (takes about 2 ms)
        CheckError(error);
        disp(strcat('pressure ch',num2str(i), ' = ' , num2str(Press_value.Value),' mbar'));
        for i = 2:4 % read all the other channels using the value writen in buffer by the previous OB1_Get_Press function
             error = OB1_Get_Press(Inst_ID.Value , i, 0, Calibration, Press_value, CalibSize);%Acquire data =0 -> used data acquired in the buffer the buffer (takes about 2 ms)
             disp(strcat('pressure ch',num2str(i), ' = ' , num2str(Press_value.Value),' mbar'));
        end
        
        for i = 1:4 % read all sensor using the value writen in buffer by the previous OB1_Get_Press function, for digital sensor, the value is read by this function
             error = OB1_Get_Sens_Data(Inst_ID.Value ,i, 0, flow_rate);%Acquire data =0 -> used data acquired in the buffer the buffer (takes about 2 ms)
             disp(strcat('sens ch',num2str(i), ' = ' , num2str(flow_rate.Value),'µL/min or mbar'));
        end
    end
    
    %set pressure
    if strcmp(answer,'set pressure')
        while (~(channel_n>0&&channel_n<5))
            prompt = 'select channel (1-4)';
            channel_n=input(prompt);
        end
        prompt = 'select pressure (mbar)';
        set_pressure=input(prompt);
        error = OB1_Set_Press(Inst_ID.Value,channel_n,set_pressure,Calibration,CalibSize);
        CheckError(error);
    end
    
    
    %get the trigger value
    if strcmp(answer,'get trigger')
        error = OB1_Get_Trig(Inst_ID.Value,trigger);
        CheckError(error);
        if trigger.Value==0
            disp(strcat( 'Trigger is Low '));
        end
        if trigger.Value==1
            disp(strcat( 'Trigger is High '));
        end   
    end
    
    %set Trigger
    if strcmp(answer,'set trigger')
        
        while (~(strcmp(answer,'high')||strcmp(answer,'low')))
            prompt = 'set trigger state (high or low)';
            answer=input(prompt,'s');
        end
        if strcmp(answer,'high')
            error = OB1_Set_Trig(Inst_ID.Value,1);
            CheckError(error);
        else
            error = OB1_Set_Trig(Inst_ID.Value,0);
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
