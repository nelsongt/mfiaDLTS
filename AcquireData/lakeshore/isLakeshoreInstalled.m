%ISLAKESHOREINSTALLED - Check whether Lakeshore 335 is conected
%
%  isColdFingerInstalled() returns 1 if matlab can communicate with the
%  Lakeshore 335 temperature controller via GPIB and 0 if matlab cannot.
%
%  Works by sending '*idn?' query through GPIB. 

% Todd Karin
% 02/14/2013

%% Modified by George Nelson for Model 330

function installed = isLakeshoreInstalled()

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

cut = 1:10;
idnCheck = 'LSCI,MODEL330,0,032301';
idn = fscanf(obj1);

if strcmp(idn(cut),idnCheck(cut))
    installed = 1;
else
    installed = 0;
end

catch err
    disp('Cannot connect to Lakeshore 335!')
    disp(err.message)
    installed = 0;
end
% Close communication.
fclose(obj1)
end


