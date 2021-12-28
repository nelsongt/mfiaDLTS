%ISLAKESHOREINSTALLED - Check whether Lakeshore 330 or 335 is conected
%
%  isLakeshoreInstalled() returns the model number if matlab can commun-
%  icate with the Lakeshore 33X temperature controller via GPIB and 0 if
%  matlab cannot.
%
%  Works by sending '*idn?' query through GPIB. 

% Todd Karin
% 02/14/2013

%% Modified by George Nelson for Model 330

function installed = isLakeshoreInstalled(model)

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

installed = 0;

try
fopen(obj1)
fprintf(obj1, '*idn?');
pause(.05);

cut = 1:12;
idnCheck33 = 'LSCI,MODEL33';
idn = fscanf(obj1);

if strcmp(idn(cut),idnCheck33(cut))
    installed = 1;
else
    installed = 0;
end

catch err
    disp('Cannot connect to Lakeshore!')
    disp(err.message)
    installed = 0;
end
% Close communication.
fclose(obj1)
end


