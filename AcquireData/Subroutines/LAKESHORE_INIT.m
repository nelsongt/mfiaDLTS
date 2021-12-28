function [success] = LAKESHORE_INIT(temp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Check for lakeshore 33X
success = true;
if isLakeshoreInstalled==0
    cprintf('red','Lakeshore Not Found. Connect and restart. Exiting...\n');
    success = false;
end
    
% Setup Lakeshore
config_string = strcat(temp.control,',1,0,2');        % Control sensor A or B, in Kelvin (1), default heater off (0), heater units power (2)
if temp.model == 330
    response = lakeshoreQuery('CSET?');
elseif temp.model == 335
    response = lakeshoreQuery('CSET? 1');
else
    cprintf('red','Error, unsupported model number entered');
    success = false;
end
if ~strcmp(response,config_string)
    lakeshoreQuery(strcat('CSET 1,',config_string));   % Control loop 1, then see config string above
end
range_string = int2str(temp.heatpower);

if temp.model == 330
    response = lakeshoreQuery('RANGE?');
elseif temp.model == 335
    response = lakeshoreQuery('RANGE? 1');
end

if ~strcmp(response,range_string)
    if temp.model == 330
        lakeshoreQuery(strcat('RANGE ',range_string));          % Set heater to high (3), medium (2), low (1)
    elseif temp.model == 335
        lakeshoreQuery(strcat('RANGE 1,',range_string));
    end
end
if strcmp(response,'-1')
    cprintf('red','Error configuring lakeshore. Exiting...\n');
    success = false;
end
cprintf('green','Lakeshore configure OK.\n');
end

