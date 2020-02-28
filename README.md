# NEL_MATLAB-ELVEFLOW_Integration

An simple program to drive ramps with an Elveflow OB1 Pressure controller

## Prequisites
- MATLAB 2019b
- Visual Studio 
	- Tested versions: _VS Community 2015 (64-bit)_, _VS Community 2017 (64-bit)_,_VS Community 2019 (64-bit)_
	- __NECCESSARY__: _C/C++ Toolchain_ (MSVC) for your processor architecture
- Active Connection to Elveflow System
	- Name of Elveflow OB1 as HEX-Number (Can be found via NI MAX)
	- The NEL Elveflow Device:
	``` MATLAB
	Instrument_Name = libpointer('cstring','01E5A2C4');
	```
- In case of a x64 System: Install the setup in the `Installx64` folder


## Program
### MATLAB_32 / MATLAB_64
The ELVEFLOW libraries for the respective system architecture. For most TUM-PCs the 64-bit library is required. 
### Test_Ramp.m
This file is a simple connection to the ELVEFLOW OB1 and can be operated via command line. It should not be developed further. However, there may be code snippets in it which can be reused in the _GUI.mlapp_.
#### Call structure
1. Query the operating system for its architecture and add the respective library to the path which is mandatory for operation.
2. Query the setup for the installed C/C++ toolchain. Use the MATLAB reference for the `mex -setup` command at any error.
3. Load the Elveflow DLL. Almost every error in here is related to the compiler resp. toolchain
4. The initialization:
	- Save the Intrument name, -ID and -calibration into the suitable C-Pointer conversion.
	- Call the initialization and check for errors
	- A calibration as specified is mandatory for the instrument to operate. You can choose between new, load and default (which is the easiest)
5. Data transfer:
 -The variables for writing and receiving data have to be initialized with the according C-Pointers
 -However, they can be processed as normal matlab variables.
6. Program Cleanup
	- For a succesful termination the communication to the OB1 has to be closed by calling `OB1_Desructor` (with appropriate error checking) and subsequently the unloading of the dynamic library (`Elveflow_Unload`).
	- As a good practice, every variable is manually cleaned after termination.
### GUI.mlapp
The app is aimed to be the final and only running script. 


