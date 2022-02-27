function [model] = isLakeshoreInstalled()
%ISLAKESHOREINSTALLED - Check whether Lakeshore connected and return model number
%
%  isLakeshoreInstalled() returns the model number if matlab can commun-
%  icate with the Lakeshore 33X temperature controller via GPIB and 0 if
%  matlab cannot.
%
%  Works by sending '*idn?' query through GPIB. 

% Todd Karin
% 02/14/2013
% Modified by George Nelson for mfiaDLTS

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

if strcmp(idn(cut),idnCheck33)
    installed = 1;
else
    installed = 0;
end

catch err
    disp('Cannot connect to Lakeshore!')
    disp(err.message)
    installed = 0;
end

model = 0;
if installed == 1  % If Lakeshore found, check model number
    cut = 11:13;
    model = str2num(idn(cut));
end

% Supported models are 331 and 335
if ~((model == 331) || (model == 335))
    model = 0;
end
    
% Close communication.
fclose(obj1)
end


