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

ElveflowError = 0;% int error to zero, if an error occurs in the dll, an error is returned
answer='empty_sring';% store the user answer in this variable

%create equivalent of char[] to communicate with DLL
%the instrument name can be found in NI Max
Instrument_Name = libpointer('cstring','Dev13'); 


%pointer to store the instrument ID (no array)
Inst_ID=libpointer('int32Ptr',zeros(1,1));

  %Initiate the device 
ElveflowError=MUX_Initialization(Instrument_Name,Inst_ID);
CheckError(ElveflowError);

disp(strcat('Instrument ID = ', num2str(Inst_ID.Value)));%show the instrument number


%%%%%%%%%%%%%%%%
% MAIN PART
%%%%%%%%%%%%%%%%
%Present all the possibility of MUX
%%%%%%%%%%%%%%%%
%init required variables
input_valve = -1;
output_valve = -1;
valve_state = -1;

Array_user=[1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];% change here valve state (see MUX_Set_all_valves.m for description)
Array_user_Ptr = libpointer('int32Ptr',Array_user);%%init all valves here !!! should be exactelly 16 elements, otherwise nothing will happen 

Array_all_open= [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
Array_all_open_Ptr = libpointer('int32Ptr',Array_all_open);%% All valves closed

Array_all_closed=[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];% change here valve state (see MUX_Set_all_valves.m for description)
Array_all_closed_Ptr = libpointer('int32Ptr',Array_all_closed);%%init all valves here !!! should be exactelly 16 elements, otherwise nothing will happen 


trigger = libpointer ('int32Ptr',zeros(1,1)); % pointer to trigger
trigger_value=0;
%ask user what to do and loop until user enter exit
while (~strcmp(answer,'exit')) %loop until user enter exit
    % get user answer 
    answer='non valid answer to avoid looping indefinitelly';
    while (~(strcmp(answer,'set individual valve')||strcmp(answer,'set all valves')||strcmp(answer,'set all valves (MUX Wire)')||strcmp(answer,'close all')||strcmp(answer,'open all')||strcmp(answer,'get trigger')||strcmp(answer,'set trigger')||strcmp(answer,'exit')))
    prompt = '\nChose what to do: set individual valve, set all valves, set all valves (MUX Wire),close all, open all, get trigger, set trigger op exit\n';
    answer = input(prompt,'s');
    end

    
    % Set individual (for MUX quake)
    if strcmp(answer,'set individual valve')
        prompt = 'input valve';
        input_valve=input(prompt);
        prompt = 'output valve';
        output_valve=input(prompt);
        prompt = 'valve_state';
        valve_state=input(prompt);
        ElveflowError = MUX_Set_indiv_valve(Inst_ID.Value,input_valve, output_valve, valve_state);
        CheckError(ElveflowError);
    end
    
    %set all valves (uses Array_user defined above)
    if strcmp(answer,'set all valves')
        
        ElveflowError = MUX_Set_all_valves(Inst_ID.Value, Array_user_Ptr,16);
        CheckError(ElveflowError);
    end
    
    %set all valves for the MUX WIRE(uses Array_user defined above) VALVE
    %ORDER IS DIFFERENTS THAN OTHER MUX
    if strcmp(answer,'set all valves (MUX Wire)')
        
        ElveflowError = MUX_Wire_Set_all_valves(Inst_ID.Value, Array_user_Ptr,16);
        CheckError(ElveflowError);
    end
    
      %Close all valves 
    if strcmp(answer,'close all')
        
        ElveflowError = MUX_Set_all_valves(Inst_ID.Value, Array_all_closed_Ptr,16);
        CheckError(ElveflowError);
    end
    
       %open all valves 
    if strcmp(answer,'open all')
        
        ElveflowError = MUX_Set_all_valves(Inst_ID.Value, Array_all_open_Ptr,16);
        CheckError(ElveflowError);
    end
    
   
    
    %get the trigger value
    if strcmp(answer,'get trigger')
        ElveflowError = MUX_Get_Trig(Inst_ID.Value,trigger);
        CheckError(ElveflowError);
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
            ElveflowError = MUX_Set_Trig(Inst_ID.Value,1);
        else
            ElveflowError = MUX_Set_Trig(Inst_ID.Value,0);
        end
        CheckError(ElveflowError);
    end
end

%%%%%%%%%%%%%%%
%EXIT
%%%%%%%%%%%%%%%
%Close communication 
%Clear all pointer if not done properly, it will crash next time the srcipt
%runs
%%%%%%%%%%%%%%%


MUX_Destructor(Inst_ID.Value);%close communication with the instrument

Elveflow_Unload;

clear Instrument_Name;
clear Inst_ID;
clear Array_all_open_Ptr;
clear Array_user_Ptr;
clear Array_all_closed_Ptr;
clear trigger;
