# NEL_MATLAB-ELVEFLOW_Integration

An simple program to drive ramps with an Elveflow OB1 Pressure controller

## Prequisites
- MATLAB 2019b
	- Add-On __MATLAB Support for MinGW-w64 C/C++ Compiler __
- Active Connection to Elveflow System
	- Name of Elveflow OB1 as HEX-Number (Can be found via NI MAX)
	``` MATLAB
	Instrument_Name = libpointer('cstring','01C9D9C3');
	```