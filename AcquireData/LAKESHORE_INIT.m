function [success] = LAKESHORE_INIT()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Check for lakeshore 331
if isLakeshoreInstalled==0
    cprintf('red','Lakeshore Not Found. Connect and restart. Exiting...\n');
    success = false;
end
    
% Setup Lakeshore
response = lakeshoreQuery('CSET?');
if ~strcmp(response,'B,1,0,2')
    lakeshoreQuery('CSET 1,B,1,0,2');   % Control loop 1, sensor B, in Kelvin (1), default heater off (0), heater units power (2)
end
response = lakeshoreQuery('RANGE?');
if ~strcmp(response,'3')
    lakeshoreQuery('RANGE 3');          % Set heater to high (3), medium (2), low (1)
end
if strcmp(response,'-1')
    cprintf('red','Error configuring lakeshore. Exiting...\n');
    success = false;
end
cprintf('green','Lakeshore configure OK.\n');
success = true;
end

