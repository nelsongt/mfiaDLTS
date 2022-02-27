function response = lakeshoreQuery(command)
%LAKESHOREQUERY - Send query to lakeshore via gpib
%
% This function returns the response from the Lakeshore to whicher
% command is passed to this function
%
% Todd Karin
% 05/14/2013
% Modified by GN for generic queries

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
    response = sn(query(obj1,command));

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
