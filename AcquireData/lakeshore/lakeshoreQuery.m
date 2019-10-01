%LAKESHOREQUERY - Send query to lakeshore via gpib
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

function response = lakeshoreQuery(commmand)

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
    fopen(obj1);
    response = sn(query(obj1,commmand));

    % Close communication.
    fclose(obj1);
catch err
    err
    disp(err.message)
    response = '-1';
end
end

% Snip out certain characters
function x =sn(x)
x(x==10)=[];
x(x==13)=[];
end