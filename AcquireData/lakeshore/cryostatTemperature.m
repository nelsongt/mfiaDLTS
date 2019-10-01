%CRYOSTATTEMPERATURE - Get temperatures on Ch A and B
%
% [tempB, tempA] = cryostatTemperature() gets the temperature in the spaces
% B and A from the Lakeshore temperature controller.
%
% Attach the Lake Shore 335 temperature controller via GPIB. This function
% returns the temperature in spaces B and A. In the big magnet setup, B is
% the sample space.
%
% Todd Karin
% 05/14/2013

function [tempB, tempA] = cryostatTemperature()

% Initialize communication to temperature controller.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 12);
% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 0, 12);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Get the temperature
try
    fopen(obj1)

    tempAstring = sn(query(obj1,'KRDG? A'));
    pause(.01);
    tempBstring = sn(query(obj1,'KRDG? B'));

    tempA = str2double(tempAstring);
    tempB = str2double(tempBstring);

    % Close communication.
    fclose(obj1)
catch err
    cprintf('red',strcat(err.message,'\n'))
    disp('Error reading temperature!')
    tempA = 0;
    tempB = 0;
end
end

% Snip out certain characters
function x =sn(x)
x(x==10)=[];
x(x==13)=[];
end
