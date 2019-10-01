% LAKESHORE Control lakeshore model 335 temperature controller 
% Version 1.1 Nov-14-2014
%
% SUMMARY 
%
%   Communicate through GPIB to the Lakeshore 335 temperature controller
%   using GPIB.
%
% DESCRIPTION
%   This matlab toolbox contains scripts for communicating with a Lakeshore
%   model 335 temperature controller. The functions are built from rather
%   simple implementations of GPIB commands. The manual for the Lakeshore
%   controller is available at
%   http://www.lakeshore.com/Documents/335_Manual.pdf
%
%   This package is used for the Fu lab at University of Washington to
%   setup our magnetic cryostat and reliquifier. The cryostat is a Janis
%   model 7THL-SOM2-11 Split superconducting magnet system. The reliquifier
%   is a Cryomech PT410 remote motor helium reliquifier.
%
%   This package will also be useful if you just need to control a
%   Lakeshore Model 335 for other purposes.
%   
%
% FUNCTIONS
%
%   ISLAKESHOREINSTALLED - Check whether Lakeshore 335 is conected
%   CRYOSTATTEMPERATURE - Get temperatures on Ch A and B
%   SAMPLESPACETEMPERATURE - Get temperature in sample space
%   ISLAKESHOREINSTALLED - Check whether Lakeshore 335 is conected
%   GETLAKESHORECURVE - Reads curves from the lakeshore
%   SWITCHLAKESHORECURVE - switch between coldhead and he-reservoir
%   LAKESHOREQUERY - Send query to lakeshore via gpib
%
%
% OTHER FILES
%
%   lakeshoreCurve_11_05_2014.mat - information and curves for setting up
%   the cold head and helium reservoir temperature control.
%
%   S95718.txt - Sample curve for diode temperature sensor
%
% SETUP
%
%   Connect a Lakeshore 335 temperature controller to the computer using
%   GPIB. This package looks for the temperature controller at board index
%   0, primary address 12. We use an NI-GPIB-USB-HS converter.
%
% INSTALL
%
%   Save these functions to you hard drive and add them to the matlab
%   path.
%
% Todd Karin
% 11/05/2014