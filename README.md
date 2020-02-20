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
	Instrument_Name = libpointer('cstring','01C9D9C3');
	```